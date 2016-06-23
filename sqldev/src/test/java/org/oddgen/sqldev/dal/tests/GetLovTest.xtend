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

class GetLovTest extends AbstractJdbcTest {

	@Test
	// deprecated get_lov signature
	def getLov1Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY1"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		val lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two", "three"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
	}
	
	@Test
	// deprecated refresh_lov function
	def getLov2Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY2"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		var lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two", "three"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
		params.put("Second parameter", "no")
		lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
	}

	@Test
	// deprecated get_lov signature and deprecated refresh_lov function
	def getLov3Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY3"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		var lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two", "three"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
		params.put("Second parameter", "no")
		lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
	}

	@Test
	// current get_lov signature 
	def getLov4Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY4"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		var lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two", "three"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
		params.put("Second parameter", "no")
		lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
	}

	@Test
	// test case for issue #32
	def getLov4WithSingleQuotesInFirstParameterTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY4"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		params.put("First Parameter", "'cause") // single quote must not cause another result
		var lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two", "three"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
		params.put("Second parameter", "no")
		lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(2, lov.size)
		Assert.assertEquals(#["one", "two"], lov.get("First parameter"))
		Assert.assertEquals(#["yes", "no"], lov.get("Second parameter"))
	}


	@Test
	def getLovDefaultTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY_DEFAULT"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		val lov = dbgen.getLov(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(0, lov.size)
	}

	@BeforeClass
	def static void setup() {
		createPlsqlDummy1
		createPlsqlDummy2
		createPlsqlDummy3
		createPlsqlDummy4
	}

	@AfterClass
	def static tearDown() {
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy1")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy2")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy3")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy4")
	}

	def static createPlsqlDummy1() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy1 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;
			   
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) 
			      RETURN t_param;

			   FUNCTION get_lov RETURN t_lov;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy1;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy1 IS
			
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_param IS
			      l_params t_param;
			   BEGIN
			      l_params('First parameter') := 'one';
			      l_params('Second parameter') := 'yes';
			      l_params('Third parameter') := 'three';
			      RETURN l_params;
			   END get_params;

			   FUNCTION get_lov RETURN t_lov IS
			      l_lov t_lov;
			   BEGIN
			      l_lov('First parameter') := NEW t_string ('one', 'two', 'three');
			      l_lov('Second parameter') := NEW t_string ('yes', 'no');
			      RETURN l_lov;
			   END get_lov;

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
			   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

			   FUNCTION refresh_lov(in_object_type IN VARCHAR2,
			                        in_object_name IN VARCHAR2,
			                        in_params      IN t_param) RETURN t_lov;

			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) 
			      RETURN t_param;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy2;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy2 IS
			
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_param IS
			      l_params t_param;
			   BEGIN
			      l_params('First parameter') := 'one';
			      l_params('Second parameter') := 'yes';
			      l_params('Third parameter') := 'three';
			      RETURN l_params;
			   END get_params;


			   FUNCTION refresh_lov(in_object_type IN VARCHAR2,
			                        in_object_name IN VARCHAR2,
			                        in_params      IN t_param) RETURN t_lov IS
			      l_lov t_lov;
			   BEGIN
			      IF in_params('Second parameter') = 'yes' THEN
			         l_lov('First parameter') := NEW t_string ('one', 'two', 'three');
			      ELSE
			         l_lov('First parameter') := NEW t_string ('one', 'two');
			      END IF;
			      l_lov('Second parameter') := NEW t_string ('yes', 'no');
			      RETURN l_lov;
			   END refresh_lov;

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
			   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

			   FUNCTION get_lov RETURN t_lov;

			   FUNCTION refresh_lov(in_object_type IN VARCHAR2,
			                        in_object_name IN VARCHAR2,
			                        in_params      IN t_param) RETURN t_lov;

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
			      l_params t_param;
			   BEGIN
			      l_params('First parameter') := 'one';
			      l_params('Second parameter') := 'yes';
			      l_params('Third parameter') := 'three';
			      RETURN l_params;
			   END get_params;

			   FUNCTION get_lov RETURN t_lov IS
			      l_lov t_lov;
			   BEGIN
			      l_lov('First parameter') := NEW t_string ('ignore one', 'ignore two', 'ignore three');
			      l_lov('Second parameter') := NEW t_string ('irrelevant 1', 'irrelevant 2');
			      l_lov('Third parameter') := NEW t_string ('bla bla', 'bla bla bla');
			      RETURN l_lov;
			   END get_lov;

			   FUNCTION refresh_lov(in_object_type IN VARCHAR2,
			                        in_object_name IN VARCHAR2,
			                        in_params      IN t_param) RETURN t_lov IS
			      l_lov t_lov;
			   BEGIN
			      IF in_params('Second parameter') = 'yes' THEN
			         l_lov('First parameter') := NEW t_string ('one', 'two', 'three');
			      ELSE
			         l_lov('First parameter') := NEW t_string ('one', 'two');
			      END IF;
			      l_lov('Second parameter') := NEW t_string ('yes', 'no');
			      RETURN l_lov;
			   END refresh_lov;

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
			   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

			   FUNCTION get_lov(in_object_type IN VARCHAR2,
			                    in_object_name IN VARCHAR2,
			                    in_params      IN t_param) RETURN t_lov;

			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) 
			      RETURN t_param;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                  in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy4;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy4 IS
			
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2)
			      RETURN t_param IS
			      l_params t_param;
			   BEGIN
			      l_params('First parameter') := 'one';
			      l_params('Second parameter') := 'yes';
			      l_params('Third parameter') := 'three';
			      RETURN l_params;
			   END get_params;

			   FUNCTION get_lov(in_object_type IN VARCHAR2,
			                    in_object_name IN VARCHAR2,
			                    in_params      IN t_param) RETURN t_lov IS
			      l_lov t_lov;
			   BEGIN
			      IF in_params('Second parameter') = 'yes' THEN
			         l_lov('First parameter') := NEW t_string ('one', 'two', 'three');
			      ELSE
			         l_lov('First parameter') := NEW t_string ('one', 'two');
			      END IF;
			      l_lov('Second parameter') := NEW t_string ('yes', 'no');
			      RETURN l_lov;
			   END get_lov;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy4;
		''')
	}
}
