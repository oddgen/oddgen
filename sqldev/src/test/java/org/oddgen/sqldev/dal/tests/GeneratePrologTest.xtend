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

import org.junit.AfterClass
import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import org.oddgen.sqldev.dal.DatabaseGeneratorDao

class GeneratePrologTest extends AbstractJdbcTest {

	@Test
	def generateProlog() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE").filter[it.id == "TABLE.EMP" || it.id == "TABLE.DEPT"].toList
		val result =  dbgen.generateProlog(dataSource.connection, nodes)
		Assert.assertEquals("-- 2 nodes selected.", result)
	}

	@Test
	def generatePrologDefault() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY_DEFAULT"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE")
		val result = dbgen.generateProlog(dataSource.connection, nodes)
		Assert.assertEquals("", result)
	}

	@BeforeClass
	def static void setup() {
		createPlsqlDummy
	}

	@AfterClass
	def static tearDown() {
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy")
	}

	def static createPlsqlDummy() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy IS
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;

			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;
			END plsql_dummy;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy IS
			
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN '-- ' || in_nodes.count || ' nodes selected.';
			   END generate_prolog;

			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END;
			END plsql_dummy;
		''')
	}
}
