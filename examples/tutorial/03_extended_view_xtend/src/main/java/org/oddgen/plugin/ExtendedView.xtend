/*
 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
package org.oddgen.plugin

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

class ExtendedView implements OddgenGenerator2 {

	private extension NodeTools nodeTools = new NodeTools

	static val SELECT_STAR = 'Select * ?'
	static val VIEW_SUFFIX = 'View suffix'
	static val ORDER_COLUMNS = 'Order columns?'

	private def getColumnNames(Connection conn, String tableName, LinkedHashMap<String, String> params) {
		if(params.get(SELECT_STAR) == "Yes") {
			return #["*"]
		} else {
			val sortColumnName = if(params.get(ORDER_COLUMNS) == "Yes") "column_name" else "column_id"
			val sql = '''
				SELECT column_name
				  FROM user_tab_columns
				 WHERE table_name = ?
				 ORDER BY «sortColumnName»
			'''
			val jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
			val columnNames = jdbcTemplate.queryForList(sql, String, tableName.toUpperCase)
			return columnNames
		}
	}

	override isSupported(Connection conn) {
		var ret = false
		if (conn !== null) {
			if (conn.metaData.databaseProductName.startsWith("Oracle")) {
				if (conn.metaData.databaseMajorVersion == 9) {
					if (conn.metaData.databaseMinorVersion >= 2) {
						ret = true
					}
				} else if (conn.metaData.databaseMajorVersion > 9) {
					ret = true
				}
			}
		}
		return ret
	}

	override getName(Connection conn) {
		return "Extended 1:1 View Generator"
	}

	override getDescription(Connection conn) {
		return "Generates a 1:1 view based on an existing table and various generator parameters."
	}

	override getFolders(Connection conn) {
		return #["Client Generators"]
	}

	override getHelp(Connection conn) {
		return "<p>not yet available</p>"
	}

	override getNodes(Connection conn, String parentNodeId) {
		val params = new LinkedHashMap<String, String>()
		params.put(SELECT_STAR, "No")
		params.put(VIEW_SUFFIX, "_v")
		params.put(ORDER_COLUMNS, "No")
		if (parentNodeId === null || parentNodeId.empty) {
			val tableNode = new Node
			tableNode.id = "TABLE"
			tableNode.params = params
			tableNode.leaf = false
			tableNode.generatable = true
			tableNode.multiselectable = true
			return #[tableNode]
		} else {
			val sql = '''
				SELECT object_type || '.' || object_name AS id,
				       object_type AS parent_id,
				       1 AS leaf,
				       1 AS generatable,
				       1 AS multiselectable
				  FROM user_objects
				 WHERE object_type = ?
				   AND generated = 'N'
			'''
			val jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
			val nodes = jdbcTemplate.query(sql, new BeanPropertyRowMapper<Node>(Node), #[parentNodeId])
			for (node : nodes) {
				node.params = params
			}
			return nodes
		}
	}

	override HashMap<String, List<String>> getLov(Connection conn, LinkedHashMap<String, String> params,
		List<Node> nodes) {
		val lov = new HashMap<String, List<String>>()
		if(params.get(SELECT_STAR) == "Yes") {
			lov.put(ORDER_COLUMNS, #["No"])
		} else {
			lov.put(ORDER_COLUMNS, #["Yes", "No"])
		}
		if(params.get(ORDER_COLUMNS) == "Yes") {
			lov.put(SELECT_STAR, #["No"])
		} else {
			lov.put(SELECT_STAR, #["Yes", "No"])
		}
		return lov
	}

	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return new HashMap<String, Boolean>()
	}

	override generateProlog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generateSeparator(Connection conn) {
		return "\n--"
	} 

	override generateEpilog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generate(Connection conn, Node node) {
		try {
			val tableName = node.toObjectName.toLowerCase
			val viewName = '''«tableName»«node.params.get(VIEW_SUFFIX).toLowerCase»'''
			val columnNames = getColumnNames(conn, tableName, node.params)
			val result = '''
				CREATE OR REPLACE VIEW «viewName» AS
				   SELECT «FOR col : columnNames SEPARATOR ", "»«col.toLowerCase»«ENDFOR»
				     FROM «tableName»;
			'''
			return result
		} catch(Exception e) {
			return '''Cannot create view statement, got: «e.message».'''
		}		
	}
}
