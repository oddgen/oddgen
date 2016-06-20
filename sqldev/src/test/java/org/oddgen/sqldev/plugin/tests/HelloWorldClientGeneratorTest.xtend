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
import org.oddgen.sqldev.dal.tests.AbstractJdbcTest
import org.oddgen.sqldev.generators.OddgenGenerator
import org.oddgen.sqldev.plugin.examples.HelloWorldClientGenerator

class HelloWorldClientGeneratorTest extends AbstractJdbcTest {
	static var OddgenGenerator gen

	@Test
	def getName() {
		Assert.assertEquals("Hello World", gen.getName(dataSource.connection))
	}

	@Test
	def getDescription() {
		Assert.assertEquals("Hello World example generator", gen.getDescription(dataSource.connection))
	}

	@Test
	def getObjectTypes() {
		val objectTypes = gen.getObjectTypes(dataSource.connection)
		Assert.assertEquals(#["TABLE", "VIEW"], objectTypes)
	}

	@Test
	def getObjectNamesTest() {
		val objectNames = gen.getObjectNames(dataSource.connection, "TABLE")
		Assert.assertEquals(#["BONUS", "DEPT", "EMP", "SALGRADE"], objectNames)
	}

	@Test
	def getParamsTest() {
		val params = gen.getParams(dataSource.connection, null, null)
		Assert.assertEquals(0, params.size)
	}

	@Test
	def getLov() {
		val lov = gen.getLov(dataSource.connection, null, null, null)
		Assert.assertEquals(0, lov.size)
	}

	@Test
	def getParamStates() {
		val paramStates = gen.getParamStates(dataSource.connection, null, null, null)
		Assert.assertEquals(0, paramStates.size)
	}

	@Test
	def generateTest() {
		val expected = '''
			BEGIN
			   sys.dbms_output.put_line('Hello TABLE EMP!');
			END;
			/
		'''
		val result = gen.generate(dataSource.connection, "TABLE", "EMP", null)
		Assert.assertEquals(expected.trim, result.trim)
	}

	@BeforeClass
	static def void setup() {
		gen = new HelloWorldClientGenerator
	}
}
