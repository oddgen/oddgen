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

import com.jcabi.log.Logger
import java.sql.Connection
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

class ViewClientGenerator implements OddgenGenerator2 {

	public static var VIEW_SUFFIX = "View suffix"
	public static var TABLE_SUFFIX = "Table suffix to be replaced"
	public static var IOT_SUFFIX = "Instead-of-trigger suffix"
	public static var GEN_IOT = "Generate instead-of-trigger?"

	static int MAX_OBJ_LEN = 30

	var Connection conn;
	var Node node;
	var extension NodeTools nodeTools = new NodeTools

	override isSupported(Connection conn) {
		val dalTools = new DalTools(conn)
		if (dalTools.isAtLeastOracle(9,2)) {
			return true
		} else {
			Logger.info(this, '''The 1:1 View generator does not support this connection. Requires Oracle Database 9.2 or higher.''')
			return false
		}
	}

	override getName(Connection conn) {
		return "1:1 View"
	}

	override getDescription(Connection conn) {
		return "Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger."
	}

	override getFolders(Connection conn) {
		return #["Examples", "Xtend"]
	}

	override getHelp(Connection conn) {
		return "<p>Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger.</p>"
	}

	override getNodes(Connection conn, String parentNodeId) {
		// lazy loading implementation
		val params = new LinkedHashMap<String, String>()
		params.put(VIEW_SUFFIX, "_V")
		params.put(TABLE_SUFFIX, "_T")
		params.put(GEN_IOT, "Yes")
		params.put(IOT_SUFFIX, "_TRG")
		if (parentNodeId === null || parentNodeId.empty) {
			// object type TABLE only
			val node = new Node
			node.id = "TABLE"
			node.params = params
			node.leaf = false
			node.generatable = true
			node.multiselectable = false // not feasible with a single node
			return #[node]
		} else {
			// tables
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
				node.params = params // same params instance for each node is OK
			}
			return nodes
		}
	}

	override HashMap<String, List<String>> getLov(Connection conn, LinkedHashMap<String, String> params,
		List<Node> nodes) {
		val lov = new HashMap<String, List<String>>()
		lov.put(GEN_IOT, #["Yes", "No"])
		return lov
	}

	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val paramStates = new HashMap<String, Boolean>()
		paramStates.put(IOT_SUFFIX, params.get(GEN_IOT) == "Yes")
		return paramStates
	}

	override generateProlog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generateSeparator(Connection conn) {
		return "\n"
	}

	override generateEpilog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generate(Connection conn, Node node) {
		this.conn = conn;
		this.node = node;
		try {
			checkParams
			val result = '''
				«generateView»
				«IF node.params.get(GEN_IOT) == "Yes"»
					«generateInsteadOfTrigger»
				«ENDIF»
			'''
			return result;

		} catch (Exception e) {
			return e.message
		}
	}

	private def void checkParams() {
		if (node.parentId != "TABLE") {
			throw new RuntimeException('''<«node.parentId»> is not a supported object type. Please use TABLE.''')
		}
		val defaultParams = conn.getNodes(null).get(0).params
		for (key : defaultParams.keySet) {
			if (node.params.get(key) === null) {
				throw new RuntimeException('''Parameter <«key»> is missing.''')
			}
		}
		for (key : node.params.keySet) {
			if (defaultParams.get(key) === null) {
				throw new RuntimeException('''Parameter <«key»> is not known.''')
			}
		}
		val lov = getLov(conn, node.params, #[node])
		for (key : lov.keySet) {
			if (!(lov.get(key).contains(
				node.params.get(key)))) {
				throw new RuntimeException('''Invalid value <«node.params.get(key)»> for parameter <«key»>. Valid values are: «FOR value : lov.get(key) SEPARATOR ", "»«value»«ENDFOR».''')
			}
		}
		if (columns.size == 0) {
			throw new RuntimeException('''Table «node.toObjectName» not found.''')
		}
		if (viewName == node.toObjectName) {
			throw new RuntimeException('''Change <«VIEW_SUFFIX»>. The target view must be named differently than its base table.''')
		}
		if (node.params.get(GEN_IOT) == "Yes") {
			if (primaryKeyColumns.size == 0) {
				throw new RuntimeException('''No primary key found in table «node.toObjectName». Cannot generate instead-of-trigger.''')
			}
		}
	}

	private def generateView() {
		val result = '''
			-- create 1:1 view for demonstration purposes
			CREATE OR REPLACE VIEW «viewName» AS
			   SELECT «FOR col : columns SEPARATOR ",\n       "»«col»«ENDFOR»
			     FROM «node.toObjectName»;
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
			      INSERT INTO «node.toObjectName» (
			         «FOR col : columns SEPARATOR ","»
			         	«col»
			         «ENDFOR»
			      ) VALUES (
			         «FOR col : columns SEPARATOR ","»
			         	:NEW.«col»
			         «ENDFOR»
			      );
			   ELSIF UPDATING THEN
			      UPDATE «node.toObjectName»
			         SET «FOR col : columns SEPARATOR ",\n    "»«col» = :NEW.«col»«ENDFOR»
			       «FOR col : primaryKeyColumns BEFORE "WHERE " SEPARATOR "\n  AND " AFTER ";"»«col» = :OLD.«col»«ENDFOR»
			   ELSIF DELETING THEN
			      DELETE FROM «node.toObjectName»
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
		val columns = jdbcTemplate.queryForList(sql, String, node.toObjectName)
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
		val columns = jdbcTemplate.queryForList(sql, String, node.toObjectName)
		return columns
	}

	private def getViewName() {
		return node.params.get(VIEW_SUFFIX).name
	}

	private def getInsteadOfTriggerName() {
		return node.params.get(IOT_SUFFIX).name
	}

	private def getName(String suffix) {
		val sb = new StringBuffer()
		if (baseName.length + suffix.length > MAX_OBJ_LEN) {
			sb.append(baseName.substring(0, MAX_OBJ_LEN - suffix.length))
		} else {
			sb.append(baseName)
		}
		sb.append(suffix)
		return sb.toString
	}

	private def getBaseName() {
		var String baseName
		val suffix = node.params.get(TABLE_SUFFIX)
		if (suffix !== null && suffix.length > 0 && node.toObjectName.endsWith(suffix)) {
			baseName = node.toObjectName.substring(0, node.toObjectName.length - suffix.length)
		} else {
			baseName = node.toObjectName
		}
		return baseName
	}
}
