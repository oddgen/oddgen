/*
 * Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
import java.sql.Clob
import java.sql.Connection
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import oracle.ide.config.Preferences
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.generators.DatabaseGenerator
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.generators.model.NodeTools
import org.oddgen.sqldev.model.DatabaseGeneratorMetaData
import org.oddgen.sqldev.model.PreferenceModel
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Document
import org.w3c.dom.Element

@Loggable(LoggableConstants.DEBUG)
class DatabaseGeneratorDao {
	var Connection conn
	var JdbcTemplate jdbcTemplate
	var extension DalTools dalTools
	val extension NodeTools nodeTools = new NodeTools
	
	private def CharSequence typesOwnerPrefix(DatabaseGeneratorMetaData metaData) {
		return '''«IF metaData.typesOwner !== null && metaData.typesOwner != "PUBLIC"»«metaData.typesOwner».«ENDIF»'''
	}
	
	private def addTextVariables() '''
	   l_buffer      VARCHAR2(32767); 
	   co_max_buffer CONSTANT INTEGER := 32767;
	'''
	
	private def addTextProcedures(String clobName) '''
	   PROCEDURE flush_buffer IS
	   BEGIN
	      sys.dbms_lob.append(«clobName», l_buffer);
	      l_buffer := NULL;
	   END flush_buffer;
	   --
	   PROCEDURE add_text (in_text IN varchar2) IS
	      l_text_len   INTEGER;
	      l_buffer_len INTEGER;
	   BEGIN
	      l_text_len   := length(in_text);
	      l_buffer_len := length(l_buffer);
	      IF l_text_len > co_max_buffer THEN
	         flush_buffer;
	         sys.dbms_lob.append(«clobName», in_text);
	      ELSIF l_text_len + l_buffer_len > co_max_buffer THEN
	         flush_buffer;
	         l_buffer := in_text;
	      ELSE
	         l_buffer := l_buffer || in_text;
	      END IF;
	   END add_text;
	'''

	private def List<String> getOrderedParams(DatabaseGeneratorMetaData metaData, String objectType, String objectName) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_ordered_params «metaData.generatorOwner».«metaData.generatorName».t_string;
			   l_clob           CLOB;
			   «addTextVariables»
			   --
			   «addTextProcedures("l_clob")»
			BEGIN
			   sys.dbms_lob.createtemporary(l_clob, TRUE);
			   «IF metaData.hasGetOrderedParams2»
			      l_ordered_params := «metaData.generatorOwner».«metaData.generatorName».get_ordered_params(in_object_type => '«objectType»', in_object_name => '«objectName»');
			   «ELSE»
			      l_ordered_params := «metaData.generatorOwner».«metaData.generatorName».get_ordered_params();
			   «ENDIF»
			   add_text('<values>');
			   FOR i IN 1 .. l_ordered_params.count
			   LOOP
			      add_text('<value><![CDATA[' || l_ordered_params(i) || ']]></value>');
			   END LOOP;
			   add_text('</values>');
			   flush_buffer;
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		val orderedParams = new ArrayList<String>()
		var Document doc
		if (metaData.hasGetOrderedParams2 || metaData.hasGetOrderedParams1) {
			doc = plsql.doc
		}
		if (doc !== null) {
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val type = value.textContent
				orderedParams.add(type)
			}
		}
		return orderedParams
	}

	private def getParams(DatabaseGeneratorMetaData metaData, String objectType, String objectName) {
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
			   «addTextVariables»
			   --
			   «addTextProcedures("l_clob")»
			BEGIN
			   sys.dbms_lob.createtemporary(l_clob, TRUE);
			   «IF metaData.hasGetParams2»
			      l_params := «metaData.generatorOwner».«metaData.generatorName».get_params(in_object_type => '«objectType»', in_object_name => '«objectName»');
			   «ELSE»
			      l_params := «metaData.generatorOwner».«metaData.generatorName».get_params();
			   «ENDIF»
			   l_key    := l_params.first;
			   add_text('<params>');
			   WHILE l_key IS NOT NULL
			   LOOP
			      add_text('<param><key><![CDATA[' || l_key || ']]></key><value><![CDATA[' || l_params(l_key) || ']]></value></param>');
			      l_params.delete(l_key);
			      l_key := l_params.first;
			   END LOOP;
			   add_text('</params>');
			   flush_buffer;
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		var Document doc
		if (metaData.hasGetParams2 || metaData.hasGetParams1) {
			doc = plsql.doc
		}
		if (doc !== null) {
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

	new(Connection conn) {
		this.conn = conn
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		this.dalTools = new DalTools(conn)
	}

	@Loggable
	def findAll() {
		// uses Oracle dictionary structure as of 9.2.0.8
		val plsql = '''
			DECLARE
			   CURSOR c_metadata IS
			      WITH 
			         gen_root AS (
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
			                    position = 3 AND data_type = 'PL/SQL TABLE') OR
			                   --
			                    (argument_name = 'IN_NODE' AND in_out = 'IN' AND position = 1 AND
			                    data_type = 'PL/SQL RECORD')
			                   --
			                   )
			             GROUP BY owner, package_name, object_name, overload),
			         gen_base AS (
			            SELECT gen_root.owner,
			                   gen_root.package_name,
			                   MIN(
			                      CASE 
			                         WHEN a.type_name = 'ODDGEN_TYPES' THEN 
			                            a.type_owner 
			                         ELSE 
			                            NULL
			                      END
			                   ) AS types_owner,
			                   gen_root.procedure_name,
			                   gen_root.arg_count
			              FROM gen_root
			              JOIN all_arguments a
			                ON a.owner = gen_root.owner
			                   AND a.package_name = gen_root.package_name
			             GROUP BY gen_root.owner, gen_root.package_name, gen_root.procedure_name, gen_root.arg_count),
			         gen AS (
			            SELECT owner,
			                   package_name,
			                   types_owner,
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
			                        END) AS has_generate2,
			                   SUM(CASE
			                           WHEN arg_count = 2 THEN
			                            1
			                            ELSE
			                            0
			                       END) AS has_generate3
			              FROM gen_base
			             GROUP BY owner, package_name, types_owner
			         ),
			         oth_base AS (
			            SELECT gen.owner,
			                   gen.package_name,
			                   gen.types_owner,
			                   arg.object_name AS procedure_name,
			                   arg.overload,
			                   COUNT(*) AS arg_count,
			                   SUM(CASE 
			                        WHEN argument_name = 'IN_PARAMS' THEN
			                         1
			                        ELSE
			                         0
			                    END) AS has_in_params_arg
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
			                    (arg.object_name = 'GET_FOLDERS' AND arg.position = 0 AND
			                    data_type = 'TABLE') OR
			                   --
			                    (arg.object_name = 'GET_HELP' AND arg.position = 0 AND
			                    data_type = 'CLOB') OR
			                   --
			                    (arg.object_name = 'GET_NODES' AND arg.position = 0 AND
			                    data_type = 'TABLE') OR
			                    (arg.object_name = 'GET_NODES' AND arg.position = 1 AND
			                    argument_name = 'IN_PARENT_NODE_ID' AND in_out = 'IN' AND
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
			                    (arg.object_name = 'GET_LOV' AND
			                    arg.position = 0 AND argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'PL/SQL TABLE') OR
			                    (arg.object_name = 'GET_LOV' AND
			                    arg.position = 1 AND argument_name = 'IN_PARAMS' AND
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
			                    in_out = 'IN' AND data_type = 'PL/SQL TABLE') OR
			                   --
			                    (arg.object_name = 'GET_PARAM_STATES' AND
			                    arg.position = 0 AND argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'PL/SQL TABLE') OR
			                    (arg.object_name = 'GET_PARAM_STATES' AND
			                    arg.position = 1 AND argument_name = 'IN_PARAMS' AND
			                    in_out = 'IN' AND data_type = 'PL/SQL TABLE') OR
			                   --
			                    (arg.object_name = 'GENERATE_PROLOG' AND
			                    arg.position = 0 AND argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'CLOB') OR
			                    (arg.object_name = 'GENERATE_PROLOG' AND
			                    arg.position = 1 AND argument_name = 'IN_NODES' AND
			                    in_out = 'IN' AND data_type = 'TABLE') OR
			                   --
			                    (arg.object_name = 'GENERATE_SEPARATOR' AND
			                    arg.position = 0 AND argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'VARCHAR2') OR
			                   --
			                    (arg.object_name = 'GENERATE_EPILOG' AND
			                    arg.position = 0 AND argument_name IS NULL AND in_out = 'OUT' AND
			                    data_type = 'CLOB') OR
			                    (arg.object_name = 'GENERATE_EPILOG' AND
			                    arg.position = 1 AND argument_name = 'IN_NODES' AND
			                    in_out = 'IN' AND data_type = 'TABLE')
			                   --
			                   )
			             GROUP BY gen.owner, gen.package_name, gen.types_owner, arg.object_name, arg.overload
			         ),
			         oth AS (
			            SELECT owner,
			                   package_name,
			                   types_owner,
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
			                           WHEN procedure_name = 'GET_FOLDERS' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_folders,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_HELP' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_help,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_NODES' AND arg_count = 2 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_nodes,
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
			                           WHEN procedure_name = 'GET_LOV' AND arg_count = 1 AND has_in_params_arg = 0 THEN
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
			                           WHEN procedure_name = 'GET_LOV' AND arg_count = 2 AND has_in_params_arg = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_lov3,
			                   SUM(CASE
			                           WHEN procedure_name = 'REFRESH_LOV' AND arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_refresh_lov,
			                   SUM(CASE
			                           WHEN procedure_name = 'REFRESH_PARAM_STATES' AND arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_refresh_param_states,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_PARAM_STATES' AND arg_count = 4 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_param_states1,
			                   SUM(CASE
			                           WHEN procedure_name = 'GET_PARAM_STATES' AND arg_count = 2 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_get_param_states2,
			                   SUM(CASE
			                           WHEN procedure_name = 'GENERATE_PROLOG' AND arg_count = 2 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_generate_prolog,
			                   SUM(CASE
			                           WHEN procedure_name = 'GENERATE_SEPARATOR' AND arg_count = 1 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_generate_separator,
			                   SUM(CASE
			                           WHEN procedure_name = 'GENERATE_EPILOG' AND arg_count = 2 THEN
			                            1
			                           ELSE
			                            0
			                        END) AS has_generate_epilog
			              FROM oth_base
			             GROUP BY owner, package_name, types_owner
			         ),
			         tot AS ( 
			            SELECT gen.owner,
			                   gen.package_name,
			                   gen.types_owner,
			                   gen.has_generate1, -- v0.1.0 deprecated
			                   gen.has_generate2, -- v0.2.0 deprecated
			                   gen.has_generate3, -- v0.3.0 current
			                   nvl(oth.has_get_name, 0) AS has_get_name, -- v0.1.0 current
			                   nvl(oth.has_get_description, 0) AS has_get_description, -- v0.1.0 current
			                   nvl(oth.has_get_folders, 0) AS has_get_folders, -- v0.3.0 current
			                   nvl(oth.has_get_help, 0) AS has_get_help, -- v0.3.0 current
			                   nvl(oth.has_get_nodes, 0) AS has_get_nodes, -- v0.3.0 current
			                   nvl(oth.has_get_object_types, 0) AS has_get_object_types, -- v0.1.0 depreated
			                   nvl(oth.has_get_object_names, 0) AS has_get_object_names, -- v0.1.0 deprecated
			                   nvl(oth.has_get_params1, 0) AS has_get_params1, -- v0.1.0 deprecated
			                   nvl(oth.has_get_params2, 0) AS has_get_params2, -- v0.2.0 deprecated
			                   nvl(oth.has_get_ordered_params1, 0) AS has_get_ordered_params1, -- v0.2.0 undocumented, v0.3.0 current
			                   nvl(oth.has_get_ordered_params2, 0) AS has_get_ordered_params2, -- v0.2.0 deprecated
			                   nvl(oth.has_get_lov1, 0) AS has_get_lov1, -- v0.1.0 deprecated
			                   nvl(oth.has_get_lov2, 0) AS has_get_lov2, -- v0.2.0 deprecated
			                   nvl(oth.has_get_lov3, 0) AS has_get_lov3, -- v0.3.0 current
			                   nvl(oth.has_refresh_lov, 0) AS has_refresh_lov, -- v0.1.0 deprecated
			                   nvl(oth.has_refresh_param_states, 0) AS has_refresh_param_states, -- v0.2.0 undocumented, deprecated
			                   nvl(oth.has_get_param_states1, 0) AS has_get_param_states1, -- v0.2.0 deprecated
			                   nvl(oth.has_get_param_states2, 0) AS has_get_param_states2, -- v0.3.0 current
			                   nvl(oth.has_generate_prolog, 0) AS has_generate_prolog, -- v0.3.0 current
			                   nvl(oth.has_generate_separator, 0) AS has_generate_separator, -- v0.3.0 current
			                   nvl(oth.has_generate_epilog, 0) AS has_generate_epilog -- v0.3.0 current
			              FROM gen
			              LEFT JOIN oth
			                ON gen.owner = oth.owner
			                   AND gen.package_name = oth.package_name
			         )
			      -- main
			      SELECT owner,
			             package_name,
			             types_owner,
			             has_generate1,
			             has_generate2,
			             has_generate3,
			             has_get_name,
			             has_get_description,
			             has_get_folders,
			             has_get_help,
			             has_get_nodes,
			             has_get_object_types,
			             has_get_object_names,
			             has_get_params1,
			             has_get_params2,
			             has_get_ordered_params1,
			             has_get_ordered_params2,
			             has_get_lov1,
			             has_get_lov2,
			             has_get_lov3,
			             has_refresh_lov,
			             has_refresh_param_states,
			             has_get_param_states1,
			             has_get_param_states2,
			             has_generate_prolog,
			             has_generate_separator,
			             has_generate_epilog
			        FROM tot;
			   --
			   SUBTYPE string_type IS VARCHAR2(8192 CHAR);
			   l_name        string_type;
			   l_description string_type;
			   l_result      CLOB;
			   «addTextVariables»
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
			         <<trap>>
			         BEGIN
			            EXECUTE IMMEDIATE 'BEGIN :l_name := ' || in_owner || '.' || in_package_name ||
			                              '.get_name; END;'
			               USING OUT l_name;
			            RETURN l_name;
			         EXCEPTION
			            WHEN OTHERS THEN
			               -- ignore error (issue #41), just return default name
			               RETURN get_default_name(in_owner        => in_owner,
			               			               in_package_name => in_package_name);
			         END trap;
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
			         <<trap>>
			         BEGIN
			            EXECUTE IMMEDIATE 'BEGIN :l_description := ' || in_owner || '.' ||
			                              in_package_name || '.get_description; END;'
			               USING OUT l_description;
			            RETURN l_description;
			         EXCEPTION
			            WHEN OTHERS THEN
			               -- ignore error (issue #41), just return default description
			               RETURN get_default_name(in_owner        => in_owner,
			                                       in_package_name => in_package_name);
			         END trap;
			      END IF;
			   END get_description;
			   --
			   «addTextProcedures("l_result")»
			   --
			   PROCEDURE add_node(in_node IN VARCHAR2, in_value IN VARCHAR2) IS
			   BEGIN
			      add_text('<' || in_node || '><![CDATA[' || in_value || ']]></' || in_node || '>');
			   END add_node;
			BEGIN
			   sys.dbms_lob.createtemporary(l_result, TRUE);
			   <<detected_db_generators>>
			   add_text('<result>');
			   FOR r_metadata IN c_metadata
			   LOOP
			      l_name        := get_name(in_owner        => r_metadata.owner,
			                                in_package_name => r_metadata.package_name,
			                                in_has_get_name => r_metadata.has_get_name);
			      l_description := get_description(in_owner               => r_metadata.owner,
			                                       in_package_name        => r_metadata.package_name,
			                                       in_has_get_description => r_metadata.has_get_description);
			      add_text('<generator>');
			      add_node(in_node => 'owner', in_value => r_metadata.owner);
			      add_node(in_node => 'packageName', in_value => r_metadata.package_name);
			      add_node(in_node => 'typesOwner', in_value => r_metadata.types_owner);
			      add_node(in_node => 'name', in_value => l_name);
			      add_node(in_node => 'description', in_value => l_description);
			      add_node(in_node => 'hasGenerate1', in_value => r_metadata.has_generate1);
			      add_node(in_node => 'hasGenerate2', in_value => r_metadata.has_generate2);
			      add_node(in_node => 'hasGenerate3', in_value => r_metadata.has_generate3);
			      add_node(in_node => 'hasGetName', in_value => r_metadata.has_get_name);
			      add_node(in_node => 'hasGetDescription', in_value => r_metadata.has_get_description);
			      add_node(in_node => 'hasGetFolders', in_value => r_metadata.has_get_folders);
			      add_node(in_node => 'hasGetHelp', in_value => r_metadata.has_get_help);
			      add_node(in_node => 'hasGetNodes', in_value => r_metadata.has_get_nodes);
			      add_node(in_node => 'hasGetObjectTypes', in_value => r_metadata.has_get_object_types);
			      add_node(in_node => 'hasGetObjectNames', in_value => r_metadata.has_get_object_names);
			      add_node(in_node => 'hasGetParams1', in_value => r_metadata.has_get_params1);
			      add_node(in_node => 'hasGetParams2', in_value => r_metadata.has_get_params2);
			      add_node(in_node => 'hasGetOrderedParams1', in_value => r_metadata.has_get_ordered_params1);
			      add_node(in_node => 'hasGetOrderedParams2', in_value => r_metadata.has_get_ordered_params2);
			      add_node(in_node => 'hasGetLov1', in_value => r_metadata.has_get_lov1);
			      add_node(in_node => 'hasGetLov2', in_value => r_metadata.has_get_lov2);
			      add_node(in_node => 'hasGetLov3', in_value => r_metadata.has_get_lov3);
			      add_node(in_node => 'hasRefreshLov', in_value => r_metadata.has_refresh_lov);
			      add_node(in_node => 'hasRefreshParamStates', in_value => r_metadata.has_refresh_param_states);
			      add_node(in_node => 'hasGetParamStates1', in_value => r_metadata.has_get_param_states1);
			      add_node(in_node => 'hasGetParamStates2', in_value => r_metadata.has_get_param_states2);
			      add_node(in_node => 'hasGenerateProlog', in_value => r_metadata.has_generate_prolog);
			      add_node(in_node => 'hasGenerateSeparator', in_value => r_metadata.has_generate_separator);
			      add_node(in_node => 'hasGenerateEpilog', in_value => r_metadata.has_generate_epilog);
			      add_text('</generator>');
			   END LOOP detected_db_generators;
			   add_text('</result>');
			   flush_buffer;
			   ? := l_result;
			END;
		'''
		val dbgens = new ArrayList<DatabaseGenerator>()
		if (isAtLeastOracle(9,2)) {
			Logger.debug(this, "plsql: %s", plsql)
			val doc = plsql.doc
			if (doc !== null) {
				val xmlGenerators = doc.getElementsByTagName("generator")
				for (var i = 0; i < xmlGenerators.length; i++) {
					val metaData = new DatabaseGeneratorMetaData
					val xmlGenerator = xmlGenerators.item(i) as Element
					metaData.generatorOwner = xmlGenerator.getElementsByTagName("owner").item(0).textContent
					metaData.generatorName = xmlGenerator.getElementsByTagName("packageName").item(0).textContent
					metaData.typesOwner = xmlGenerator.getElementsByTagName("typesOwner").item(0).textContent
					metaData.name = xmlGenerator.getElementsByTagName("name").item(0).textContent
					metaData.description = xmlGenerator.getElementsByTagName("description").item(0).textContent
					metaData.hasGetName = xmlGenerator.getElementsByTagName("hasGetName").item(0).textContent == "1"
					metaData.hasGetDescription = xmlGenerator.getElementsByTagName("hasGetDescription").item(0).
						textContent == "1"
					metaData.hasGetFolders = xmlGenerator.getElementsByTagName("hasGetFolders").item(0).textContent == "1"
					metaData.hasGetHelp = xmlGenerator.getElementsByTagName("hasGetHelp").item(0).textContent == "1"
					metaData.hasGetNodes = xmlGenerator.getElementsByTagName("hasGetNodes").item(0).textContent == "1"
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
					metaData.hasGetLov3 = xmlGenerator.getElementsByTagName("hasGetLov3").item(0).textContent == "1"
					metaData.hasRefreshLov = xmlGenerator.getElementsByTagName("hasRefreshLov").item(0).textContent == "1"
					metaData.hasRefreshParamStates = xmlGenerator.getElementsByTagName("hasRefreshParamStates").item(0).
						textContent == "1"
					metaData.hasGetParamStates1 = xmlGenerator.getElementsByTagName("hasGetParamStates1").item(0).
						textContent == "1"
					metaData.hasGetParamStates2 = xmlGenerator.getElementsByTagName("hasGetParamStates2").item(0).
						textContent == "1"
					metaData.hasGenerateProlog = xmlGenerator.getElementsByTagName("hasGenerateProlog").item(0).
						textContent == "1"
					metaData.hasGenerateSeparator = xmlGenerator.getElementsByTagName("hasGenerateSeparator").item(0).
						textContent == "1"
					metaData.hasGenerateEpilog = xmlGenerator.getElementsByTagName("hasGenerateEpilog").item(0).
						textContent == "1"
					metaData.hasGenerate1 = xmlGenerator.getElementsByTagName("hasGenerate1").item(0).textContent == "1"
					metaData.hasGenerate2 = xmlGenerator.getElementsByTagName("hasGenerate2").item(0).textContent == "1"
					metaData.hasGenerate3 = xmlGenerator.getElementsByTagName("hasGenerate3").item(0).textContent == "1"
					val dbgen = new DatabaseGenerator(metaData)
					dbgens.add(dbgen)
				}
			}
		}
		return dbgens
	}
	
	def List<String> getFolders(DatabaseGeneratorMetaData metaData) {
		// convert PL/SQL table to XML
		val plsql = '''
			DECLARE
			   l_folders «metaData.typesOwnerPrefix»oddgen_types.t_value_type;
			   l_clob    CLOB;
			   «addTextVariables»
			   --
			   «addTextProcedures("l_clob")»
			BEGIN
			   sys.dbms_lob.createtemporary(l_clob, TRUE);
			   l_folders := «metaData.generatorOwner».«metaData.generatorName».get_folders;
			   add_text('<values>');
			   FOR i IN 1 .. l_folders.count
			   LOOP
			      add_text('<value><![CDATA[' || l_folders(i) || ']]></value>');
			   END LOOP;
			   add_text('</values>');
			   flush_buffer;
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		val folders = new ArrayList<String>
		var Document doc
		if (metaData.hasGetFolders) {
			try {
				doc = plsql.doc
			} catch (Exception e) {
				// error has been logged, ignore it and return default
			}
		}
		if (doc !== null) {
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val type = value.textContent
				folders.add(type)
			}
		} else {
			var PreferenceModel preferences
			try {
				// running in SQL Developer
				preferences = PreferenceModel.getInstance(Preferences.getPreferences());
			} catch (NoClassDefFoundError e) {
				// running in development environment (default prefrences)
				preferences = PreferenceModel.getInstance(null)
			}
			for (f : preferences.defaultDatabaseServerGeneratorFolder.split(",").filter[!it.empty]) {
				folders.add(f.trim)
			}
		}
		return folders
	}	

	def getHelp(DatabaseGeneratorMetaData metaData) {
		val plsql = '''
			DECLARE
			   l_clob CLOB;
			BEGIN
			   l_clob := «metaData.generatorOwner».«metaData.generatorName».get_help();
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		var String help = '<p>Help is not implemented for this generator.</p>';
		if (metaData.hasGetHelp) {
			try {
				help = plsql.getString
			} catch (Exception e) {
				help = '''
					<p>Got the following error when calling «metaData.generatorOwner».«metaData.generatorName».get_help():</p>
					<p>«e.message»</p>
				'''
			}
		}
		return help
	}

	def getNodes(DatabaseGeneratorMetaData metaData, String parentNodeId) {
		val plsql = '''
			«IF metaData.hasGetNodes»
				DECLARE
				   t_nodes «metaData.typesOwnerPrefix»oddgen_types.t_node_type;
				   l_key   «metaData.typesOwnerPrefix»oddgen_types.key_type;
				   l_clob CLOB;
				   «addTextVariables»
				   -- 
				   FUNCTION bool2string (in_bool BOOLEAN, in_default VARCHAR2) RETURN VARCHAR2 IS
				   BEGIN
				      IF in_bool IS NULL THEN
				         RETURN in_default;
				      ELSIF in_bool THEN
				         RETURN 'true';
				      ELSE
				         RETURN 'false';
				      END IF;
				   END bool2string;
				   --
				   «addTextProcedures("l_clob")»
				BEGIN
				   sys.dbms_lob.createtemporary(l_clob, TRUE);
				   t_nodes := «metaData.generatorOwner».«metaData.generatorName».get_nodes(in_parent_node_id => '«parentNodeId»');
				   add_text('<nodes>');
				   IF t_nodes.count > 0 THEN
				      <<nodes>>
				      FOR i IN 1..t_nodes.count LOOP
				         add_text('<node>');
				         add_text('<id>' || t_nodes(i).id || '</id>');
				         add_text('<parent_id>' || t_nodes(i).parent_id || '</parent_id>');
				         add_text('<name><![CDATA[' || t_nodes(i).name || ']]></name>');
				         add_text('<description><![CDATA[' || t_nodes(i).description || ']]></description>');
				         add_text('<icon_name>' || t_nodes(i).icon_name || '</icon_name>');
				         add_text('<icon_base64>' || t_nodes(i).icon_base64 || '</icon_base64>');
				         add_text('<params>');
				         l_key := t_nodes(i).params.first;
				         <<params>>
				         WHILE l_key IS NOT NULL LOOP
				            add_text('<param><key><![CDATA[' || l_key || ']]></key><value><![CDATA[' || t_nodes(i).params(l_key) || ']]></value></param>');
				            t_nodes(i).params.delete(l_key);
				            l_key := t_nodes(i).params.first;
				         END LOOP params;
				         add_text('</params>');
				         add_text('<leaf>' || bool2string(t_nodes(i).leaf, 'false') || '</leaf>');
				         add_text('<generatable>' || bool2string(t_nodes(i).generatable, NULL) || '</generatable>');
				         add_text('<multiselectable>' || bool2string(t_nodes(i).multiselectable, NULL) || '</multiselectable>');
				         add_text('<relevant>' || bool2string(t_nodes(i).relevant, NULL) || '</relevant>');
				         add_text('</node>');
				      END LOOP nodes;
				   END IF;
				   add_text('</nodes>');
				   flush_buffer;
				   ? := l_clob;
				END;
			«ELSE»
				«IF parentNodeId === null || parentNodeId.empty»
					«IF metaData.hasGetObjectTypes»
						DECLARE
						   l_types «metaData.generatorOwner».«metaData.generatorName».t_string;
						   l_clob CLOB;
						   «addTextVariables»
						   --
						   «addTextProcedures("l_clob")»
						BEGIN
						   l_types := «metaData.generatorOwner».«metaData.generatorName».get_object_types();
						   sys.dbms_lob.createtemporary(l_clob, TRUE);
						   add_text('<nodes>');
						   FOR i IN 1 .. l_types.count
						   LOOP
						      add_text('<node>');
						      add_text('<id>' || l_types(i) || '</id>');
						      add_text('<parent_id/>');
						      add_text('<params/>');
						      add_text('<leaf>false</leaf>');
						      add_text('</node>');
						   END LOOP;
						   add_text('</nodes>');
						   flush_buffer;
						   ? := l_clob;
						END;
					«ELSE»
						DECLARE
						   l_clob CLOB;
						   «addTextVariables»
						   --
						   «addTextProcedures("l_clob")»
						BEGIN
						   sys.dbms_lob.createtemporary(l_clob, TRUE);
						   add_text('<nodes>');
						   add_text('<node>');
						   add_text('<id>TABLE</id>');
						   add_text('<parent_id/>');
						   add_text('<params/>');
						   add_text('<leaf>false</leaf>');
						   add_text('</node>');
						   add_text('<node>');
						   add_text('<id>VIEW</id>');
						   add_text('<parent_id/>');
						   add_text('<params/>');
						   add_text('<leaf>false</leaf>');
						   add_text('</node>');
						   add_text('</nodes>');
						   flush_buffer;
						   ? := l_clob;
						END;
					«ENDIF»
				«ELSE»
					«IF metaData.hasGetObjectNames»
						DECLARE
						   l_names «metaData.generatorOwner».«metaData.generatorName».t_string;
						   l_clob   CLOB;
						   «addTextVariables»
						   --
						   «addTextProcedures("l_clob")»
						BEGIN
						   l_names := «metaData.generatorOwner».«metaData.generatorName».get_object_names(in_object_type => '«parentNodeId»');
						   sys.dbms_lob.createtemporary(l_clob, TRUE);
						   add_text('<nodes>');
						   FOR i IN 1 .. l_names.count
						   LOOP
						      add_text('<node>');
						      add_text('<id>«parentNodeId».' || l_names(i) || '</id>');
						      add_text('<parent_id>«parentNodeId»</parent_id>');
						      add_text('<params/>');
						      add_text('<leaf>true</leaf>');
						      add_text('</node>');
						   END LOOP;
						   add_text('</nodes>');
						   flush_buffer;
						   ? := l_clob;
						END;
					«ELSE»
						DECLARE
						   l_clob   CLOB;
						   «addTextVariables»
						   --
						   «addTextProcedures("l_clob")»
						BEGIN
						   sys.dbms_lob.createtemporary(l_clob, TRUE);
						   add_text('<nodes>');
						   FOR r IN (
						      SELECT object_name
						        FROM user_objects
						       WHERE object_type = '«parentNodeId»'
						         AND generated = 'N'
						       ORDER BY object_name
						   ) LOOP
						      add_text('<node>');
						      add_text('<id>«parentNodeId».' || r.object_name || '</id>');
						      add_text('<parent_id>«parentNodeId»</parent_id>');
						      add_text('<params/>');
						      add_text('<leaf>true</leaf>');
						      add_text('</node>');
						   END LOOP;
						   add_text('</nodes>');
						   flush_buffer;
						   ? := l_clob;
						END;
					«ENDIF»
				«ENDIF»
			«ENDIF»
		'''
		Logger.debug(this, "plsql: %s", plsql)
		val nodes = new ArrayList<Node>
		var doc = plsql.doc
		if (doc !== null) {
			val xmlNodes = doc.getElementsByTagName("node")
			for (var i = 0; i < xmlNodes.length; i++) {
				val node = new Node
				val xmlNode = xmlNodes.item(i) as Element
				node.id = xmlNode.getElementsByTagName("id").item(0).textContent
				node.parentId = xmlNode.getElementsByTagName("parent_id")?.item(0)?.textContent
				node.name = xmlNode.getElementsByTagName("name")?.item(0)?.textContent
				node.description = xmlNode.getElementsByTagName("description")?.item(0)?.textContent
				node.iconName = xmlNode.getElementsByTagName("icon_name")?.item(0)?.textContent
				node.iconBase64 = xmlNode.getElementsByTagName("icon_base64")?.item(0)?.textContent
				val params = new LinkedHashMap<String, String>
				val xmlParams = xmlNode.getElementsByTagName("param")
				for (var j = 0; j < xmlParams.length; j++) {
					val xmlParam = xmlParams.item(j) as Element
					val key = xmlParam.getElementsByTagName("key").item(0).textContent
					val value = xmlParam.getElementsByTagName("value").item(0).textContent
					params.put(key, value)
				}
				node.params = params
				node.leaf = xmlNode.getElementsByTagName("leaf")?.item(0)?.textContent == "true"
				val generatable = xmlNode.getElementsByTagName("generatable")?.item(0)?.textContent
				if (generatable !== null && !generatable.empty) {
					node.generatable = generatable == "true"
				}
				val multiselectable = xmlNode.getElementsByTagName("multiselectable")?.item(0)?.textContent
				if (multiselectable !== null && !multiselectable.empty) {
					node.multiselectable = multiselectable == "true"
				}
				val relevant = xmlNode.getElementsByTagName("relevant").item(0)?.textContent
				if (relevant !== null && !relevant.empty) {
					node.relevant = relevant == "true"
				}
				nodes.add(node)
			}
			if (!metaData.hasGetNodes) {
				// extend nodes with parameters
				for (node : nodes) {
					node.params = getParams(metaData, node.toObjectType, node.toObjectName)
				}
			}
		}
		return nodes
	}


	def getLov(DatabaseGeneratorMetaData metaData, LinkedHashMap<String, String> params, List<Node> nodes) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   «IF metaData.hasGetLov3»
			      l_params «metaData.typesOwnerPrefix»oddgen_types.t_param_type;
			      l_node   «metaData.typesOwnerPrefix»oddgen_types.r_node_type;
			      l_nodes  «metaData.typesOwnerPrefix»oddgen_types.t_node_type := «metaData.typesOwnerPrefix»oddgen_types.t_node_type();
			      l_lovs   «metaData.typesOwnerPrefix»oddgen_types.t_lov_type;
			      l_key    «metaData.typesOwnerPrefix»oddgen_types.value_type;
			      l_lov    «metaData.typesOwnerPrefix»oddgen_types.t_value_type;
			   «ELSE»
			      «IF metaData.hasGetLov2 || metaData.hasRefreshLov»
			          l_params «metaData.generatorOwner».« metaData.generatorName».t_param;
			      «ENDIF»
			      l_lovs «metaData.generatorOwner».«metaData.generatorName».t_lov;
			      l_key  «metaData.generatorOwner».«metaData.generatorName».param_type;
			      l_lov  «metaData.generatorOwner».«metaData.generatorName».t_string;
			   «ENDIF»
			   l_clob CLOB;
			   «addTextVariables»
			   --
			   «addTextProcedures("l_clob")»
			BEGIN
			   sys.dbms_lob.createtemporary(l_clob, TRUE);
			   «IF params !== null && (metaData.hasGetLov3 || metaData.hasGetLov2 || metaData.hasRefreshLov)»
			      «FOR key : params.keySet»
			         l_params('«key»') := '«params.get(key).escapeSingleQuotes»';
			      «ENDFOR»
			   «ENDIF»
			   «IF metaData.hasGetLov3»
			      «nodes.toPlsql»
			      l_lovs := «metaData.generatorOwner».«metaData.generatorName».get_lov(in_params => l_params, in_nodes => l_nodes);
			   «ELSEIF metaData.hasGetLov2»
			      l_lovs := «metaData.generatorOwner».«metaData.generatorName».get_lov(in_object_type => '«nodes.toObjectType»', in_object_name => '«nodes.toObjectName»', in_params => l_params);
			   «ELSEIF metaData.hasRefreshLov»
			      l_lovs := «metaData.generatorOwner».«metaData.generatorName».refresh_lov(in_object_type => '«nodes.toObjectType»', in_object_name => '«nodes.toObjectName»', in_params => l_params);
			   «ELSEIF metaData.hasGetLov1»
			      l_lovs := «metaData.generatorOwner».«metaData.generatorName».get_lov();
			   «ENDIF»
			   l_key  := l_lovs.first;
			   add_text('<lovs>');
			   WHILE l_key IS NOT NULL
			   LOOP
			      add_text('<lov><key><![CDATA[' || l_key || ']]></key><values>');
			      FOR i IN 1 .. l_lovs(l_key).count
			      LOOP
			         add_text('<value><![CDATA[' || l_lovs(l_key) (i) || ']]></value>');
			      END LOOP;
			      add_text('</values></lov>');
			      l_lovs.delete(l_key);
			      l_key := l_lovs.first;
			   END LOOP;
			   add_text('</lovs>');
			   flush_buffer;
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		val lovs = new HashMap<String, List<String>>()
		var Document doc
		if (metaData.hasGetLov3 || metaData.hasGetLov2 || metaData.hasRefreshLov || metaData.hasGetLov1) {
			doc = plsql.doc
		}
		if (doc !== null) {
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

	def getParamStates(DatabaseGeneratorMetaData metaData, LinkedHashMap<String, String> params, List<Node> nodes) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   «IF metaData.hasGetParamStates2»
			      l_params       «metaData.typesOwnerPrefix»oddgen_types.t_param_type;
			      l_node         «metaData.typesOwnerPrefix»oddgen_types.r_node_type;
			      l_nodes        «metaData.typesOwnerPrefix»oddgen_types.t_node_type := «metaData.typesOwnerPrefix»oddgen_types.t_node_type();
			      l_param_states «metaData.typesOwnerPrefix»oddgen_types.t_param_type;
			      l_key          «metaData.typesOwnerPrefix»oddgen_types.value_type;
			   «ELSE»
			      l_params       «metaData.generatorOwner».«metaData.generatorName».t_param;
			      l_param_states «metaData.generatorOwner».«metaData.generatorName».t_param;
			      l_key          «metaData.generatorOwner».«metaData.generatorName».param_type;
			   «ENDIF»
			   l_clob         CLOB;
			   «addTextVariables»
			   --
			   «addTextProcedures("l_clob")»
			BEGIN
			   sys.dbms_lob.createtemporary(l_clob, TRUE);
			   «FOR key : params.keySet»
			      l_params('«key»') := '«params.get(key).escapeSingleQuotes»';
			   «ENDFOR»
			   «IF metaData.hasGetParamStates2»
			      «nodes.toPlsql»
			      l_param_states := «metaData.generatorOwner».«metaData.generatorName».get_param_states(
			                           in_params => l_params,
			                           in_nodes  => l_nodes
			                        );
			   «ELSE»
			      l_param_states := «metaData.generatorOwner».«metaData.generatorName».«IF metaData.hasGetParamStates1»get_param_states«ELSE»refresh_param_states«ENDIF»(
			                           in_object_type => '«nodes.toObjectType»',
			                           in_object_name => '«nodes.toObjectName»',
			                           in_params      => l_params
			                        );
			   «ENDIF»
			   l_key          := l_param_states.first;
			   add_text('<paramStates>');
			   WHILE l_key IS NOT NULL
			   LOOP
			      add_text('<paramState><key><![CDATA[' || l_key || ']]></key><value><![CDATA[' || l_param_states(l_key) || ']]></value></paramState>');
			      l_param_states.delete(l_key);
			      l_key := l_param_states.first;
			   END LOOP;
			   add_text('</paramStates>');
			   flush_buffer;
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		val paramStates = new HashMap<String, String>()
		var Document doc
		if (metaData.hasGetParamStates2 || metaData.hasGetParamStates1 || metaData.hasRefreshParamStates) {
			doc = plsql.doc
		}
		if (doc !== null) {
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
	
	def generateProlog(DatabaseGeneratorMetaData metaData, List<Node> nodes) {
		val plsql = '''
			DECLARE
			   l_node   «metaData.typesOwnerPrefix»oddgen_types.r_node_type;
			   l_nodes  «metaData.typesOwnerPrefix»oddgen_types.t_node_type := «metaData.typesOwnerPrefix»oddgen_types.t_node_type();
			   l_clob   CLOB;
			BEGIN
			   «nodes.toPlsql»
			   l_clob := «metaData.generatorOwner».«metaData.generatorName».generate_prolog(
			                in_nodes => l_nodes
			             );
			   ? := l_clob;
			END;
		'''
		var String result = ""
		if (metaData.hasGenerateProlog) {
			result = plsql.getClob('''Failed to generate prolog code for «nodes.size» nodes via «metaData.generatorOwner».«metaData.generatorName»''') 
		}
		return result
	}
	
	def generateSeparator(DatabaseGeneratorMetaData metaData) {
		val plsql = '''
		   DECLARE
		      l_sep VARCHAR2(4000 CHAR);
		   BEGIN
		      l_sep := «metaData.generatorOwner».«metaData.generatorName».generate_separator;
		      ? := l_sep;
		   END;
		'''
		var String result = '\n';
		if (metaData.hasGenerateSeparator) {
			result = plsql.getString
		}
		return result
	}

	def generateEpilog(DatabaseGeneratorMetaData metaData, List<Node> nodes) {
		val plsql = '''
			DECLARE
			   l_node   «metaData.typesOwnerPrefix»oddgen_types.r_node_type;
			   l_nodes  «metaData.typesOwnerPrefix»oddgen_types.t_node_type := «metaData.typesOwnerPrefix»oddgen_types.t_node_type();
			   l_clob   CLOB;
			BEGIN
			   «nodes.toPlsql»
			   l_clob := «metaData.generatorOwner».«metaData.generatorName».generate_epilog(
			                in_nodes => l_nodes
			             );
			   ? := l_clob;
			END;
		'''
		var String result = ""
		if (metaData.hasGenerateEpilog) {
			result = plsql.getClob('''Failed to generate epilog code for «nodes.size» nodes via «metaData.generatorOwner».«metaData.generatorName»''') 
		}
		return result
	}

	def String bulkGenerate(DatabaseGeneratorMetaData metaData, List<Node> nodes) {
		val nodesString = nodes.toXml(false).toString
		val Clob nodesXml = conn.createClob();
		nodesXml.setString(1, nodesString)
		val oddgenTypesUsed = (metaData.hasGetFolders || metaData.hasGetNodes || metaData.hasGenerateProlog || metaData.hasGenerateEpilog || metaData.hasGenerate3) 
		val plsql = '''
			DECLARE
			   «IF oddgenTypesUsed»
			      -- oddgen_types usage detected
			      l_node   «metaData.typesOwnerPrefix»oddgen_types.r_node_type;
			      l_nodes  «metaData.typesOwnerPrefix»oddgen_types.t_node_type := «metaData.typesOwnerPrefix»oddgen_types.t_node_type();
			      l_sep    «metaData.typesOwnerPrefix»oddgen_types.value_type := chr(10);
			      l_p      «metaData.typesOwnerPrefix»oddgen_types.t_param_type;
			   «ELSE»
			      -- no oddgen_types usage detected, define types locally
			      SUBTYPE key_type    IS VARCHAR2(4000 BYTE);
			      SUBTYPE value_type  IS VARCHAR2(32767 BYTE);
			      TYPE t_value_type   IS TABLE OF value_type;
			      TYPE t_param_type   IS TABLE OF value_type INDEX BY key_type;
			      TYPE t_lov_type     IS TABLE OF t_value_type INDEX BY key_type;
			      TYPE r_node_type    IS RECORD (
			         id               key_type,
			         parent_id        key_type,
			         name             value_type,
			         description      value_type,
			         icon_name        key_type,
			         icon_base64      value_type,
			         params           t_param_type,
			         leaf             BOOLEAN,
			         generatable      BOOLEAN,
			         multiselectable  BOOLEAN,
			         relevant         BOOLEAN
			      );
			      TYPE t_node_type    IS TABLE OF r_node_type;
			      l_node   r_node_type;
			      l_nodes  t_node_type := t_node_type();
			      l_sep    value_type := chr(10);
			      l_p      t_param_type;
			   «ENDIF»
			   «IF metaData.hasGenerate1»
			      l_params «metaData.generatorOwner».«metaData.generatorName».t_param;
			   «ENDIF»
			   l_clob   CLOB;
			   l_temp   CLOB;
			BEGIN
			   «IF metaData.hasGenerateSeparator»
			      l_sep := «metaData.generatorOwner».«metaData.generatorName».generate_separator;
			   «ENDIF»
			   «IF nodes.size > 0 && nodes.get(0).params !== null»
			      «FOR key : nodes.get(0).params.keySet»
			         l_p('«key.escapeSingleQuotes»') := '«nodes.get(0).params.get(key).escapeSingleQuotes»';
			      «ENDFOR»
			   «ENDIF»
			   FOR r IN (
			      SELECT id,
			             parent_id,
			             name,
			             description,
			             icon_name,
			             icon_base64,
			             leaf,
			             generatable,
			             multiselectable,
			             relevant
			        FROM XMLTABLE(
			                '/nodes/node'
			                PASSING XMLTYPE(?)
			                COLUMNS id              VARCHAR2(4000 BYTE) PATH 'id',
			                        parent_id       VARCHAR2(4000 BYTE) PATH 'parent_id',
			                        name            CLOB                PATH 'name',
			                        description     CLOB                PATH 'description',
			                        icon_name       VARCHAR2(4000 BYTE) PATH 'icon_name',
			                        icon_base64     CLOB                PATH 'icon_base64',
			                        leaf            VARCHAR2(5 CHAR)    PATH 'leaf',
			                        generatable     VARCHAR2(5 CHAR)    PATH 'generatable',
			                        multiselectable VARCHAR2(5 CHAR)    PATH 'multiselectable',
			                        relevant        VARCHAR2(5 CHAR)    PATH 'relevant'
			             )
			   ) LOOP
			      l_node.id              := r.id;
			      l_node.parent_id       := r.parent_id;
			      l_node.name            := r.name;
			      l_node.description     := r.description;
			      l_node.icon_name       := r.icon_name;
			      l_node.icon_base64     := r.icon_base64;
			      l_node.leaf            := r.leaf = 'true';
			      l_node.generatable     := r.generatable = 'true';
			      l_node.multiselectable := r.multiselectable = 'true';
			      l_node.relevant        := r.relevant = 'true';
			      l_node.params          := l_p;
			      l_nodes.extend;
			      l_nodes(l_nodes.count) := l_node;
			   END LOOP;
			   «IF metaData.hasGenerate1»
			      «IF nodes.size > 0 && nodes.get(0).params !== null»
			         «FOR key : nodes.get(0).params.keySet»
			            l_params('«key»') := '«nodes.get(0).params.get(key).escapeSingleQuotes»';
			         «ENDFOR»
			      «ENDIF»
			   «ENDIF»
			   sys.dbms_lob.createtemporary(l_clob, TRUE);
			   «IF metaData.hasGenerateProlog»
			      BEGIN
			         l_temp := «metaData.generatorOwner».«metaData.generatorName».generate_prolog(
			                      in_nodes => l_nodes
			                   );
			      EXCEPTION
			         WHEN OTHERS THEN
			            l_temp := 'Failed to generate prolog for «nodes.size» nodes via «metaData.generatorOwner».«metaData.generatorName». Got the following error: '
			                      || SQLERRM || chr(10) || sys.dbms_utility.format_error_backtrace();
			      END;
			      IF l_temp IS NOT NULL THEN
			         IF NOT sys.dbms_lob.substr(l_temp, 1, sys.dbms_lob.getlength(l_temp)) = chr(10) THEN
			            sys.dbms_lob.append(l_temp, chr(10));
			         END IF;
			         sys.dbms_lob.append(l_clob, l_temp);
			      END IF;
			   «ENDIF»
			   FOR i IN 1 .. l_nodes.count LOOP
			      BEGIN
			         «IF metaData.hasGenerate3»
			            l_temp := «metaData.generatorOwner».«metaData.generatorName».generate(
			                         in_node => l_nodes(i)
			                      );
			         «ELSE»
			            l_temp := «metaData.generatorOwner».«metaData.generatorName».generate(
			                         in_object_type => l_nodes(i).parent_id
			                       , in_object_name => substr(l_nodes(i).id, instr(l_nodes(i).id, '.') + 1)
			                      «IF metaData.hasGenerate1»
			                         , in_params      => l_params
			                      «ENDIF»
			                      );
			         «ENDIF»
			      EXCEPTION
			         WHEN OTHERS THEN
			             l_temp := 'Failed to generate code for ' || l_nodes(i).id
			                       || ' via «metaData.generatorOwner».«metaData.generatorName». Got the following error: '
			                       || SQLERRM || chr(10) || sys.dbms_utility.format_error_backtrace();
			      END;
			      IF l_temp IS NOT NULL THEN
			         IF NOT sys.dbms_lob.substr(l_temp, 1, sys.dbms_lob.getlength(l_temp)) = chr(10) THEN
			            sys.dbms_lob.append(l_temp, chr(10));
			         END IF;
			         IF l_clob IS NULL THEN
			            l_clob := l_temp;
			         ELSE
			            sys.dbms_lob.append(l_clob, l_temp);
			         END IF;
			         IF i < l_nodes.count AND l_sep IS NOT NULL THEN
			            sys.dbms_lob.append(l_clob, l_sep);
			         END IF;
			      END IF;
			   END LOOP;
			   «IF metaData.hasGenerateEpilog»
			      BEGIN
			         l_temp := «metaData.generatorOwner».«metaData.generatorName».generate_epilog(
			                      in_nodes => l_nodes
			         	       );
			      EXCEPTION
			         WHEN OTHERS THEN
			            l_temp := 'Failed to generate epilog for «nodes.size» nodes via «metaData.generatorOwner».«metaData.generatorName». Got the following error: '
			                      || SQLERRM || chr(10) || sys.dbms_utility.format_error_backtrace();
			      END;
			      IF l_temp IS NOT NULL THEN
			         sys.dbms_lob.append(l_clob, l_temp);
			      END IF;
			   «ENDIF»
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		val result = plsql.getClob('''Failed to generate code for «nodes.size» nodes via «metaData.generatorOwner».«metaData.generatorName»''', nodesXml)
		return result
	}

	def String generate(DatabaseGeneratorMetaData metaData, Node node) {
		val plsql = '''
			DECLARE
			   «IF metaData.hasGenerate3»
			      l_node   «metaData.typesOwnerPrefix»oddgen_types.r_node_type;
			   «ELSEIF metaData.hasGenerate1»
			      l_params «metaData.generatorOwner».«metaData.generatorName».t_param;
			   «ENDIF»
			   l_clob   CLOB;
			BEGIN
			   «IF metaData.hasGenerate3»
			      «node.toPlsql»
			      l_clob := «metaData.generatorOwner».«metaData.generatorName».generate(
			                   in_node => l_node
			                );
			   «ELSE»
			      «IF metaData.hasGenerate1»
			         «IF node.params !== null»
			            «FOR key : node.params.keySet»
			               l_params('«key»') := '«node.params.get(key).escapeSingleQuotes»';
			            «ENDFOR»
			         «ENDIF»
			      «ENDIF»
			      l_clob := «metaData.generatorOwner».«metaData.generatorName».generate(
			                     in_object_type => '«node.toObjectType»'
			                   , in_object_name => '«node.toObjectName»'
			                   «IF metaData.hasGenerate1»
			                      , in_params      => l_params
			                   «ENDIF»
			                );
			   «ENDIF»
			   ? := l_clob;
			END;
		'''
		Logger.debug(this, "plsql: %s", plsql)
		val result = plsql.getClob('''Failed to generate code for «node.id» via «metaData.generatorOwner».«metaData.generatorName»''')
		return result
	}

}
