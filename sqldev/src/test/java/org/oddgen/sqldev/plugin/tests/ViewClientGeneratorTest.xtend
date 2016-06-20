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
package org.oddgen.sqldev.plugin.tests

import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.dal.tests.AbstractJdbcTest
import org.oddgen.sqldev.generators.OddgenGenerator
import org.oddgen.sqldev.plugin.examples.ViewClientGenerator

class ViewClientGeneratorTest extends AbstractJdbcTest {
	static var OddgenGenerator gen
	static var OddgenGenerator dbgen

	private def dropTableIgnoreError(String tableName) {
		val sql = '''
			DROP TABLE «tableName»
		'''
		try {
			jdbcTemplate.execute(sql)
		} catch(Exception e) {
			// ignore, assumed not existing table
		}
	}

	@Test
	def getName() {
		Assert.assertEquals("1:1 View", gen.getName(dataSource.connection))
	}

	@Test
	def getDescription() {
		Assert.assertEquals(
			"Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger.",
			gen.getDescription(dataSource.connection))
	}

	@Test
	def getObjectTypes() {
		val objectTypes = gen.getObjectTypes(dataSource.connection)
		Assert.assertEquals(#["TABLE"], objectTypes)
	}

	@Test
	def getObjectNamesTest() {
		val objectNames = gen.getObjectNames(dataSource.connection, "TABLE")
		Assert.assertEquals(#["BONUS", "DEPT", "EMP", "SALGRADE"], objectNames)
	}

	@Test
	def getParamsTest() {
		val params = gen.getParams(dataSource.connection, null, null)
		Assert.assertEquals(4, params.size)
		Assert.assertEquals(#[
			ViewClientGenerator.VIEW_SUFFIX,
			ViewClientGenerator.TABLE_SUFFIX,
			ViewClientGenerator.GEN_IOT,
			ViewClientGenerator.IOT_SUFFIX
		], params.keySet.toList)
		Assert.assertEquals(#["_V", "_T", "Yes", "_TRG"], params.values.toList)
	}

	@Test
	def getLov() {
		val lov = gen.getLov(dataSource.connection, null, null, null)
		Assert.assertEquals(1, lov.size)
		Assert.assertEquals(#["Yes", "No"], lov.get(ViewClientGenerator.GEN_IOT))
	}

	@Test
	def getParamStates() {
		val params = gen.getParams(dataSource.connection, null, null)
		var paramStates = gen.getParamStates(dataSource.connection, null, null, params)
		Assert.assertEquals(1, paramStates.size)
		Assert.assertEquals(true, paramStates.get(ViewClientGenerator.IOT_SUFFIX))
		params.put(ViewClientGenerator.GEN_IOT, "No")
		paramStates = gen.getParamStates(dataSource.connection, null, null, params)
		Assert.assertEquals(false, paramStates.get(ViewClientGenerator.IOT_SUFFIX))
	}

	@Test
	def generateEmpDefaultTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "EMP")
		val dbgenResult = dbgen.generate(dataSource.connection, "TABLE", "EMP", params)
		val result = gen.generate(dataSource.connection, "TABLE", "EMP", params)
		Assert.assertEquals(dbgenResult, result)
	}

	@Test
	def generateEmpWithoutInsteadOfTriggerTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "EMP")
		params.put(ViewClientGenerator.GEN_IOT, "No")
		val dbgenResult = dbgen.generate(dataSource.connection, "TABLE", "EMP", params)
		val result = gen.generate(dataSource.connection, "TABLE", "EMP", params)
		Assert.assertEquals(dbgenResult, result)
	}

	@Test
	def generateCompoundPrimaryKeyTest() {
		dropTableIgnoreError("T")
		val sql = '''
			CREATE TABLE t (
			   c1 INTEGER NOT NULL,
			   c2 INTEGER NOT NULL,
			   c3 VARCHAR2(20) NOT NULL,
			   c4 VARCHAR2(20) NULL,
			   CONSTRAINT t_pk PRIMARY KEY (c2, c1)
			)
		'''
		jdbcTemplate.execute(sql)
		val params = gen.getParams(dataSource.connection, "TABLE", "T")
		val expected = '''
			-- create 1:1 view for demonstration purposes
			CREATE OR REPLACE VIEW T_V AS
			   SELECT C1,
			          C2,
			          C3,
			          C4
			     FROM T;
			-- create simple instead-of-trigger for demonstration purposes
			CREATE OR REPLACE TRIGGER T_TRG
			   INSTEAD OF INSERT OR UPDATE OR DELETE ON T_V
			BEGIN
			   IF INSERTING THEN
			      INSERT INTO T (
			         C1,
			         C2,
			         C3,
			         C4
			      ) VALUES (
			         :NEW.C1,
			         :NEW.C2,
			         :NEW.C3,
			         :NEW.C4
			      );
			   ELSIF UPDATING THEN
			      UPDATE T
			         SET C1 = :NEW.C1,
			             C2 = :NEW.C2,
			             C3 = :NEW.C3,
			             C4 = :NEW.C4
			       WHERE C2 = :OLD.C2
			         AND C1 = :OLD.C1;
			   ELSIF DELETING THEN
			      DELETE FROM T
			       WHERE C2 = :OLD.C2
			         AND C1 = :OLD.C1;
			   END IF;
			END;
			/
		'''
		val result = gen.generate(dataSource.connection, "TABLE", "T", params)
		dropTableIgnoreError("T")
		Assert.assertEquals(expected.trim, result.trim)
	}
	
	@Test
	def checkObjectTypeNotSupportedTest() {
		val params = gen.getParams(dataSource.connection, "VIEW", "EMP")
		val expected = '''<VIEW> is not a supported object type. Please use TABLE.'''
		val result = gen.generate(dataSource.connection, "VIEW", "EMP", params)
		Assert.assertEquals(expected, result)
	}

	@Test
	def checkParameterIsMissingTestTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "EMP")
		params.remove(ViewClientGenerator.VIEW_SUFFIX)
		val expected = '''Parameter <«ViewClientGenerator.VIEW_SUFFIX»> is missing.'''
		val result = gen.generate(dataSource.connection, "TABLE", "EMP", params)
		Assert.assertEquals(expected, result)
	}

	@Test
	def checkParameterIsNotKnownTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "EMP")
		params.put("test", "value")
		val expected = '''Parameter <test> is not known.'''
		val result = gen.generate(dataSource.connection, "TABLE", "EMP", params)
		Assert.assertEquals(expected, result)
	}

	@Test
	def checkParameterInvalidValueTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "EMP")
		params.put(ViewClientGenerator.GEN_IOT, "Maybe")
		val expected = '''Invalid value <Maybe> for parameter <«ViewClientGenerator.GEN_IOT»>. Valid values are: Yes, No.'''
		val result = gen.generate(dataSource.connection, "TABLE", "EMP", params)
		Assert.assertEquals(expected, result)
	}

	@Test
	def checkParameterTableNotFoundTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "XYZ")
		val expected = '''Table XYZ not found.'''
		val result = gen.generate(dataSource.connection, "TABLE", "XYZ", params)
		Assert.assertEquals(expected, result)
	}

	@Test
	def checkParameterViewMustBeNamedDifferentlyTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "EMP")
		params.put(ViewClientGenerator.VIEW_SUFFIX, "")
		val expected = '''Change <«ViewClientGenerator.VIEW_SUFFIX»>. The target view must be named differently than its base table.'''
		val result = gen.generate(dataSource.connection, "TABLE", "EMP", params)
		Assert.assertEquals(expected, result)
	}

	@Test
	def checkParameterNoPrimaryKeyTest() {
		val params = gen.getParams(dataSource.connection, "TABLE", "BONUS")
		val expected = '''No primary key found in table BONUS. Cannot generate instead-of-trigger.'''
		val result = gen.generate(dataSource.connection, "TABLE", "BONUS", params)
		Assert.assertEquals(expected, result)
	}

	@BeforeClass
	static def void setup() {
		gen = new ViewClientGenerator
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgens = dao.findAll
		dbgen = dbgens.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_VIEW"
		]
	}
}
