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

class GetObjectNamesTest extends AbstractJdbcTest {

	@Test
	def getUserObjectNamesTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val result = dao.getUserObjectNames("TABLE")
		Assert.assertEquals(4, result.size)
		Assert.assertEquals(#["BONUS", "DEPT", "EMP", "SALGRADE"], result)
	}

	@Test
	def getObjectNamesTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY"
		]
		val result = dbgen.getObjectNames(dataSource.connection, "TABLE")
		Assert.assertEquals(3, result.size)
		Assert.assertEquals(#["one", "two", "three"], result)
	}

	@Test
	def getObjectNamesDefaultTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY_DEFAULT"
		]
		val result = dbgen.getObjectNames(dataSource.connection, "TABLE")
		Assert.assertEquals(4, result.size)
		Assert.assertEquals(#["BONUS", "DEPT", "EMP", "SALGRADE"], result)
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
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   
			   FUNCTION get_object_types RETURN t_string;
			   
			   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy IS
			
			   FUNCTION get_object_types RETURN t_string IS 
			   BEGIN
			      RETURN NEW t_string('dummy');
			   END get_object_types; 
			
			   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string IS
			   BEGIN
			   RETURN NEW t_string('one', 'two', 'three');
			   END get_object_names;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy;
		''')
	}
}
