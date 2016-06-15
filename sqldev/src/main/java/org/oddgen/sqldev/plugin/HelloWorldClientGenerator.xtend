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