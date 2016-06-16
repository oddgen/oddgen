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
package org.oddgen.sqldev.plugin

import java.sql.Connection
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.generators.OddgenGenerator
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class HelloWorldClientGenerator implements OddgenGenerator {
	
	override getName(Connection conn) {
		return "Hello World"
	}
	
	override getDescription(Connection conn) {
		return "Hello World example generator"
	}
	
	override getObjectTypes(Connection conn) {
		val objectTypes = new ArrayList<String>()
		objectTypes.add("TABLE")
		objectTypes.add("VIEW")
		return objectTypes
	}
	
	override getObjectNames(Connection conn, String objectType) {
		val sql = '''
			SELECT object_name
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
		return new LinkedHashMap<String, String>()
	}
	
	override getLov(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		return new HashMap<String, List<String>>()
	}
	
	override getParamStates(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		new HashMap<String, Boolean>()
	}
	
	override generate(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		val result = '''
			BEGIN
			   sys.dbms_output.put_line('Hello «objectType» «objectName»!');
			END;
			/
		'''
		return result;
	}
	
}