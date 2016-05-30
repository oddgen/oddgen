/*
 * Copyright 2015-2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.oddgen.sqldev.dal

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.sql.CallableStatement
import java.sql.Clob
import java.sql.Connection
import java.sql.SQLException
import java.sql.Types
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.generators.DatabaseGenerator
import org.oddgen.sqldev.model.DatabaseGeneratorDto
import org.springframework.dao.DataAccessException
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.CallableStatementCallback
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Document
import org.w3c.dom.Element

@Loggable
class DatabaseGeneratorDao {
	private static int MAX_DEPTH = 2
	private int depth = 0
	private Connection conn
	private JdbcTemplate jdbcTemplate
	private extension DalTools dalTools

	new(Connection conn) {
		this.conn = conn
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		this.dalTools = new DalTools(conn)
	}

	def private setName(DatabaseGeneratorDto dbgen) {
		val plsql = '''
			BEGIN
				? := «dbgen.generatorOwner».«dbgen.generatorName».get_name();
			END;
		'''
		dbgen.name = plsql.string
		if (dbgen.name == null) {
			dbgen.name = '''«dbgen.generatorOwner».«dbgen.generatorName»'''
		}
	}

	def private setDescription(DatabaseGeneratorDto dbgen) {
		val plsql = '''
			BEGIN
				? := «dbgen.generatorOwner».«dbgen.generatorName».get_description();
			END;
		'''
		dbgen.description = plsql.string
		if (dbgen.description == null) {
			dbgen.description = dbgen.name
		}
	}

	def private setObjectTypes(DatabaseGeneratorDto dbgen) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_types «dbgen.generatorOwner».«dbgen.generatorName».t_string;
			   l_clob   CLOB;
			BEGIN
			   l_types := «dbgen.generatorOwner».«dbgen.generatorName».get_object_types();
			   l_clob := '<values>';
			   FOR i IN 1 .. l_types.count
			   LOOP
			      l_clob := l_clob || '<value>' || l_types(i) || '</value>';
			   END LOOP;
			   l_clob := l_clob || '</values>';
			   ? := l_clob;
			END;
		'''
		dbgen.objectTypes = new ArrayList<String>()
		val doc = plsql.doc
		if (doc == null) {
			dbgen.objectTypes.add("TABLE")
			dbgen.objectTypes.add("VIEW")
		} else {
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val type = value.textContent
				dbgen.objectTypes.add(type)
			}
		}
	}
	
	def private List<String>  getOrderedParams(DatabaseGeneratorDto dbgen) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_ordered_params «dbgen.generatorOwner».«dbgen.generatorName».t_string;
			   l_clob           CLOB;
			BEGIN
			   l_ordered_params := «dbgen.generatorOwner».«dbgen.generatorName».get_ordered_params();
			   l_clob := '<values>';
			   FOR i IN 1 .. l_ordered_params.count
			   LOOP
			      l_clob := l_clob || '<value>' || l_ordered_params(i) || '</value>';
			   END LOOP;
			   l_clob := l_clob || '</values>';
			   ? := l_clob;
			END;
		'''
		val orderedParams = new ArrayList<String>()
		val doc = plsql.doc
		if (doc != null) {
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val type = value.textContent
				orderedParams.add(type)
			}
		}
		return orderedParams
	}

	def private setParams(DatabaseGeneratorDto dbgen) {
		// initialize Parameters in the requested order
		dbgen.params = new LinkedHashMap<String, String>()
		for (param : getOrderedParams(dbgen)) {
			dbgen.params.put(param, "")
		}
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_params «dbgen.generatorOwner».«dbgen.generatorName».t_param;
			   l_key    «dbgen.generatorOwner».«dbgen.generatorName».param_type;
			   l_clob   CLOB;
			BEGIN
			   l_params := «dbgen.generatorOwner».«dbgen.generatorName».get_params();
			   l_key    := l_params.first;
			   l_clob   := '<params>';
			   WHILE l_key IS NOT NULL
			   LOOP
			      l_clob := l_clob || '<param><key>' || l_key || '</key><value>' || l_params(l_key) || '</value></param>';
			      l_params.delete(l_key);
			      l_key := l_params.first;
			   END LOOP;
			   l_clob := l_clob || '</params>';
			   ? := l_clob;
			END;
		'''
		val doc = plsql.doc
		if (doc != null) {
			val params = doc.getElementsByTagName("param")
			for (var i = 0; i < params.length; i++) {
				val param = params.item(i) as Element
				val key = param.getElementsByTagName("key").item(0).textContent
				val value = param.getElementsByTagName("value").item(0).textContent
				dbgen.params.put(key, value)
			}
		}
	}

	def private setLovs(DatabaseGeneratorDto dbgen, Document doc) {
		dbgen.lovs.clear
		if (doc != null) {
			val lovs = doc.getElementsByTagName("lov")
			if (lovs.length > 0) {
				for (var i = 0; i < lovs.length; i++) {
					val lov = lovs.item(i) as Element
					val key = lov.getElementsByTagName("key").item(0).textContent
					val values = lov.getElementsByTagName("value")
					val value = new ArrayList<String>()
					for (var j = 0; j < values.length; j++) {
						val valueElement = values.item(j) as Element
						value.add(valueElement.textContent)
					}
					dbgen.lovs.put(key, value)
				}
			}

		}
	}

	def private setLovs(DatabaseGeneratorDto dbgen) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_lovs «dbgen.generatorOwner».«dbgen.generatorName».t_lov;
			   l_key  «dbgen.generatorOwner».«dbgen.generatorName».param_type;
			   l_lov  «dbgen.generatorOwner».«dbgen.generatorName».t_string;
			   l_clob CLOB;
			BEGIN
			   l_lovs := «dbgen.generatorOwner».«dbgen.generatorName».get_lov();
			   l_key  := l_lovs.first;
			   l_clob := '<lovs>';
			   WHILE l_key IS NOT NULL
			   LOOP
			      l_clob := l_clob || '<lov><key>' || l_key || '</key><values>';
			      FOR i IN 1 .. l_lovs(l_key).count
			      LOOP
			         l_clob := l_clob || '<value>' || l_lovs(l_key) (i) || '</value>';
			      END LOOP;
			      l_clob := l_clob || '</values></lov>';
			      l_lovs.delete(l_key);
			      l_key := l_lovs.first;
			   END LOOP;
			   l_clob := l_clob || '</lovs>';
			   ? := l_clob;
			END;
		'''
		dbgen.lovs = new HashMap<String, List<String>>()
		val doc = plsql.doc
		setLovs(dbgen, doc)
	}
	
	def private setParamStates(DatabaseGeneratorDto dbgen) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_params       «dbgen.generatorOwner».«dbgen.generatorName».t_param;
			   l_param_states «dbgen.generatorOwner».«dbgen.generatorName».t_param;
			   l_key          «dbgen.generatorOwner».«dbgen.generatorName».param_type;
			   l_clob         CLOB;
			BEGIN
			   «FOR key : dbgen.params.keySet»
			      l_params('«key»') := '«dbgen.params.get(key)»';
			   «ENDFOR»
			   l_param_states := «dbgen.generatorOwner».«dbgen.generatorName».refresh_param_states(in_params => l_params);
			   l_key          := l_param_states.first;
			   l_clob         := '<paramStates>';
			   WHILE l_key IS NOT NULL
			   LOOP
			      l_clob := l_clob || '<paramState><key>' || l_key || '</key><value>' || l_param_states(l_key) || '</value></paramState>';
			      l_param_states.delete(l_key);
			      l_key := l_param_states.first;
			   END LOOP;
			   l_clob := l_clob || '</paramStates>';
			   ? := l_clob;
			END;
		'''
		dbgen.paramStates = new HashMap<String, String>()
		val doc = plsql.doc
		if (doc != null) {
			val paramStates = doc.getElementsByTagName("paramState")
			for (var i = 0; i < paramStates.length; i++) {
				val paramState = paramStates.item(i) as Element
				val key = paramState.getElementsByTagName("key").item(0).textContent
				val value = paramState.getElementsByTagName("value").item(0).textContent
				dbgen.paramStates.put(key, value)
			}
		}
	}
	

	def private setRefreshable(DatabaseGeneratorDto dbgen) {
		val sql = '''
			SELECT COUNT(*)
			  FROM (SELECT *
			          FROM all_arguments
			         WHERE owner = '«dbgen.generatorOwner»'
			               AND package_name = '«dbgen.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 0
			               AND in_out = 'OUT'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«dbgen.generatorOwner»'
			               AND type_name = '«dbgen.generatorName»'
			               AND type_subname = 'T_LOV'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«dbgen.generatorOwner»'
			               AND package_name = '«dbgen.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 1
			               AND in_out = 'IN'
			               AND argument_name = 'IN_OBJECT_TYPE'
			               AND data_type = 'VARCHAR2'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«dbgen.generatorOwner»'
			               AND package_name = '«dbgen.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 2
			               AND in_out = 'IN'
			               AND argument_name = 'IN_OBJECT_NAME'
			               AND data_type = 'VARCHAR2'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«dbgen.generatorOwner»'
			               AND package_name = '«dbgen.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 3
			               AND in_out = 'IN'
			               AND argument_name = 'IN_PARAMS'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«dbgen.generatorOwner»'
			               AND type_name = '«dbgen.generatorName»'
			               AND type_subname = 'T_PARAM')
		'''
		val count = jdbcTemplate.queryForObject(sql, Integer)
		if (count == 4) {
			dbgen.isRefreshable = true
		} else {
			dbgen.isRefreshable = false
		}
	}

	def findAll() {
		// uses Oracle dictionary structure as of 9.2.0.8
		val sql = '''
			WITH 
			   dbgens AS (
			      SELECT proc.owner,
			             proc.object_name,
			             proc.procedure_name,
			             nvl((SELECT 1
			                   FROM all_arguments arg
			                  WHERE arg.owner = obj.owner
			                        AND arg.package_name = obj.object_name
			                        AND arg.object_name = proc.procedure_name
			                        AND arg.position = 3
			                        AND arg.argument_name = 'IN_PARAMS'
			                        AND in_out = 'IN'
			                        AND arg.data_type = 'PL/SQL TABLE'
			                        AND arg.type_subname = 'T_PARAM'),
			                 0) AS generate_has_inparams
			        FROM all_procedures proc
			        JOIN all_objects obj
			          ON obj.owner = proc.owner
			             AND obj.object_name = proc.object_name
			       WHERE proc.procedure_name = 'GENERATE'
			             AND obj.object_type = 'PACKAGE'
			             AND EXISTS (SELECT 1
			                FROM all_arguments arg
			               WHERE arg.owner = obj.owner
			                     AND arg.package_name = obj.object_name
			                     AND arg.object_name = proc.procedure_name
			                     AND arg.position = 0
			                     AND in_out = 'OUT'
			                     AND arg.data_type = 'CLOB')
			             AND EXISTS (SELECT 1
			                FROM all_arguments arg
			               WHERE arg.owner = obj.owner
			                     AND arg.package_name = obj.object_name
			                     AND arg.object_name = proc.procedure_name
			                     AND arg.position = 1
			                     AND arg.argument_name = 'IN_OBJECT_TYPE'
			                     AND in_out = 'IN'
			                     AND arg.data_type = 'VARCHAR2')
			             AND EXISTS (SELECT 1
			                FROM all_arguments arg
			               WHERE arg.owner = obj.owner
			                     AND arg.package_name = obj.object_name
			                     AND arg.object_name = proc.procedure_name
			                     AND arg.position = 2
			                     AND arg.argument_name = 'IN_OBJECT_NAME'
			                     AND in_out = 'IN'
			                     AND arg.data_type = 'VARCHAR2')
			   )
			SELECT owner AS generator_owner,
			       object_name AS generator_name,
			       MAX(generate_has_inparams) AS has_params
			  FROM dbgens
			 GROUP BY owner, object_name
			 ORDER BY owner, object_name
		'''
		val dtos = jdbcTemplate.query(sql, new BeanPropertyRowMapper<DatabaseGeneratorDto>(DatabaseGeneratorDto))
		val dbgens = new ArrayList<DatabaseGenerator>()
		for (dto : dtos) {
			dto.setName
			dto.setDescription
			dto.setObjectTypes
			dto.setRefreshable
			dto.setParams
			dto.setLovs
			dto.setParamStates
			val dbgen = new DatabaseGenerator(dto)
			dbgens.add(dbgen)
		}
		return dbgens
	}

	def refresh(DatabaseGeneratorDto dbgen, String objectType, String objectName, LinkedHashMap<String, String> params) {
		if (dbgen.isRefreshable) {
			// convert PL/SQL associative array to XML
			// pass current parameter values as PL/SQL code
			val plsql = '''
				DECLARE
				   l_params «dbgen.generatorOwner».«dbgen.generatorName».t_param;
				   l_lovs   «dbgen.generatorOwner».«dbgen.generatorName».t_lov;
				   l_key    «dbgen.generatorOwner».«dbgen.generatorName».param_type;
				   l_lov    «dbgen.generatorOwner».«dbgen.generatorName».t_string;
				   l_clob   CLOB;
				BEGIN
				   «FOR key : params.keySet»
				      l_params('«key»') := '«params.get(key)»';
				   «ENDFOR»
				   l_lovs := «dbgen.generatorOwner».«dbgen.generatorName».refresh_lov(
				                in_object_type => '«objectType»',
				                in_object_name => '«objectName»',
				                in_params      => l_params
				             );
				   l_key  := l_lovs.first;
				   l_clob := '<lovs>';
				   WHILE l_key IS NOT NULL
				   LOOP
				      l_clob := l_clob || '<lov><key>' || l_key || '</key><values>';
				      FOR i IN 1 .. l_lovs(l_key).count
				      LOOP
				         l_clob := l_clob || '<value>' || l_lovs(l_key) (i) || '</value>';
				      END LOOP;
				      l_clob := l_clob || '</values></lov>';
				      l_lovs.delete(l_key);
				      l_key := l_lovs.first;
				   END LOOP;
				   l_clob := l_clob || '</lovs>';
				   ? := l_clob;
				END;
			'''
			val doc = plsql.doc
			setLovs(dbgen, doc)
		}
		dbgen.setParamStates
	}	

	def String generate(DatabaseGeneratorDto dbgen, String objectType, String objectName, LinkedHashMap<String, String> params) {
		depth++
		val plsql = '''
			DECLARE
			   «IF params != null && params.size > 0»
			      l_params «dbgen.generatorOwner».«dbgen.generatorName».t_param;
			   «ENDIF»
			   l_clob   CLOB;
			BEGIN
			   «IF params != null && params.size > 0»
			      «FOR key : params.keySet»
			         l_params('«key»') := '«params.get(key)»';
			   	  «ENDFOR»
			   «ENDIF»
			   l_clob := «dbgen.generatorOwner».«dbgen.generatorName».generate(
			                  in_object_type => '«objectType»'
			                , in_object_name => '«objectName»'
			                «IF params != null && params.size > 0»
			                   , in_params      => l_params
			                «ENDIF»
			             );
			   ? := l_clob;
			END;
		'''
		var String result;
		try {
			val resultClob = jdbcTemplate.execute(plsql.removeCarriageReturns, new CallableStatementCallback<Clob>() {
				override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.CLOB);
					cs.execute
					return cs.getClob(1);
				}
			})
			result = resultClob.getSubString(1, resultClob.length as int)
		} catch (Exception e) {
			if (e.message.contains("ORA-04068") && depth < MAX_DEPTH) {
				// catch : existing state of packages has been discarded
				Logger.debug(this, '''Failed with ORA-04068. Try again («depth»).''')
				result = generate(dbgen, objectType, objectName, params)
			} else {
				result = '''Failed to generate code for «objectType».«objectName» via «dbgen.generatorOwner».«dbgen.generatorName». Got the following error: «e.cause?.message»'''
				Logger.error(this, plsql + result)
			}
		} finally {
			depth--
		}
		return result
	}

}
