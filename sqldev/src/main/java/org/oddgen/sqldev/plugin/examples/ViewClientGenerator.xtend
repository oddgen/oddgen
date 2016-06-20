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
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.generators.OddgenGenerator
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class ViewClientGenerator implements OddgenGenerator {

	public static var VIEW_SUFFIX = "View suffix"
	public static var TABLE_SUFFIX = "Table suffix to be replaced"
	public static var IOT_SUFFIX = "Instead-of-trigger suffix"
	public static var GEN_IOT = "Generate instead-of-trigger?"

	static int MAX_OBJ_LEN = 30

	var Connection conn;
	var String objectType;
	var String objectName;
	var LinkedHashMap<String, String> params

	override getName(Connection conn) {
		return "1:1 View"
	}

	override getDescription(Connection conn) {
		return "Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger."
	}

	override getObjectTypes(Connection conn) {
		val objectTypes = new ArrayList<String>()
		objectTypes.add("TABLE")
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
		val params = new LinkedHashMap<String, String>()
		params.put(VIEW_SUFFIX, "_V")
		params.put(TABLE_SUFFIX, "_T")
		params.put(GEN_IOT, "Yes")
		params.put(IOT_SUFFIX, "_TRG")
		return params
	}

	override getLov(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		val lov = new HashMap<String, List<String>>()
		lov.put(GEN_IOT, #["Yes", "No"])
		return lov
	}

	override getParamStates(Connection conn, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		val paramStates = new HashMap<String, Boolean>()
		paramStates.put(IOT_SUFFIX, params.get(GEN_IOT) == "Yes")
		return paramStates
	}

	override generate(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		this.conn = conn;
		this.objectType = objectType
		this.objectName = objectName
		this.params = params
		try {
			checkParams
			val result = '''
				«generateView»
				«IF params.get(GEN_IOT) == "Yes"»
					«generateInsteadOfTrigger»
				«ENDIF»
			'''
			return result;

		} catch(Exception e) {
			return e.message
		}
	}

	private def void checkParams() {
		if(objectType != "TABLE") {
			throw new RuntimeException('''<«objectType»> is not a supported object type. Please use TABLE.''')
		}
		val defaultParams = getParams(conn, objectType, objectName)
		for (key : defaultParams.keySet) {
			if(params.get(key) == null) {
				throw new RuntimeException('''Parameter <«key»> is missing.''')
			}
		}
		for (key : params.keySet) {
			if(defaultParams.get(key) == null) {
				throw new RuntimeException('''Parameter <«key»> is not known.''')
			}
		}
		val lov = getLov(conn, objectType, objectName, params)
		for (key : lov.keySet) {
			if(!(lov.get(key).contains(
				params.get(
				key)))) {
				throw new RuntimeException('''Invalid value <«params.get(key)»> for parameter <«key»>. Valid values are: «FOR value : lov.get(key) SEPARATOR ", "»«value»«ENDFOR».''')
			}
		}
		if(columns.size == 0) {
			throw new RuntimeException('''Table «objectName» not found.''')
		}
		if(viewName ==
			objectName) {
			throw new RuntimeException('''Change <«VIEW_SUFFIX»>. The target view must be named differently than its base table.''')
		}
		if(params.get(GEN_IOT) == "Yes") {
			if(primaryKeyColumns.size ==
				0) {
				throw new RuntimeException('''No primary key found in table «objectName». Cannot generate instead-of-trigger.''')
			}
		}
	}

	private def generateView() {
		val result = '''
			-- create 1:1 view for demonstration purposes
			CREATE OR REPLACE VIEW «viewName» AS
			   SELECT «FOR col : columns SEPARATOR ",\n       "»«col»«ENDFOR»
			     FROM «objectName»;
		'''
		return result
	}

	private def generateInsteadOfTrigger() {
		val result = '''
			-- create simple instead-of-trigger for demonstration purposes
			CREATE OR REPLACE TRIGGER «insteadOfTriggerName»
			   INSTEAD OF INSERT OR UPDATE OR DELETE ON «viewName»
			BEGIN
			   IF INSERTING THEN
			      INSERT INTO «objectName» (
			         «FOR col : columns SEPARATOR ","»
			         	«col»
			         «ENDFOR»
			      ) VALUES (
			         «FOR col : columns SEPARATOR ","»
			         	:NEW.«col»
			         «ENDFOR»
			      );
			   ELSIF UPDATING THEN
			      UPDATE «objectName»
			         SET «FOR col : columns SEPARATOR ",\n    "»«col» = :NEW.«col»«ENDFOR»
			       «FOR col : primaryKeyColumns BEFORE "WHERE " SEPARATOR "\n  AND " AFTER ";"»«col» = :OLD.«col»«ENDFOR»
			   ELSIF DELETING THEN
			      DELETE FROM «objectName»
			       «FOR col : primaryKeyColumns BEFORE "WHERE " SEPARATOR "\n  AND " AFTER ";"»«col» = :OLD.«col»«ENDFOR»
			   END IF;
			END;
			/
		'''
		return result
	}

	private def getColumns() {
		val sql = '''
			SELECT column_name 
			  FROM user_tab_columns 
			 WHERE table_name = ? 
			ORDER BY column_id
		'''
		val jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		val columns = jdbcTemplate.queryForList(sql, String, objectName)
		return columns
	}

	private def getPrimaryKeyColumns() {
		val sql = '''
			SELECT cols.column_name
			  FROM user_constraints pk
			  JOIN user_cons_columns cols
			    ON cols.constraint_name = pk.constraint_name
			 WHERE pk.constraint_type = 'P'
			       AND pk.table_name = ?
			 ORDER BY cols.position
		'''
		val jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		val columns = jdbcTemplate.queryForList(sql, String, objectName)
		return columns
	}

	private def getViewName() {
		return params.get(VIEW_SUFFIX).name
	}

	private def getInsteadOfTriggerName() {
		return params.get(IOT_SUFFIX).name
	}

	private def getName(String suffix) {
		val sb = new StringBuffer()
		if(baseName.length + suffix.length > MAX_OBJ_LEN) {
			sb.append(baseName.substring(0, MAX_OBJ_LEN - suffix.length))
		} else {
			sb.append(baseName)
		}
		sb.append(suffix)
		return sb.toString
	}

	private def getBaseName() {
		var String baseName
		val suffix = params.get(TABLE_SUFFIX)
		if(suffix != null && suffix.length > 0 && objectName.endsWith(suffix)) {
			baseName = objectName.substring(0, objectName.length - suffix.length)
		} else {
			baseName = objectName
		}
		return baseName
	}
}
