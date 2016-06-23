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

class GetParamStatesTest extends AbstractJdbcTest {

	@Test
	// deprecated refresh_param_states function
	def getParamStates1Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY1"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		var paramStates = dbgen.getParamStates(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(1, paramStates.size)
		Assert.assertEquals(true, paramStates.get("Second parameter"))
		params.put("First parameter", "not one")
		paramStates = dbgen.getParamStates(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(1, paramStates.size)
		Assert.assertEquals(false, paramStates.get("Second parameter"))
	}
	
	@Test
	// current get_param_states function
	def getParamStates2Test() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY2"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		var paramStates = dbgen.getParamStates(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(1, paramStates.size)
		Assert.assertEquals(true, paramStates.get("Second parameter"))
		params.put("First parameter", "not one")
		paramStates = dbgen.getParamStates(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(1, paramStates.size)
		Assert.assertEquals(false, paramStates.get("Second parameter"))
	}

	@Test
	// test case for issue #32
	def getParamStatesWithSingleQuotesInFirstParameterTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY2"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		params.put("First parameter", "'not'' one") // single quote must not cause another result
		val paramStates = dbgen.getParamStates(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(1, paramStates.size)
		Assert.assertEquals(false, paramStates.get("Second parameter"))
	}


	@Test
	def getLovDefaultTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY_DEFAULT"
		]
		val params = dbgen.getParams(dataSource.connection, null, null)
		val paramStates = dbgen.getParamStates(dataSource.connection, "someObjectType", "someObjectname", params);
		Assert.assertEquals(0, paramStates.size)
	}

	@BeforeClass
	def static void setup() {
		createPlsqlDummy1
		createPlsqlDummy2
	}

	@AfterClass
	def static tearDown() {
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy1")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy2")
	}

	def static createPlsqlDummy1() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy1 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) 
			      RETURN t_param;

			   FUNCTION refresh_param_states(in_object_type IN VARCHAR2,
			                                 in_object_name IN VARCHAR2,
			                                 in_params      IN t_param) RETURN t_param;
			
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

			   FUNCTION refresh_param_states(in_object_type IN VARCHAR2,
			   			                     in_object_name IN VARCHAR2,
			   			                     in_params      IN t_param) RETURN t_param IS
			      l_paramStates t_param;
			   BEGIN
			      If in_params('First parameter') = 'one' THEN
			         l_paramStates('Second parameter') := 'true';
			      ELSE
			         l_paramStates('Second parameter') := 'false';
			      END IF;
			      RETURN l_paramStates;
			   END refresh_param_states;

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
			   
			   FUNCTION get_params(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) 
			      RETURN t_param;

			   FUNCTION get_param_states(in_object_type IN VARCHAR2,
			                             in_object_name IN VARCHAR2,
			                             in_params      IN t_param) RETURN t_param;
			
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

			   FUNCTION get_param_states(in_object_type IN VARCHAR2,
			   			                 in_object_name IN VARCHAR2,
			   			                 in_params      IN t_param) RETURN t_param IS
			      l_paramStates t_param;
			   BEGIN
			      If in_params('First parameter') = 'one' THEN
			         l_paramStates('Second parameter') := 'true';
			      ELSE
			         l_paramStates('Second parameter') := 'false';
			      END IF;
			      RETURN l_paramStates;
			   END get_param_states;

			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy2;
		''')
	}
}
