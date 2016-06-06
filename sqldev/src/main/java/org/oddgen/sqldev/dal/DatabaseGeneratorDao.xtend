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
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.generators.DatabaseGenerator
import org.oddgen.sqldev.model.DatabaseGeneratorMetaData
import org.springframework.dao.DataAccessException
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.CallableStatementCallback
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Document
import org.w3c.dom.Element

@Loggable(LoggableConstants.DEBUG)
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

	def private setName(DatabaseGeneratorMetaData metaData) {
		val plsql = '''
			BEGIN
				? := «metaData.generatorOwner».«metaData.generatorName».get_name();
			END;
		'''
		metaData.name = plsql.string
		if (metaData.name == null) {
			metaData.name = '''«metaData.generatorOwner».«metaData.generatorName»'''
		}
	}

	def private setDescription(DatabaseGeneratorMetaData metaData) {
		val plsql = '''
			BEGIN
				? := «metaData.generatorOwner».«metaData.generatorName».get_description();
			END;
		'''
		metaData.description = plsql.string
		if (metaData.description == null) {
			metaData.description = metaData.name
		}
	}

	def getObjectTypes(DatabaseGeneratorMetaData metaData) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_types «metaData.generatorOwner».«metaData.generatorName».t_string;
			   l_clob   CLOB;
			BEGIN
			   l_types := «metaData.generatorOwner».«metaData.generatorName».get_object_types();
			   l_clob := '<values>';
			   FOR i IN 1 .. l_types.count
			   LOOP
			      l_clob := l_clob || '<value>' || l_types(i) || '</value>';
			   END LOOP;
			   l_clob := l_clob || '</values>';
			   ? := l_clob;
			END;
		'''
		val objectTypes = new ArrayList<String>()
		val doc = plsql.doc
		if (doc == null) {
			objectTypes.add("TABLE")
			objectTypes.add("VIEW")
		} else {
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val type = value.textContent
				objectTypes.add(type)
			}
		}
		return objectTypes
	}

	def private List<String> getOrderedParams(DatabaseGeneratorMetaData metaData) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_ordered_params «metaData.generatorOwner».«metaData.generatorName».t_string;
			   l_clob           CLOB;
			BEGIN
			   l_ordered_params := «metaData.generatorOwner».«metaData.generatorName».get_ordered_params();
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

	def getParams(DatabaseGeneratorMetaData metaData) {
		// initialize Parameters in the requested order
		val params = new LinkedHashMap<String, String>()
		for (param : getOrderedParams(metaData)) {
			params.put(param, "")
		}
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_params «metaData.generatorOwner».«metaData.generatorName».t_param;
			   l_key    «metaData.generatorOwner».«metaData.generatorName».param_type;
			   l_clob   CLOB;
			BEGIN
			   l_params := «metaData.generatorOwner».«metaData.generatorName».get_params();
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
			val xmlParams = doc.getElementsByTagName("param")
			for (var i = 0; i < xmlParams.length; i++) {
				val param = xmlParams.item(i) as Element
				val key = param.getElementsByTagName("key").item(0).textContent
				val value = param.getElementsByTagName("value").item(0).textContent
				params.put(key, value)
			}
		}
		return params
	}

	def private getLovs(HashMap<String, List<String>> lovs, Document doc) {
		lovs.clear
		if (doc != null) {
			val xmlLovs = doc.getElementsByTagName("lov")
			if (xmlLovs.length > 0) {
				for (var i = 0; i < xmlLovs.length; i++) {
					val lov = xmlLovs.item(i) as Element
					val key = lov.getElementsByTagName("key").item(0).textContent
					val values = lov.getElementsByTagName("value")
					val value = new ArrayList<String>()
					for (var j = 0; j < values.length; j++) {
						val valueElement = values.item(j) as Element
						value.add(valueElement.textContent)
					}
					lovs.put(key, value)
				}
			}

		}
		return lovs
	}

	def getLovs(DatabaseGeneratorMetaData metaData) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_lovs «metaData.generatorOwner».«metaData.generatorName».t_lov;
			   l_key  «metaData.generatorOwner».«metaData.generatorName».param_type;
			   l_lov  «metaData.generatorOwner».«metaData.generatorName».t_string;
			   l_clob CLOB;
			BEGIN
			   l_lovs := «metaData.generatorOwner».«metaData.generatorName».get_lov();
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
		val lovs = new HashMap<String, List<String>>()
		val doc = plsql.doc
		return getLovs(lovs, doc)
	}

	def getLovs(DatabaseGeneratorMetaData metaData, String objectType, String objectName, LinkedHashMap<String, String> params) {
		// convert PL/SQL associative array to XML
		// pass current parameter values as PL/SQL code
		val plsql = '''
			DECLARE
			   l_params «metaData.generatorOwner».«metaData.generatorName».t_param;
			   l_lovs   «metaData.generatorOwner».«metaData.generatorName».t_lov;
			   l_key    «metaData.generatorOwner».«metaData.generatorName».param_type;
			   l_lov    «metaData.generatorOwner».«metaData.generatorName».t_string;
			   l_clob   CLOB;
			BEGIN
			   «FOR key : params.keySet»
			   	l_params('«key»') := '«params.get(key)»';
			   «ENDFOR»
			   l_lovs := «metaData.generatorOwner».«metaData.generatorName».refresh_lov(
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
		val lovs = new HashMap<String, List<String>>()
		return getLovs(lovs, doc)
	}

	def getParamStates(DatabaseGeneratorMetaData metaData, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_params       «metaData.generatorOwner».«metaData.generatorName».t_param;
			   l_param_states «metaData.generatorOwner».«metaData.generatorName».t_param;
			   l_key          «metaData.generatorOwner».«metaData.generatorName».param_type;
			   l_clob         CLOB;
			BEGIN
			   «FOR key : params.keySet»
			   	l_params('«key»') := '«params.get(key)»';
			   «ENDFOR»
			   l_param_states := «metaData.generatorOwner».«metaData.generatorName».refresh_param_states(
			   			            in_object_type => '«objectType»',
			   			            in_object_name => '«objectName»',
			   			            in_params      => l_params
			   			         );
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
		val paramStates = new HashMap<String, String>()
		val doc = plsql.doc
		if (doc != null) {
			val xmlParamStates = doc.getElementsByTagName("paramState")
			for (var i = 0; i < xmlParamStates.length; i++) {
				val paramState = xmlParamStates.item(i) as Element
				val key = paramState.getElementsByTagName("key").item(0).textContent
				val value = paramState.getElementsByTagName("value").item(0).textContent
				paramStates.put(key, value)
			}
		}
		return paramStates
	}

	def private setHasRefreshLovs(DatabaseGeneratorMetaData metaData) {
		val sql = '''
			SELECT COUNT(*)
			  FROM (SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 0
			               AND in_out = 'OUT'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«metaData.generatorOwner»'
			               AND type_name = '«metaData.generatorName»'
			               AND type_subname = 'T_LOV'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 1
			               AND in_out = 'IN'
			               AND argument_name = 'IN_OBJECT_TYPE'
			               AND data_type = 'VARCHAR2'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 2
			               AND in_out = 'IN'
			               AND argument_name = 'IN_OBJECT_NAME'
			               AND data_type = 'VARCHAR2'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 3
			               AND in_out = 'IN'
			               AND argument_name = 'IN_PARAMS'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«metaData.generatorOwner»'
			               AND type_name = '«metaData.generatorName»'
			               AND type_subname = 'T_PARAM')
		'''
		val count = jdbcTemplate.queryForObject(sql, Integer)
		if (count == 4) {
			metaData.hasRefreshLovs = true
		} else {
			metaData.hasRefreshLovs = false
		}
	}

	def private setHasRefreshParamStates(DatabaseGeneratorMetaData metaData) {
		val sql = '''
			SELECT COUNT(*)
			  FROM (SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_PARAM_STATES'
			               AND position = 0
			               AND in_out = 'OUT'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«metaData.generatorOwner»'
			               AND type_name = '«metaData.generatorName»'
			               AND type_subname = 'T_PARAM'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_PARAM_STATES'
			               AND position = 1
			               AND in_out = 'IN'
			               AND argument_name = 'IN_OBJECT_TYPE'
			               AND data_type = 'VARCHAR2'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_PARAM_STATES'
			               AND position = 2
			               AND in_out = 'IN'
			               AND argument_name = 'IN_OBJECT_NAME'
			               AND data_type = 'VARCHAR2'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«metaData.generatorOwner»'
			               AND package_name = '«metaData.generatorName»'
			               AND object_name = 'REFRESH_PARAM_STATES'
			               AND position = 3
			               AND in_out = 'IN'
			               AND argument_name = 'IN_PARAMS'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«metaData.generatorOwner»'
			               AND type_name = '«metaData.generatorName»'
			               AND type_subname = 'T_PARAM')
		'''
		val count = jdbcTemplate.queryForObject(sql, Integer)
		if (count == 4) {
			metaData.hasRefreshParamStates = true
		} else {
			metaData.hasRefreshParamStates = false
		}
	}

	@Loggable
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
		val metaDatas = jdbcTemplate.query(sql, new BeanPropertyRowMapper<DatabaseGeneratorMetaData>(DatabaseGeneratorMetaData))
		val dbgens = new ArrayList<DatabaseGenerator>()
		for (metaData : metaDatas) {
			metaData.setName
			metaData.setDescription
			metaData.setHasRefreshLovs
			metaData.setHasRefreshParamStates
			val dbgen = new DatabaseGenerator(metaData)
			dbgens.add(dbgen)
		}
		return dbgens
	}

	def String generate(DatabaseGeneratorMetaData metaData, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		depth++
		val plsql = '''
			DECLARE
			   «IF params != null && params.size > 0»
			   	l_params «metaData.generatorOwner».«metaData.generatorName».t_param;
			   «ENDIF»
			   l_clob   CLOB;
			BEGIN
			   «IF params != null && params.size > 0»
			   	«FOR key : params.keySet»
			   		l_params('«key»') := '«params.get(key)»';
			   	«ENDFOR»
			   «ENDIF»
			   l_clob := «metaData.generatorOwner».«metaData.generatorName».generate(
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
				result = generate(metaData, objectType, objectName,
					params)
			} else {
				result = '''Failed to generate code for «objectType».«objectName» via «metaData.generatorOwner».«metaData.generatorName». Got the following error: «e.cause?.message»'''
				Logger.error(this, plsql + result)
			}
		} finally {
			depth--
		}
		return result
	}

}
