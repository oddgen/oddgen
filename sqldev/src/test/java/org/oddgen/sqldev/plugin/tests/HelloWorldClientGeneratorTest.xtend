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
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.plugin.examples.HelloWorldClientGenerator

class HelloWorldClientGeneratorTest extends AbstractJdbcTest {
	static var OddgenGenerator2 gen

	@Test
	def getName() {
		Assert.assertEquals("Hello World", gen.getName(dataSource.connection))
	}

	@Test
	def getDescription() {
		Assert.assertEquals("Hello World example generator", gen.getDescription(dataSource.connection))
	}
	
	@Test
	def getFolders() {
		Assert.assertEquals(#["Examples", "Xtend"], gen.getFolders(dataSource.connection))
	}	

	@Test
	def getHelp() {
		Assert.assertEquals("<p>Hello World example generator</p>", gen.getHelp(dataSource.connection))
	}	

	@Test
	def getNodes_Level1() {
		val nodes = gen.getNodes(dataSource.connection, null).filter[it.parentId === null || it.parentId.empty]
		val names = nodes.sortBy[it.id].map[it.id].toList
		Assert.assertEquals(2, nodes.size)
		Assert.assertEquals(#["TABLE", "VIEW"], names)
	}

	@Test
	def getNodes_Level2() {
		val nodes = gen.getNodes(dataSource.connection, null).filter[it.parentId !== null]
		val names = nodes.sortBy[it.id].map[it.id.split("\\.").get(1)].toList
		Assert.assertEquals(4, nodes.size)
		Assert.assertEquals(#["BONUS", "DEPT", "EMP", "SALGRADE"], names)
	}

	@Test
	def getLov() {
		val node = gen.getNodes(dataSource.connection, null).get(0)
		val lov = gen.getLov(dataSource.connection, node.params, null)
		Assert.assertEquals(0, lov.size)
	}

	@Test
	def getParamStates() {
		val node = gen.getNodes(dataSource.connection, null).get(0)
		val paramStates = gen.getParamStates(dataSource.connection, node.params, null)
		Assert.assertEquals(0, paramStates.size)
	}
	
	@Test
	def generateProlog() {
		val nodes = gen.getNodes(dataSource.connection, null).filter[it.parentId == "TABLE"].toList
		val expected = '''
			BEGIN
			   -- 4 nodes selected.
		'''
		val result = gen.generateProlog(dataSource.connection, nodes)
		Assert.assertEquals(expected, result)		
	}

	@Test
	def generateSeparator() {
		val result = gen.generateSeparator(dataSource.connection)
		Assert.assertEquals("", result)		
	}

	@Test
	def generateEpilog() {
		val nodes = gen.getNodes(dataSource.connection, null).filter[it.parentId == "TABLE"].toList
		val expected = '''
			«'   '»-- 4 nodes generated in 1.234 ms.
			END;
			/
		'''
		val result = gen.generateEpilog(dataSource.connection, nodes)
		Assert.assertEquals(expected, result.replaceAll("[0-9]+\\.[0-9]{3}", "1.234"))		
	}

	@Test
	def generate() {
		val node = gen.getNodes(dataSource.connection, null).findFirst[it.id == "TABLE.EMP"]
		val expected = '''
			«'   '»sys.dbms_output.put_line('Hello TABLE EMP!');
		'''
		val result = gen.generate(dataSource.connection, node)
		Assert.assertEquals(expected, result)
	}

	@Test
	def generate4Nodes() {
		val nodes = gen.getNodes(dataSource.connection, null).filter[it.parentId == "TABLE"].sortBy[it.id].toList
		val expected = '''
			BEGIN
			   -- 4 nodes selected.
			   sys.dbms_output.put_line('Hello TABLE BONUS!');
			   sys.dbms_output.put_line('Hello TABLE DEPT!');
			   sys.dbms_output.put_line('Hello TABLE EMP!');
			   sys.dbms_output.put_line('Hello TABLE SALGRADE!');
			   -- 4 nodes generated in 1.234 ms.
			END;
			/
		'''
		val result = '''
			«gen.generateProlog(dataSource.connection, nodes)»
			«FOR node : nodes»
				«gen.generate(dataSource.connection, node)»«gen.generateSeparator(dataSource.connection)»
			«ENDFOR»
			«gen.generateEpilog(dataSource.connection, nodes)»
		'''
		Assert.assertEquals(expected, result.replaceAll("[0-9]+\\.[0-9]{3}", "1.234"))
	}

	@BeforeClass
	static def void setup() {
		gen = new HelloWorldClientGenerator
	}
}
