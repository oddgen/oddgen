package org.oddgen.sqldev.dal

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.sql.CallableStatement
import java.sql.Clob
import java.sql.Connection
import java.sql.SQLException
import java.sql.Types
import javax.xml.parsers.DocumentBuilderFactory
import org.springframework.dao.DataAccessException
import org.springframework.jdbc.BadSqlGrammarException
import org.springframework.jdbc.core.CallableStatementCallback
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Document
import org.xml.sax.InputSource

@Loggable(prepend=true)
class DalTools {
	private Connection conn
	private JdbcTemplate jdbcTemplate

	new(Connection conn) {
		this.conn = conn
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
	}

	def getString(String plsql) {
		var String result = null
		try {
			result = jdbcTemplate.execute(plsql, new CallableStatementCallback<String>() {
				override String doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.VARCHAR);
					cs.execute
					return cs.getString(1);
				}
			})
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			Logger.error(this, e.message)
		}
		return result
	}

	def getDoc(String plsql) {
		var Document doc = null
		try {
			val paramsClob = jdbcTemplate.execute(plsql, new CallableStatementCallback<Clob>() {
				override Clob doInCallableStatement(CallableStatement cs) throws SQLException, DataAccessException {
					cs.registerOutParameter(1, Types.CLOB);
					cs.execute
					return cs.getClob(1);
				}
			})
			val docBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
			doc = docBuilder.parse(new InputSource(paramsClob.characterStream))
		} catch (BadSqlGrammarException e) {
			if (e.cause.message.contains("PLS-00302")) {
				// catch component must be declared error
			} else {
				Logger.error(this, e.cause.message)
			}
		} catch (Exception e) {
			Logger.error(this, e.message)
		}
		return doc
	}

}
