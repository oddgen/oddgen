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

class GetParamsTest extends AbstractJdbcTest {

	@Test
	// deprecated get_params signature
	def getParams1Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY1"
		]
		val result = dao.getParams(dbgen.metaData, "someObjectType", "someObjectname");
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("First parameter", result.keySet.get(0))
		Assert.assertEquals("Second parameter", result.keySet.get(2))
		Assert.assertEquals("Third parameter", result.keySet.get(3))
		Assert.assertEquals("Fourth parameter", result.keySet.get(1))
		Assert.assertEquals("one", result.get("First parameter"))
		Assert.assertEquals("two", result.get("Second parameter"))
		Assert.assertEquals("three", result.get("Third parameter"))
		Assert.assertEquals("four", result.get("Fourth parameter"))
	}

	@Test
	// deprecated get_params signature and deprecated get_ordered_params signature
	def getParams2Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY2"
		]
		val result = dao.getParams(dbgen.metaData, "someObjectType", "someObjectname");
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("First parameter", result.keySet.get(0))
		Assert.assertEquals("Second parameter", result.keySet.get(1))
		Assert.assertEquals("Third parameter", result.keySet.get(2))
		Assert.assertEquals("Fourth parameter", result.keySet.get(3))
		Assert.assertEquals("one", result.get("First parameter"))
		Assert.assertEquals("two", result.get("Second parameter"))
		Assert.assertEquals("three", result.get("Third parameter"))
		Assert.assertEquals("four", result.get("Fourth parameter"))
	}

	@Test
	// current get_params without get_ordered_params
	def getParams3Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY3"
		]
		var result = dao.getParams(dbgen.metaData, "TABLE", "AbC");
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("First parameter", result.keySet.get(0))
		Assert.assertEquals("Second parameter", result.keySet.get(2))
		Assert.assertEquals("Third parameter", result.keySet.get(3))
		Assert.assertEquals("Fourth parameter", result.keySet.get(1))
		Assert.assertEquals("table.abc one", result.get("First parameter"))
		Assert.assertEquals("table.abc two", result.get("Second parameter"))
		Assert.assertEquals("table.abc three", result.get("Third parameter"))
		Assert.assertEquals("table.abc four", result.get("Fourth parameter"))
	}

	@Test
	// current get_params signature with deprecated get_ordered_params signature
	def getParams4Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY4"
		]
		var result = dao.getParams(dbgen.metaData, "TABLE", "AbC");
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("First parameter", result.keySet.get(0))
		Assert.assertEquals("Second parameter", result.keySet.get(1))
		Assert.assertEquals("Third parameter", result.keySet.get(2))
		Assert.assertEquals("Fourth parameter", result.keySet.get(3))
		Assert.assertEquals("table.abc one", result.get("First parameter"))
		Assert.assertEquals("table.abc two", result.get("Second parameter"))
		Assert.assertEquals("table.abc three", result.get("Third parameter"))
		Assert.assertEquals("table.abc four", result.get("Fourth parameter"))
	}

	@Test
	// current get_params signature with current get_ordered_params signature
	def getParams5Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY5"
		]
		var result = dao.getParams(dbgen.metaData, "TABLE", "AbC");
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("First parameter", result.keySet.get(0))
		Assert.assertEquals("Second parameter", result.keySet.get(1))
		Assert.assertEquals("Third parameter", result.keySet.get(2))
		Assert.assertEquals("Fourth parameter", result.keySet.get(3))
		Assert.assertEquals("table.abc one", result.get("First parameter"))
		Assert.assertEquals("table.abc two", result.get("Second parameter"))
		Assert.assertEquals("table.abc three", result.get("Third parameter"))
		Assert.assertEquals("table.abc four", result.get("Fourth parameter"))
		result = dao.getParams(dbgen.metaData, "VIEW", "AbC");
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("First parameter", result.keySet.get(3))
		Assert.assertEquals("Second parameter", result.keySet.get(2))
		Assert.assertEquals("Third parameter", result.keySet.get(1))
		Assert.assertEquals("Fourth parameter", result.keySet.get(0))
		Assert.assertEquals("view.abc one", result.get("First parameter"))
		Assert.assertEquals("view.abc two", result.get("Second parameter"))
		Assert.assertEquals("view.abc three", result.get("Third parameter"))
		Assert.assertEquals("view.abc four", result.get("Fourth parameter"))
	}

	@Test
	def getParamsDefaultTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY_DEFAULT"
		]
		val result = dao.getParams(dbgen.metaData, "someObjectType", "someObjectname");
		Assert.assertEquals(0, result.size)
	}

	@BeforeClass
	def static void setup() {
		createPlsqlDummy1
		createPlsqlDummy2
		createPlsqlDummy3
		createPlsqlDummy4
		createPlsqlDummy5
	}

	@AfterClass
	def static tearDown() {
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy1")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy2")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy3")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy4")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy5")
	}

	def static createPlsqlDummy1() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy1 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   
			   FUNCTION get_params RETURN t_param;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy1;
		''')

		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy1 IS
			
			   FUNCTION get_params RETURN t_param IS
			      l_params t_param;			   
			   BEGIN
			      l_params('First parameter') := 'one';
			      l_params('Second parameter') := 'two';
			      l_params('Third parameter') := 'three';
			      l_params('Fourth parameter') := 'four';
			      RETURN l_params;
			   END get_params;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy1;
		''')
	}

	def static createPlsqlDummy2() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy2 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   
			   FUNCTION get_params RETURN t_param;
			   
			   FUNCTION get_ordered_params RETURN t_string;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy2;
		''')

		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy2 IS
			
			   FUNCTION get_params RETURN t_param IS
			      l_params t_param;			   
			   BEGIN
			      l_params('First parameter') := 'one';
			      l_params('Second parameter') := 'two';
			      l_params('Third parameter') := 'three';
			      l_params('Fourth parameter') := 'four';
			      RETURN l_params;
			   END get_params;
			   
			   FUNCTION get_ordered_params RETURN t_string IS
			   BEGIN
			      RETURN NEW t_string('First parameter', 'Second parameter', 'Third parameter', 'Fourth parameter');
			   END get_ordered_params;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy2;
		''')
	}

	def static createPlsqlDummy3() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy3 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) 
			      RETURN t_param;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy3;
		''')

		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy3 IS
			
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_param IS
			      l_prefix string_type;
			      l_params t_param;			   
			   BEGIN
			      l_prefix := lower(in_object_type) || '.' || lower(in_object_name) || ' ';
			      l_params('First parameter') := l_prefix || 'one';
			      l_params('Second parameter') := l_prefix || 'two';
			      l_params('Third parameter') := l_prefix || 'three';
			      l_params('Fourth parameter') := l_prefix || 'four';
			      RETURN l_params;
			   END get_params;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy3;
		''')
	}

	def static createPlsqlDummy4() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy4 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) 
			      RETURN t_param;
			
			   FUNCTION get_ordered_params RETURN t_string;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy4;
		''')

		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy4 IS
			
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_param IS
			      l_prefix string_type;
			      l_params t_param;			   
			   BEGIN
			      l_prefix := lower(in_object_type) || '.' || lower(in_object_name) || ' ';
			      l_params('First parameter') := l_prefix || 'one';
			      l_params('Second parameter') := l_prefix || 'two';
			      l_params('Third parameter') := l_prefix || 'three';
			      l_params('Fourth parameter') := l_prefix || 'four';
			      RETURN l_params;
			   END get_params;

			   FUNCTION get_ordered_params RETURN t_string IS
			   BEGIN
			      RETURN NEW t_string('First parameter', 'Second parameter', 'Third parameter', 'Fourth parameter');
			   END get_ordered_params;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy4;
		''')
	}

	def static createPlsqlDummy5() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy5 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_param;
			
			   FUNCTION get_ordered_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_string;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy5;
		''')

		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy5 IS
			
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_param IS
			      l_prefix string_type;
			      l_params t_param;			   
			   BEGIN
			      l_prefix := lower(in_object_type) || '.' || lower(in_object_name) || ' ';
			      l_params('First parameter') := l_prefix || 'one';
			      l_params('Second parameter') := l_prefix || 'two';
			      l_params('Third parameter') := l_prefix || 'three';
			      l_params('Fourth parameter') := l_prefix || 'four';
			      RETURN l_params;
			   END get_params;

			   FUNCTION get_ordered_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_string IS
			   BEGIN
			      IF in_object_type = 'TABLE' THEN
			         RETURN NEW t_string('First parameter', 'Second parameter', 'Third parameter', 'Fourth parameter');
			      ELSE
			         RETURN NEW t_string('Fourth parameter', 'Third parameter', 'Second parameter', 'First parameter');
			      END IF;
			   END get_ordered_params;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy5;
		''')
	}
}
