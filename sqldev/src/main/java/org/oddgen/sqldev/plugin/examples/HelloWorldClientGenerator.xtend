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
package org.oddgen.sqldev.plugin.examples

import java.sql.Connection
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.generators.model.NodeTools
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class HelloWorldClientGenerator implements OddgenGenerator2 {

	var extension NodeTools nodeTools = new NodeTools	
	var long startTimeMillis = System.currentTimeMillis
	
	override getName(Connection conn) {
		return "Hello World"
	}
	
	override getDescription(Connection conn) {
		return "Hello World example generator"
	}
	
	override getFolders(Connection conn) {
		return #["Client Generators", "Examples"]
	}
	
	override getHelp(Connection conn) {
		return "<p>Hello World example generator</p>"
	}
	
	override getNodes(Connection conn, String parentNodeId) {
		// eager loading implementation
		val sql = '''
			SELECT 'TABLE' AS id,
			       NULL AS parent_id,
			       0 AS leaf,
			       1 AS generatable,
			       1 AS multiselectable
			  FROM dual
			UNION ALL
			SELECT 'VIEW' AS id,
			       NULL AS parent_id,
			       0 AS leaf,
			       1 AS generatable,
			       1 AS multiselectable
			  FROM dual
			UNION ALL
			SELECT object_type || '.' || object_name AS id,
			       object_type AS parent_id,
			       1 AS leaf,
			       1 AS generatable,
			       1 AS multiselectable
			  FROM user_objects
			 WHERE object_type IN ('TABLE', 'VIEW')
			   AND generated = 'N'
		'''
		val jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		val nodes = jdbcTemplate.query(sql, new BeanPropertyRowMapper<Node>(Node))
		return nodes
	}
			
	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return new HashMap<String, List<String>>
	}
	
	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return new HashMap<String, Boolean>
	}
	
	override generateProlog(Connection conn, List<Node> nodes) {
		startTimeMillis = System.currentTimeMillis
		val result = '''
			BEGIN
			   -- «nodes.size» nodes selected.
		'''
		return result
	}
	
	override generateSeparator(Connection conn) {
		return ""
	}

	override generateEpilog(Connection conn, List<Node> nodes) {
		val result = '''
			«'   '»-- «nodes.size» nodes generated in «System.currentTimeMillis - startTimeMillis» ms.
			END;
			/
		'''
		return result
	}
	
	override generate(Connection conn, Node node) {
		val result = '''
			«'   '»sys.dbms_output.put_line('Hello «node.toObjectType» «node.toObjectName»!');
		'''
		return result;
	}
	
}