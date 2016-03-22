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

@Loggable
class DalTools {
	private Connection conn
	private JdbcTemplate jdbcTemplate

	new(Connection conn) {
		this.conn = conn
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
	}

	def removeCarriageReturns(String plsql) {
		// fix for issue #3: no CR in PL/SQL blocks on Ora DB 10.2 - see MOS note 1399110.1 for details.
		return plsql.replace("\r", "")
	}

	def getString(String plsql) {
		var String result = null
		try {
			result = jdbcTemplate.execute(plsql.removeCarriageReturns, new CallableStatementCallback<String>() {
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
			val paramsClob = jdbcTemplate.execute(plsql.removeCarriageReturns, new CallableStatementCallback<Clob>() {
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
