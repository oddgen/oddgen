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
package org.oddgen.plugin.extendedview

import java.sql.Connection
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.generators.OddgenGenerator
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class ExtendedView implements OddgenGenerator {

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

	override getName(Connection conn) {
		return "Extended 1:1 View Generator"
	}

	override getDescription(Connection conn) {
		return "Generates a 1:1 view based on an existing table and various generator parameters."
	}

	override getObjectTypes(Connection conn) {
		val objectTypes = new ArrayList<String>()
		objectTypes.add("TABLE")
		return objectTypes
	}

	override getObjectNames(Connection conn, String objectType) {
		val sql = '''
			SELECT initcap(object_name) AS object_name
			  FROM user_objects
			 WHERE object_type = ?
			   AND generated = 'N'
			ORDER BY object_name
		'''
		val jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		val objectNames = jdbcTemplate.queryForList(sql, String, objectType)
		return objectNames
	}

	override getParams(Connection conn, String objectType, String objectName) {
		val params = new LinkedHashMap<String, String>()
		params.put(SELECT_STAR, "No")
		params.put(VIEW_SUFFIX, "_v")
		params.put(ORDER_COLUMNS, "No")
		return params
	}

	override getLov(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
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

	override getParamStates(Connection conn, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		return new HashMap<String, Boolean>()
	}

	override generate(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		try {
			val tableName = objectName.toLowerCase
			val viewName = '''«tableName»«params.get(VIEW_SUFFIX).toLowerCase»'''
			val columnNames = getColumnNames(conn, tableName, params)
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
