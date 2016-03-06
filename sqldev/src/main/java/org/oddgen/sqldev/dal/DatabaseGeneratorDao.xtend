package org.oddgen.sqldev.dal

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
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
import org.oddgen.sqldev.dal.model.DatabaseGenerator
import org.springframework.dao.DataAccessException
import org.springframework.jdbc.BadSqlGrammarException
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.CallableStatementCallback
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Element
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
				? := «dbgen.generatorOwner».«dbgen.generatorName».get_name();
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
				dbgen.name = '''«dbgen.generatorOwner».«dbgen.generatorName»'''
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
				? := «dbgen.generatorOwner».«dbgen.generatorName».get_description();
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
			   l_result «dbgen.generatorOwner».«dbgen.generatorName».t_string;
			   l_clob   CLOB;
			BEGIN
			   l_result := «dbgen.generatorOwner».«dbgen.generatorName».get_object_types();
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
			val types = Arrays.asList(typesString.split("\\s*,\\s*"));
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
			   l_params «dbgen.generatorOwner».«dbgen.generatorName».t_param;
			   l_key    «dbgen.generatorOwner».«dbgen.generatorName».param_type;
			   l_clob   CLOB;
			BEGIN
			   l_params := «dbgen.generatorOwner».«dbgen.generatorName».get_params();
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
			val docBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
			val doc = docBuilder.parse(new InputSource(paramsClob.characterStream))
			val params = doc.getElementsByTagName("param")
			for (var i = 0; i < params.length; i++) {
				val param = params.item(i) as Element
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

	def private setLovs(DatabaseGenerator dbgen, Clob lovsClob) {
		dbgen.lovs.clear
		val docBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
		val doc = docBuilder.parse(new InputSource(lovsClob.characterStream))
		val lovs = doc.getElementsByTagName("lov")
		if (lovs.length > 0) {
			for (var i = 0; i < lovs.length; i++) {
				val lov = lovs.item(i) as Element
				val key = lov.getElementsByTagName("key").item(0).textContent
				val values = lov.getElementsByTagName("value")
				val value = new ArrayList<String>()
				for (var j = 0; j < values.length; j++) {
					val valueElement = values.item(j) as Element
					value.add(valueElement.textContent)
				}
				dbgen.lovs.put(key, value)
			}
		}
	}

	def private setLovs(DatabaseGenerator dbgen) {
		// convert PL/SQL associative array to XML
		val plsql = '''
			DECLARE
			   l_lovs «dbgen.generatorOwner».«dbgen.generatorName».t_lov;
			   l_key  «dbgen.generatorOwner».«dbgen.generatorName».param_type;
			   l_lov  «dbgen.generatorOwner».«dbgen.generatorName».t_string;
			   l_clob CLOB;
			BEGIN
			   l_lovs := «dbgen.generatorOwner».«dbgen.generatorName».get_lov();
			   l_key  := l_lovs.first;
			   l_clob := '<lovs>';
			   WHILE l_key IS NOT NULL
			   LOOP
			      l_clob := l_clob || '<lov><key>' || l_key || '</key><values>';
			      FOR i IN 1 .. l_lovs(l_key).count
			      LOOP
			         l_clob := l_clob || '<value>' || l_lovs(l_key) (i) || '</value>';
			      END LOOP;
			      l_clob := l_clob || '</values></lov>';
			      l_lovs.delete(l_key);
			      l_key := l_lovs.first;
			   END LOOP;
			   l_clob := l_clob || '</lovs>';
			   ? := l_clob;
			END;
		'''
		dbgen.lovs = new HashMap<String, List<String>>()
		try {
			val lovsClob = jdbcTemplate.execute(plsql, new CallableStatementCallback<Clob>() {
				override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.CLOB);
					cs.execute
					return cs.getClob(1);
				}
			})
			setLovs(dbgen, lovsClob)
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
			         WHERE owner = '«dbgen.generatorOwner»'
			               AND package_name = '«dbgen.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 0
			               AND in_out = 'OUT'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«dbgen.generatorOwner»'
			               AND type_name = '«dbgen.generatorName»'
			               AND type_subname = 'T_LOV'
			        UNION ALL
			        SELECT *
			          FROM all_arguments
			         WHERE owner = '«dbgen.generatorOwner»'
			               AND package_name = '«dbgen.generatorName»'
			               AND object_name = 'REFRESH_LOV'
			               AND position = 1
			               AND in_out = 'IN'
			               AND argument_name = 'IN_PARAMS'
			               AND data_type = 'PL/SQL TABLE'
			               AND type_owner = '«dbgen.generatorOwner»'
			               AND type_name = '«dbgen.generatorName»'
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
			SELECT owner                    AS generator_owner,
			       object_name              AS generator_name,
			       MAX(generateHasInParams) AS has_params
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
			dbgen.setLovs
		}
		return dbgens
	}

	def refresh(DatabaseGenerator dbgen) {
		if (dbgen.isRefreshable) {
			// convert PL/SQL associative array to XML
			// pass current parameter values as PL/SQL code
			val plsql = '''
				DECLARE
				   l_params «dbgen.generatorOwner».«dbgen.generatorName».t_param;
				   l_lovs   «dbgen.generatorOwner».«dbgen.generatorName».t_lov;
				   l_key    «dbgen.generatorOwner».«dbgen.generatorName».param_type;
				   l_lov    «dbgen.generatorOwner».«dbgen.generatorName».t_string;
				   l_clob   CLOB;
				BEGIN
				   «FOR key : dbgen.params.keySet»
				      l_params('«key»') := '«dbgen.params.get(key)»';
				   «ENDFOR»
				   l_lovs := «dbgen.generatorOwner».«dbgen.generatorName».refresh_lov(in_params => l_params);
				   l_key  := l_lovs.first;
				   l_clob := '<lovs>';
				   WHILE l_key IS NOT NULL
				   LOOP
				      l_clob := l_clob || '<lov><key>' || l_key || '</key><values>';
				      FOR i IN 1 .. l_lovs(l_key).count
				      LOOP
				         l_clob := l_clob || '<value>' || l_lovs(l_key) (i) || '</value>';
				      END LOOP;
				      l_clob := l_clob || '</values></lov>';
				      l_lovs.delete(l_key);
				      l_key := l_lovs.first;
				   END LOOP;
				   l_clob := l_clob || '</lovs>';
				   ? := l_clob;
				END;
			'''
			try {
				val lovsClob = jdbcTemplate.execute(plsql, new CallableStatementCallback<Clob>() {
					override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
						cs.registerOutParameter(1, Types.CLOB);
						cs.execute
						return cs.getClob(1);
					}
				})
				setLovs(dbgen, lovsClob)
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
	}

	def generate(DatabaseGenerator dbgen) {
		val plsql = '''
			DECLARE
			   «IF dbgen.hasParams»
			   	   l_params «dbgen.generatorOwner».«dbgen.generatorName».t_param;
			   «ENDIF»
			   l_clob   CLOB;
			BEGIN
			   «IF dbgen.hasParams»
			      «FOR key : dbgen.params.keySet»
			         l_params('«key»') := '«dbgen.params.get(key)»';
			   	  «ENDFOR»
			   «ENDIF»
			   l_clob := «dbgen.generatorOwner».«dbgen.generatorName».generate(
			                  in_object_type => '«dbgen.objectType»'
			                , in_object_name => '«dbgen.objectName»'
			                «IF dbgen.hasParams»
			                   , in_params      => l_params
			                «ENDIF»
			             );
			   ? := l_clob;
			END;
		'''
		var String result;
		try {
			val resultClob = jdbcTemplate.execute(plsql, new CallableStatementCallback<Clob>() {
				override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.CLOB);
					cs.execute
					return cs.getClob(1);
				}
			})
			result = resultClob.getSubString(1,
				resultClob.
					length as int)
			} catch (Exception e) {
				result = '''Failed to generate code via «dbgen.generatorOwner».«dbgen.generatorName». Got the following error: «e.message».'''
				Logger.error(this, result)
			}
			return result
		}
	}
