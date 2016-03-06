package org.oddgen.sqldev.dal

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.io.StringReader
import java.sql.CallableStatement
import java.sql.Clob
import java.sql.Connection
import java.sql.SQLException
import java.sql.Types
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.List
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathFactory
import org.oddgen.sqldev.dal.model.DatabaseGenerator
import org.springframework.dao.DataAccessException
import org.springframework.jdbc.BadSqlGrammarException
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.CallableStatementCallback
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Element
import org.w3c.dom.NodeList
import org.xml.sax.InputSource

@Loggable(prepend=true)
class DatabaseGeneratorDao {
	private Connection conn
	private JdbcTemplate jdbcTemplate

	new(Connection conn) {
		this.conn = conn
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
	}

	def private setName(DatabaseGenerator dbgen) {
		val plsql = '''
			BEGIN
				? := «dbgen.owner».«dbgen.objectName».get_name();
			END;
		'''
		try {
			dbgen.name = jdbcTemplate.execute(plsql, new CallableStatementCallback<String>() {
				override String doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.VARCHAR);
					cs.execute
					return cs.getString(1);
				}
			})
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
				dbgen.name = '''«dbgen.owner».«dbgen.objectName»'''
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			Logger.error(this, e.message)			
		}
	}

	def private setDescription(DatabaseGenerator dbgen) {
		val plsql = '''
			BEGIN
				? := «dbgen.owner».«dbgen.objectName».get_description();
			END;
		'''
		try {
			dbgen.description = jdbcTemplate.execute(plsql, new CallableStatementCallback<String>() {
				override String doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.VARCHAR);
					cs.execute
					return cs.getString(1);
				}
			})
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
				dbgen.description = dbgen.name
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			Logger.error(this, e.message)			
		}
	}

	def private setObjectTypes(DatabaseGenerator dbgen) {
		// convert PL/SQL nested table to comma separated list
		val plsql = '''
			DECLARE
			   l_result «dbgen.owner».«dbgen.objectName».t_string;
			   l_clob   CLOB;
			BEGIN
			   l_result := «dbgen.owner».«dbgen.objectName».get_object_types();
			   FOR i IN 1 .. l_result.count
			   LOOP
			      IF l_clob IS NOT NULL THEN
			         l_clob := l_clob || ',';
			      END IF;
			      l_clob := l_clob || l_result(i);
			   END LOOP;
			   ? := l_clob;
			END;
		'''
		dbgen.objectTypes = new ArrayList<String>()
		try {
			val typesClob = jdbcTemplate.execute(plsql, new CallableStatementCallback<Clob>() {
				override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.CLOB);
					cs.execute
					return cs.getClob(1);
				}
			})
			val typesString = typesClob.getSubString(1, typesClob.length as int)
			val List<String> types = Arrays.asList(typesString.split("\\s*,\\s*"));
			for (type : types) {
				dbgen.objectTypes.add(type)
			}
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
				dbgen.objectTypes.add("TABLE")
				dbgen.objectTypes.add("VIEW")
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			Logger.error(this, e.message)			
		}
	}

	def private setParams(DatabaseGenerator dbgen) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_params oddgen.plsql_view.t_param;
			   l_key    oddgen.plsql_view.param_type;
			   l_clob   CLOB;
			BEGIN
			   l_params := oddgen.plsql_view.get_params();
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
		dbgen.params = new HashMap<String, String>()
		try {
			val paramsClob = jdbcTemplate.execute(plsql, new CallableStatementCallback<Clob>() {
				override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.CLOB);
					cs.execute
					return cs.getClob(1);
				}
			})
			val paramsString = paramsClob.getSubString(1, paramsClob.length as int)
			val builder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
			val doc = builder.parse(new InputSource(new StringReader(paramsString)))
			val xpath = XPathFactory.newInstance().newXPath();
			val nodes = xpath.evaluate("/params/param", doc, XPathConstants.NODESET) as NodeList;
			for (var i = 0; i < nodes.length; i++) {
				val param = nodes.item(i) as Element
				val key = param.getElementsByTagName("key").item(0).textContent
				val value = param.getElementsByTagName("value").item(0).textContent
				dbgen.params.put(key, value)
			}
			
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			Logger.error(this, e.message)			
		}
	}
	
	def private setRefreshable(DatabaseGenerator dbgen) {
		val sql = '''
			SELECT COUNT(*)
			  FROM (SELECT *
			          FROM all_arguments
			         WHERE owner = '«dbgen.owner»'
			               AND package_name = '«dbgen.objectName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 0
			               AND in_out = 'OUT'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«dbgen.owner»'
			               AND type_name = '«dbgen.objectName»'
			               AND type_subname = 'T_LOV'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«dbgen.owner»'
			               AND package_name = '«dbgen.objectName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 1
			               AND in_out = 'IN'
			               AND argument_name = 'IN_PARAMS'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«dbgen.owner»'
			               AND type_name = '«dbgen.objectName»'
			               AND type_subname = 'T_PARAM')
		'''
		val count = jdbcTemplate.queryForObject(sql, Integer)
		if (count == 2) {
			dbgen.isRefreshable = true
		} else {
			dbgen.isRefreshable = false
		}
	}

	def findAll() {
		val sql = '''
			SELECT owner,
			       object_name,
			       MAX(generateHasInParams) AS hasParams
			  FROM (SELECT /*+no_merge */
			               func.owner,
			               func.object_name,
			               func.procedure_name,
			               nvl((SELECT 1
			                      FROM all_arguments arg
			                     WHERE arg.object_id = func.object_id
			                       AND arg.subprogram_id = func.subprogram_id
			                       AND arg.position = 3
			                       AND arg.argument_name = 'IN_PARAMS'
			                       AND in_out = 'IN'
			                       AND arg.data_type = 'PL/SQL TABLE'
			                       AND arg.type_subname = 'T_PARAM'), 0) AS generateHasInParams
			          FROM all_procedures func
			         WHERE func.procedure_name = 'GENERATE'
			           AND func.owner IN (SELECT username
			                                FROM all_users
			                               WHERE oracle_maintained = 'N')
			           AND EXISTS (SELECT 1
			                         FROM all_arguments arg
			                        WHERE arg.object_id = func.object_id
			                          AND arg.subprogram_id = func.subprogram_id
			                          AND arg.position = 0
			                          AND in_out = 'OUT'
			                          AND arg.data_type = 'CLOB')
			           AND EXISTS (SELECT 1
			                         FROM all_arguments arg
			                         WHERE arg.object_id = func.object_id
			                          AND arg.subprogram_id = func.subprogram_id
			                          AND arg.position = 1
			                          AND arg.argument_name = 'IN_OBJECT_TYPE'
			                          AND in_out = 'IN'
			                          AND arg.data_type = 'VARCHAR2')
			           AND EXISTS (SELECT 1
			                         FROM all_arguments arg
			                        WHERE arg.object_id = func.object_id
			                          AND arg.subprogram_id = func.subprogram_id
			                          AND arg.position = 2
			                          AND arg.argument_name = 'IN_OBJECT_NAME'
			                          AND in_out = 'IN'
			                          AND arg.data_type = 'VARCHAR2'))
			 GROUP BY owner, object_name
			 ORDER BY owner, object_name
		'''
		val dbgens = jdbcTemplate.query(sql, new BeanPropertyRowMapper<DatabaseGenerator>(DatabaseGenerator))
		for (dbgen : dbgens) {
			dbgen.setName
			dbgen.setDescription
			dbgen.setObjectTypes
			dbgen.setRefreshable
			dbgen.setParams
		}
		return dbgens
	}
}
