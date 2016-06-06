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
		var Document doc
		if (metaData.hasGetObjectTypes) {
			doc = plsql.doc
		}
		if (doc != null) {
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val type = value.textContent
				objectTypes.add(type)
			}
		}
		if (objectTypes.size == 0) {
			objectTypes.add("TABLE")
			objectTypes.add("VIEW")
		}
		return objectTypes
	}

	def private List<String> getOrderedParams(DatabaseGeneratorMetaData metaData, String objectType,
		String objectName) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_ordered_params «metaData.generatorOwner».«metaData.generatorName».t_string;
			   l_clob           CLOB;
			BEGIN
			   «IF metaData.hasGetOrderedParams2»
			   	l_ordered_params := «metaData.generatorOwner».«metaData.generatorName».get_ordered_params(in_object_type => '«objectType»', in_object_name => '«objectName»');
			   «ELSE»
			   	l_ordered_params := «metaData.generatorOwner».«metaData.generatorName».get_ordered_params();
			   «ENDIF»
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
		var Document doc
		if (metaData.hasGetOrderedParams2 || metaData.hasGetOrderedParams1) {
			doc = plsql.doc
		}
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

	def getParams(DatabaseGeneratorMetaData metaData, String objectType, String objectName) {
		// initialize Parameters in the requested order
		val params = new LinkedHashMap<String, String>()
		for (param : getOrderedParams(metaData, objectType, objectName)) {
			params.put(param, "")
		}
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_params «metaData.generatorOwner».«metaData.generatorName».t_param;
			   l_key    «metaData.generatorOwner».«metaData.generatorName».param_type;
			   l_clob   CLOB;
			BEGIN
			   «IF metaData.hasGetParams2»
			      l_params := «metaData.generatorOwner».«metaData.generatorName».get_params(in_object_type => '«objectType»', in_object_name => '«objectName»');
			   «ELSE»
			      l_params := «metaData.generatorOwner».«metaData.generatorName».get_params();
			   «ENDIF»
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
		var Document doc
		if (metaData.hasGetParams2 || metaData.hasGetParams1) {
			doc = plsql.doc
		}
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

	def getLovs(DatabaseGeneratorMetaData metaData, String objectType, String objectName, LinkedHashMap<String, String> params) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   «IF metaData.hasGetLov2 || metaData.hasRefreshLov»
			      l_params «metaData.generatorOwner».« metaData.generatorName».t_param;
			   «ENDIF»
			   l_lovs «metaData.generatorOwner».«metaData.generatorName».t_lov;
			   l_key  «metaData.generatorOwner».«metaData.generatorName».param_type;
			   l_lov  «metaData.generatorOwner».«metaData.generatorName».t_string;
			   l_clob CLOB;
			BEGIN
			   «IF params != null && (metaData.hasGetLov2 || metaData.hasRefreshLov)»
			      «FOR key : params.keySet»
			         l_params('«key»') := '«params.get(key)»';
			   	  «ENDFOR»
			   «ENDIF»
			   «IF metaData.hasGetLov2»
			      l_lovs := «metaData.generatorOwner».«metaData.generatorName».get_lov(in_object_type => '«objectType»', in_object_name => '«objectName»', in_params => l_params);
			   «ELSEIF metaData.hasRefreshLov»
			      l_lovs := «metaData.generatorOwner».«metaData.generatorName».refresh_lov(in_object_type => '«objectType»', in_object_name => '«objectName»', in_params => l_params);
			   «ELSEIF metaData.hasGetLov1»
			      l_lovs := «metaData.generatorOwner».«metaData.generatorName».get_lov();
			   «ENDIF»
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
		var Document doc
		if (metaData.hasGetLov2 || metaData.hasRefreshLov || metaData.hasGetLov1) {
			doc = plsql.doc
		}
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

	@Loggable
	def findAll() {
		// uses Oracle dictionary structure as of 9.2.0.8
		val plsql = '''
			DECLARE
			   CURSOR c_metadata IS
			      WITH 
			         gen_base AS (
			            SELECT owner,
			                   package_name,
			                   object_name AS procedure_name,
			                   overload,
			                   COUNT(*) AS arg_count
			              FROM all_arguments
			             WHERE object_name = 'GENERATE'
			                   AND data_level = 0
			                   AND
			                   (
			                   --
			                    (argument_name IS NULL AND in_out = 'OUT' AND position = 0 AND
			                    data_type = 'CLOB') OR
			                    (argument_name = 'IN_OBJECT_TYPE' AND in_out = 'IN' AND position = 1 AND
			                    data_type = 'VARCHAR2') OR
			                   --
			                    (argument_name = 'IN_OBJECT_NAME' AND in_out = 'IN' AND position = 2 AND
			                    data_type = 'VARCHAR2') OR (argument_name = 'IN_PARAMS' AND in_out = 'IN' AND
			                    position = 3 AND data_type = 'PL/SQL TABLE')
			                   --
			                   )
			             GROUP BY owner, package_name, object_name, overload),
			         gen AS (
			            SELECT owner,
			                   package_name,
			                   SUM(CASE
			                           WHEN arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_generate1,
			                   SUM(CASE
			                           WHEN arg_count = 3 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_generate2
			              FROM gen_base
			             GROUP BY owner, package_name
			         ),
			         oth_base AS (
			            SELECT gen.owner,
			                   gen.package_name,
			                   arg.object_name AS procedure_name,
			                   arg.overload,
			                   COUNT(*) AS arg_count
			              FROM all_arguments arg
			              JOIN gen
			                ON arg.owner = gen.owner
			                   AND arg.package_name = gen.package_name
			             WHERE data_level = 0
			                   AND (
			                   --
			                    (arg.object_name = 'GET_NAME' AND arg.position = 0 AND
			                    data_type = 'VARCHAR2') OR
			                   --
			                    (arg.object_name = 'GET_DESCRIPTION' AND arg.position = 0 AND
			                    data_type = 'VARCHAR2') OR
			                   --
			                    (arg.object_name = 'GET_OBJECT_TYPES' AND arg.position = 0 AND
			                    data_type = 'TABLE') OR
			                   --
			                    (arg.object_name = 'GET_OBJECT_NAMES' AND arg.position = 0 AND
			                    argument_name IS NULL AND in_out = 'OUT' AND data_type = 'TABLE') OR
			                    (arg.object_name = 'GET_OBJECT_NAMES' AND arg.position = 1 AND
			                    argument_name = 'IN_OBJECT_TYPE' AND in_out = 'IN' AND
			                    data_type = 'VARCHAR2') OR
			                   --
			                    (arg.object_name = 'GET_PARAMS' AND arg.position = 0 AND
			                    argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'PL/SQL TABLE') OR
			                    (arg.object_name = 'GET_PARAMS' AND arg.position = 1 AND
			                    argument_name = 'IN_OBJECT_TYPE' AND in_out = 'IN' AND
			                    data_type = 'VARCHAR2') OR
			                    (arg.object_name = 'GET_PARAMS' AND arg.position = 2 AND
			                    argument_name = 'IN_OBJECT_NAME' AND in_out = 'IN' AND
			                    data_type = 'VARCHAR2') OR
			                   --
			                    (arg.object_name = 'GET_ORDERED_PARAMS' AND arg.position = 0 AND
			                    argument_name IS NULL AND in_out = 'OUT' AND data_type = 'TABLE') OR
			                    (arg.object_name = 'GET_ORDERED_PARAMS' AND arg.position = 1 AND
			                    argument_name = 'IN_OBJECT_TYPE' AND in_out = 'IN' AND
			                    data_type = 'VARCHAR2') OR
			                    (arg.object_name = 'GET_ORDERED_PARAMS' AND arg.position = 2 AND
			                    argument_name = 'IN_OBJECT_NAME' AND in_out = 'IN' AND
			                    data_type = 'VARCHAR2') OR
			                   --
			                    (arg.object_name IN ('GET_LOV', 'REFRESH_LOV') AND
			                    arg.position = 0 AND argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'PL/SQL TABLE') OR
			                    (arg.object_name IN ('GET_LOV', 'REFRESH_LOV') AND
			                    arg.position = 1 AND argument_name = 'IN_OBJECT_TYPE' AND
			                    in_out = 'IN' AND data_type = 'VARCHAR2') OR
			                    (arg.object_name IN ('GET_LOV', 'REFRESH_LOV') AND
			                    arg.position = 2 AND argument_name = 'IN_OBJECT_NAME' AND
			                    in_out = 'IN' AND data_type = 'VARCHAR2') OR
			                    (arg.object_name IN ('GET_LOV', 'REFRESH_LOV') AND
			                    arg.position = 3 AND argument_name = 'IN_PARAMS' AND
			                    in_out = 'IN' AND data_type = 'PL/SQL TABLE') OR
			                   --
			                    (arg.object_name IN ('GET_PARAM_STATES', 'REFRESH_PARAM_STATES') AND
			                    arg.position = 0 AND argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'PL/SQL TABLE') OR
			                    (arg.object_name IN ('GET_PARAM_STATES', 'REFRESH_PARAM_STATES') AND
			                    arg.position = 1 AND argument_name = 'IN_OBJECT_TYPE' AND
			                    in_out = 'IN' AND data_type = 'VARCHAR2') OR
			                    (arg.object_name IN ('GET_PARAM_STATES', 'REFRESH_PARAM_STATES') AND
			                    arg.position = 2 AND argument_name = 'IN_OBJECT_NAME' AND
			                    in_out = 'IN' AND data_type = 'VARCHAR2') OR
			                    (arg.object_name IN ('GET_PARAM_STATES', 'REFRESH_PARAM_STATES') AND
			                    arg.position = 3 AND argument_name = 'IN_PARAMS' AND
			                    in_out = 'IN' AND data_type = 'PL/SQL TABLE')
			                   --
			                   )
			             GROUP BY gen.owner, gen.package_name, arg.object_name, arg.overload
			         ),
			         oth AS (
			            SELECT owner,
			                   package_name,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_NAME' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_name,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_DESCRIPTION' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_description,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_OBJECT_TYPES' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_object_types,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_OBJECT_NAMES' AND arg_count = 2 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_object_names,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_PARAMS' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_params1,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_PARAMS' AND arg_count = 3 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_params2,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_ORDERED_PARAMS' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_ordered_params1,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_ORDERED_PARAMS' AND arg_count = 3 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_ordered_params2,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_LOV' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_lov1,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_LOV' AND arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_lov2,
			                   SUM(CASE
			                           WHEN procedure_name = 'REFRESH_LOV' AND arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_refresh_lov,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_PARAM_STATES' AND arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_param_states,
			                   SUM(CASE
			                           WHEN procedure_name = 'REFRESH_PARAM_STATES' AND arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_refresh_param_states
			              FROM oth_base
			             GROUP BY owner, package_name
			         ),
			         tot AS ( 
			            SELECT gen.owner,
			                   gen.package_name,
			                   gen.has_generate1,
			                   gen.has_generate2,
			                   nvl(oth.has_get_name, 0) AS has_get_name,
			                   nvl(oth.has_get_description, 0) AS has_get_description,
			                   nvl(oth.has_get_object_types, 0) AS has_get_object_types,
			                   nvl(oth.has_get_object_names, 0) AS has_get_object_names,
			                   nvl(oth.has_get_params1, 0) AS has_get_params1, -- v0.1.0 deprecated
			                   nvl(oth.has_get_params2, 0) AS has_get_params2,
			                   nvl(oth.has_get_ordered_params1, 0) AS has_get_ordered_params1, -- v.0.2.0 undocumented
			                   nvl(oth.has_get_ordered_params2, 0) AS has_get_ordered_params2,
			                   nvl(oth.has_get_lov1, 0) AS has_get_lov1, -- v0.1.0 deprecated
			                   nvl(oth.has_get_lov2, 0) AS has_get_lov2,
			                   nvl(oth.has_refresh_lov, 0) AS has_refresh_lov, -- v0.1.0 deprecated
			                   nvl(oth.has_get_param_states, 0) AS has_get_param_states,
			                   nvl(oth.has_refresh_param_states, 0) AS has_refresh_param_states -- v0.2.0 undocumented
			              FROM gen
			              LEFT JOIN oth
			                ON gen.owner = oth.owner
			                   AND gen.package_name = oth.package_name
			         )
			      -- main
			      SELECT owner,
			             package_name,
			             has_generate1,
			             has_generate2,
			             has_get_name,
			             has_get_description,
			             has_get_object_types,
			             has_get_object_names,
			             has_get_params1,
			             has_get_params2,
			             has_get_ordered_params1,
			             has_get_ordered_params2,
			             has_get_lov1,
			             has_get_lov2,
			             has_refresh_lov,
			             has_get_param_states,
			             has_refresh_param_states
			        FROM tot;
			   --
			   SUBTYPE string_type IS VARCHAR2(8192 CHAR);
			   l_name        string_type;
			   l_description string_type;
			   l_result      CLOB;
			   --
			   FUNCTION get_default_name(in_owner IN VARCHAR2, in_package_name IN VARCHAR2)
			      RETURN VARCHAR2 IS
			   BEGIN
			      RETURN in_owner || '.' || in_package_name;
			   END get_default_name;
			   --
			   FUNCTION get_name(in_owner        IN VARCHAR2,
			                     in_package_name IN VARCHAR2,
			                     in_has_get_name IN INTEGER) RETURN VARCHAR2 IS
			      l_name string_type;
			   BEGIN
			      IF in_has_get_name = 0 THEN
			         RETURN get_default_name(in_owner        => in_owner,
			                                 in_package_name => in_package_name);
			      ELSE
			         EXECUTE IMMEDIATE 'BEGIN :l_name := ' || in_owner || '.' || in_package_name ||
			                           '.get_name; END;'
			            USING OUT l_name;
			         RETURN l_name;
			      END IF;
			   END get_name;
			   --
			   FUNCTION get_description(in_owner               IN VARCHAR2,
			                            in_package_name        IN VARCHAR2,
			                            in_has_get_description IN INTEGER) RETURN VARCHAR2 IS
			      l_description string_type;
			   BEGIN
			      IF in_has_get_description = 0 THEN
			         RETURN get_default_name(in_owner        => in_owner,
			                                 in_package_name => in_package_name);
			      ELSE
			         EXECUTE IMMEDIATE 'BEGIN :l_description := ' || in_owner || '.' ||
			                           in_package_name || '.get_description; END;'
			            USING OUT l_description;
			         RETURN l_description;
			      END IF;
			   END get_description;
			   --
			   PROCEDURE add_node(in_node IN VARCHAR2, in_value IN VARCHAR2) IS
			   BEGIN
			      sys.dbms_lob.append(l_result,
			                          '<' || in_node || '>' || in_value || '</' || in_node || '>');
			   END add_node;
			BEGIN
			   sys.dbms_lob.createtemporary(l_result, TRUE);
			   <<detected_db_generators>>
			   sys.dbms_lob.append(l_result, '<result>');
			   FOR r_metadata IN c_metadata
			   LOOP
			      l_name        := get_name(in_owner        => r_metadata.owner,
			                                in_package_name => r_metadata.package_name,
			                                in_has_get_name => r_metadata.has_get_name);
			      l_description := get_description(in_owner               => r_metadata.owner,
			                                       in_package_name        => r_metadata.package_name,
			                                       in_has_get_description => r_metadata.has_get_description);
			      sys.dbms_lob.append(l_result, '<generator>');
			      add_node(in_node => 'owner', in_value => r_metadata.owner);
			      add_node(in_node => 'packageName', in_value => r_metadata.package_name);
			      add_node(in_node => 'name', in_value => l_name);
			      add_node(in_node => 'description', in_value => l_description);
			      add_node(in_node => 'hasGenerate1', in_value => r_metadata.has_generate1);
			      add_node(in_node => 'hasGenerate2', in_value => r_metadata.has_generate2);
			      add_node(in_node => 'hasGetName', in_value => r_metadata.has_get_name);
			      add_node(in_node => 'hasGetDescription', in_value => r_metadata.has_get_description);
			      add_node(in_node => 'hasGetObjectTypes', in_value => r_metadata.has_get_object_types);
			      add_node(in_node => 'hasGetObjectNames', in_value => r_metadata.has_get_object_names);
			      add_node(in_node => 'hasGetParams1', in_value => r_metadata.has_get_params1);
			      add_node(in_node => 'hasGetParams2', in_value => r_metadata.has_get_params2);
			      add_node(in_node => 'hasGetOrderedParams1', in_value => r_metadata.has_get_ordered_params1);
			      add_node(in_node => 'hasGetOrderedParams2', in_value => r_metadata.has_get_ordered_params2);
			      add_node(in_node => 'hasGetLov1', in_value => r_metadata.has_get_lov1);
			      add_node(in_node => 'hasGetLov2', in_value => r_metadata.has_get_lov2);
			      add_node(in_node => 'hasRefreshLov', in_value => r_metadata.has_refresh_lov);
			      add_node(in_node => 'hasGetParamStates', in_value => r_metadata.has_get_param_states);
			      add_node(in_node => 'hasRefreshParamStates', in_value => r_metadata.has_refresh_param_states);
			      sys.dbms_lob.append(l_result, '</generator>');
			   END LOOP detected_db_generators;
			   sys.dbms_lob.append(l_result, '</result>');
			   ? := l_result;
			END;
		'''
		val doc = plsql.doc
		val dbgens = new ArrayList<DatabaseGenerator>()
		if (doc != null) {
			val xmlGenerators = doc.getElementsByTagName("generator")
			for (var i = 0; i < xmlGenerators.length; i++) {
				val metaData = new DatabaseGeneratorMetaData
				val xmlGenerator = xmlGenerators.item(i) as Element
				metaData.generatorOwner = xmlGenerator.getElementsByTagName("owner").item(0).textContent
				metaData.generatorName = xmlGenerator.getElementsByTagName("packageName").item(0).textContent
				metaData.name = xmlGenerator.getElementsByTagName("name").item(0).textContent
				metaData.description = xmlGenerator.getElementsByTagName("description").item(0).textContent
				metaData.hasGenerate1 = xmlGenerator.getElementsByTagName("hasGenerate1").item(0).textContent == "1"
				metaData.hasGenerate2 = xmlGenerator.getElementsByTagName("hasGenerate2").item(0).textContent == "1"
				metaData.hasGetName = xmlGenerator.getElementsByTagName("hasGetName").item(0).textContent == "1"
				metaData.hasGetDescription = xmlGenerator.getElementsByTagName("hasGetDescription").item(0).
					textContent == "1"
				metaData.hasGetObjectTypes = xmlGenerator.getElementsByTagName("hasGetObjectTypes").item(0).
					textContent == "1"
				metaData.hasGetObjectNames = xmlGenerator.getElementsByTagName("hasGetObjectNames").item(0).
					textContent == "1"
				metaData.hasGetParams1 = xmlGenerator.getElementsByTagName("hasGetParams1").item(0).textContent == "1"
				metaData.hasGetParams2 = xmlGenerator.getElementsByTagName("hasGetParams2").item(0).textContent == "1"
				metaData.hasGetOrderedParams1 = xmlGenerator.getElementsByTagName("hasGetOrderedParams1").item(0).
					textContent == "1"
				metaData.hasGetOrderedParams2 = xmlGenerator.getElementsByTagName("hasGetOrderedParams2").item(0).
					textContent == "1"
				metaData.hasGetLov1 = xmlGenerator.getElementsByTagName("hasGetLov1").item(0).textContent == "1"
				metaData.hasGetLov2 = xmlGenerator.getElementsByTagName("hasGetLov2").item(0).textContent == "1"
				metaData.hasRefreshLov = xmlGenerator.getElementsByTagName("hasRefreshLov").item(0).textContent == "1"
				metaData.hasGetParamStates = xmlGenerator.getElementsByTagName("hasGetParamStates").item(0).
					textContent == "1"
				metaData.hasRefreshParamStates = xmlGenerator.getElementsByTagName("hasRefreshParamStates").item(0).
					textContent == "1"
				val dbgen = new DatabaseGenerator(metaData)
				dbgens.add(dbgen)
			}
		}
		return dbgens
	}

	def String generate(DatabaseGeneratorMetaData metaData, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		depth++
		val plsql = '''
			DECLARE
			   «IF metaData.hasGenerate1»
			      l_params «metaData.generatorOwner».«metaData.generatorName».t_param;
			   «ENDIF»
			   l_clob   CLOB;
			BEGIN
			   «IF metaData.hasGenerate1»
			      «FOR key : params.keySet»
			         l_params('«key»') := '«params.get(key)»';
			      «ENDFOR»
			   «ENDIF»
			   l_clob := «metaData.generatorOwner».«metaData.generatorName».generate(
			                  in_object_type => '«objectType»'
			                , in_object_name => '«objectName»'
			                «IF metaData.hasGenerate1»
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
