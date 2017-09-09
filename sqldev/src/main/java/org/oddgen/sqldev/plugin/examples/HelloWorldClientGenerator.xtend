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
package org.oddgen.sqldev.plugin.examples

import java.sql.Connection
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.dal.DalTools
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.generators.model.NodeTools
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class HelloWorldClientGenerator implements OddgenGenerator2 {

	var extension NodeTools nodeTools = new NodeTools	
	var double startTimeNanos = System.nanoTime

	override isSupported(Connection conn) {
		return true
	}
	
	override getName(Connection conn) {
		return "Hello World"
	}
	
	override getDescription(Connection conn) {
		return "Hello World example generator"
	}
	
	override getFolders(Connection conn) {
		return #["Examples", "Xtend"]
	}
	
	override getHelp(Connection conn) {
		return "<p>Hello World example generator</p>"
	}
	
	override getNodes(Connection conn, String parentNodeId) {
		val dalTools = new DalTools(conn)
		if (dalTools.isAtLeastOracle(9,2)) {
			// eager loading implementation for Oracle Database 9.2 and higher
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
		} else {
			// lazy loading implementation for generic JDBC driver
			if (parentNodeId === null || parentNodeId.empty) {
				val tableNode = new Node
				tableNode.id = "TABLE"
				tableNode.leaf = false
				tableNode.generatable = true
				tableNode.multiselectable = true
				val viewNode = new Node
				viewNode.id = "VIEW"
				viewNode.leaf = false
				viewNode.generatable = true
				viewNode.multiselectable = true
				return #[tableNode, viewNode]
			} else {
				val nodes = new ArrayList<Node>
				val resultSet = conn.metaData.getTables(null, null, null, #[parentNodeId])
				while (resultSet.next) {
					val node = new Node
					node.id = '''«parentNodeId».«resultSet.getString("TABLE_NAME")»'''
					node.parentId = parentNodeId
					node.leaf = true
					node.generatable = true
					node.multiselectable = true
					nodes.add(node)
				}
				resultSet.close
				return nodes
			}
		}
	}
			
	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return new HashMap<String, List<String>>
	}
	
	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return new HashMap<String, Boolean>
	}
	
	override generateProlog(Connection conn, List<Node> nodes) {
		startTimeNanos = System.nanoTime
		val result = '''
			BEGIN
			   -- «nodes.size» nodes selected.
			   «IF nodes.size == 0»
			      NULL;
			   «ENDIF»
		'''
		return result
	}
	
	override generateSeparator(Connection conn) {
		return ""
	}

	override generateEpilog(Connection conn, List<Node> nodes) {
		val result = '''
			«'   '»-- «nodes.size» nodes generated in «String.format("%.3f", (System.nanoTime - startTimeNanos) / 1000000)» ms.
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