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
package org.oddgen.sqldev.dal.tests

import java.util.LinkedHashMap
import org.junit.Assert
import org.junit.Test
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.generators.model.Node

class DatabaseGeneratorTest extends AbstractJdbcTest {

	@Test
	def plsqlViewDao() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgens = dao.findAll
		val plsqlView = dbgens.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_VIEW"
		]
		Assert.assertEquals("1:1 View (PL/SQL)", plsqlView.getName(dataSource.connection))
		Assert.assertEquals(
			"Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger. The generator is based on plain PL/SQL without a third party template engine.",
			plsqlView.getDescription(dataSource.connection))
		Assert.assertEquals("TABLE", plsqlView.getNodes(dataSource.connection, null).get(0).id)
		var params = plsqlView.getNodes(dataSource.connection, "TABLE").findFirst[true].params
		Assert.assertEquals(4, params.size)
		Assert.assertEquals(#["View suffix", "Table suffix to be replaced", "Generate instead-of-trigger?", "Instead-of-trigger suffix"], params.keySet.toList)
		Assert.assertEquals("_V", params.get("View suffix"))
		Assert.assertEquals("_T", params.get("Table suffix to be replaced"))
		Assert.assertEquals("_TRG", params.get("Instead-of-trigger suffix"))
		Assert.assertEquals("Yes", params.get("Generate instead-of-trigger?"))
		var nodes = plsqlView.getNodes(dataSource.connection, "TABLE").filter[it.id=="TABLE.DEPT"].toList
		var lovs = plsqlView.getLov(dataSource.connection, params, nodes)
		Assert.assertEquals(2, lovs.get("Generate instead-of-trigger?").size)
		Assert.assertEquals(#["Yes", "No"], lovs.get("Generate instead-of-trigger?"))
		var paramStates = plsqlView.getParamStates(dataSource.connection, params, nodes)
		Assert.assertEquals(1, paramStates.size)
		Assert.assertEquals(true, paramStates.get("Instead-of-trigger suffix"))
	}

	@Test
	def generateViewWithInsteadOfTrigger() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst[it.getMetaData.generatorName == 'PLSQL_VIEW']
		val expected = '''
			-- create 1:1 view for demonstration purposes
			CREATE OR REPLACE VIEW DEPT_V AS
			   SELECT DEPTNO,
			          DNAME,
			          LOC
			     FROM DEPT;
			-- create simple instead-of-trigger for demonstration purposes
			CREATE OR REPLACE TRIGGER DEPT_TRG
			   INSTEAD OF INSERT OR UPDATE OR DELETE ON DEPT_V
			BEGIN
			   IF INSERTING THEN
			      INSERT INTO DEPT (
			         DEPTNO,
			         DNAME,
			         LOC
			      ) VALUES (
			         :NEW.DEPTNO,
			         :NEW.DNAME,
			         :NEW.LOC
			      );
			   ELSIF UPDATING THEN
			      UPDATE DEPT
			         SET DEPTNO = :NEW.DEPTNO,
			             DNAME = :NEW.DNAME,
			             LOC = :NEW.LOC
			       WHERE DEPTNO = :OLD.DEPTNO;
			   ELSIF DELETING THEN
			      DELETE FROM DEPT
			       WHERE DEPTNO = :OLD.DEPTNO;
			   END IF;
			END;
			/
		'''	
		val node = new Node;
		node.id = "TABLE.DEPT"
		val generated = dbgen.generate(dataSource.connection, node)
		Assert.assertEquals(expected.trim, generated.trim)
	}

	@Test
	def generateViewWithoutInsteadOfTrigger() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst[it.getMetaData.generatorName == 'PLSQL_VIEW']
		val expected = '''
			-- create 1:1 view for demonstration purposes
			CREATE OR REPLACE VIEW EMP_V AS
			   SELECT EMPNO,
			          ENAME,
			          JOB,
			          MGR,
			          HIREDATE,
			          SAL,
			          COMM,
			          DEPTNO
			     FROM EMP;
		'''	
		val node = new Node;
		node.id = "TABLE.EMP"
		node.params = new LinkedHashMap<String, String>
		node.params.put("Generate instead-of-trigger?", "No");
		val generated = dbgen.generate(dataSource.connection, node)
		Assert.assertEquals(expected.trim, generated.trim)
	}

	@Test
	// test case for issue #32, check if single quotes in parameters are handled correctly
	// generated code is not valid code of course, but the test case is still useful
	def generateViewWithSingleQuoteInSuffix() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst[it.getMetaData.generatorName == 'PLSQL_VIEW']
		val expected = '''
			-- create 1:1 view for demonstration purposes
			CREATE OR REPLACE VIEW EMP_'V'' AS
			   SELECT EMPNO,
			          ENAME,
			          JOB,
			          MGR,
			          HIREDATE,
			          SAL,
			          COMM,
			          DEPTNO
			     FROM EMP;
		'''
		val node = new Node;
		node.id = "TABLE.EMP"
		node.params = new LinkedHashMap<String, String>
		node.params.put("Generate instead-of-trigger?", "No");
		node.params.put("View suffix", "_'V''") // handle one or multiple single quotes
		val generated = dbgen.generate(dataSource.connection, node)
		Assert.assertEquals(expected.trim, generated.trim)
	}

	@Test
	def generateHelloWorld() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == 'PLSQL_HELLO_WORLD'
		]
		val expected = '''
			BEGIN
			   sys.dbms_output.put_line('Hello VIEW EMP_V!');
			END;
			/
		'''
		val node = new Node;
		node.id = "VIEW.EMP_V"
		val generated = dbgen.generate(dataSource.connection, node)
		Assert.assertEquals(expected.trim, generated.trim)
	}

	@Test
	def generateError() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == 'PLSQL_HELLO_WORLD'
		]
		dbgen.getMetaData.generatorName = 'NON_EXISTING_PACKAGE'
		val expected = '''
			Failed to generate code for TYPE.NAME via SCOTT.NON_EXISTING_PACKAGE. Got the following error: ORA-06550: line 4, column 14:
			PLS-00201: identifier 'SCOTT.NON_EXISTING_PACKAGE' must be declared
			ORA-06550: line 4, column 4:
			PL/SQL: Statement ignored
		'''
		val node = new Node;
		node.id = "TYPE.NAME"
		val generated = dbgen.generate(dataSource.connection, node)
		Assert.assertEquals(expected.trim, generated?.trim)
	}
}
