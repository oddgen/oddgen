package org.oddgen.sqldev.dal.tests

import org.junit.AfterClass
import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.dal.ObjectNameDao
import org.oddgen.sqldev.model.ObjectType
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class ObjectNameTest {
	private static SingleConnectionDataSource dataSource
	private static JdbcTemplate jdbcTemplate
	
	@Test
	def findUserObjectNamesTest() {
		val dao = new ObjectNameDao(dataSource.connection)
		val objectType = new ObjectType()
		objectType.name = "TABLE"
		val result = dao.findUserObjectNames(objectType)
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("BONUS", result.get(0).name)
		Assert.assertEquals("DEPT", result.get(1).name)
		Assert.assertEquals("EMP", result.get(2).name)
		Assert.assertEquals("SALGRADE", result.get(3).name)
	}
	
	@Test
	def findObjectNamesTest() {
		val gendao = new DatabaseGeneratorDao(dataSource.connection)
		val namedao = new ObjectNameDao(dataSource.connection)
		val dbgen = gendao.findAll.findFirst [it. generatorOwner == dataSource.username.toUpperCase && it.generatorName == "PLSQL_DUMMY"]
		val objectType = new ObjectType()
		objectType.name = "TABLE"
		objectType.generator = dbgen
		val result = namedao.findObjectNames(objectType)
		Assert.assertEquals(3, result.size)
		Assert.assertEquals("one", result.get(0).name)
		Assert.assertEquals("two", result.get(1).name)
		Assert.assertEquals("three", result.get(2).name)
	}

	@Test
	def findObjectNamesDefaultTest() {
		val gendao = new DatabaseGeneratorDao(dataSource.connection)
		val namedao = new ObjectNameDao(dataSource.connection)
		val dbgen = gendao.findAll.findFirst [it. generatorOwner == dataSource.username.toUpperCase && it.generatorName == "PLSQL_DUMMY_DEFAULT"]
		val objectType = new ObjectType()
		objectType.name = "TABLE"
		objectType.generator = dbgen
		val result = namedao.findObjectNames(objectType)
		Assert.assertEquals(4, result.size)
		Assert.assertEquals("BONUS", result.get(0).name)
		Assert.assertEquals("DEPT", result.get(1).name)
		Assert.assertEquals("EMP", result.get(2).name)
		Assert.assertEquals("SALGRADE", result.get(3).name)
	}

	@BeforeClass
	def static void setup() {
		// create dataSource and jdbcTemplate
		dataSource = new SingleConnectionDataSource()
		dataSource.driverClassName = "oracle.jdbc.OracleDriver"
		dataSource.url = "jdbc:oracle:thin:@titisee.trivadis.com:1521/phspdb2"
		dataSource.username = "scott"
		dataSource.password = "tiger"
		jdbcTemplate = new JdbcTemplate(dataSource)

		// deploy PL/SQL packages 
		createPlsqlDummy
		createPlsqlDummyDefault
	}
	
	@AfterClass
	def static tearDown() {
		val jdbcTemplate = new JdbcTemplate(dataSource)
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy_default")
	}	

	def static createPlsqlDummy() {
		// create package specification of dummy generator with get_object_names function
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

		// create package body of dummy generator with get_object_names function
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
			      l_result CLOB;
			   BEGIN
			      l_result := in_object_type || '.' || in_object_name;
			      RETURN l_result;
			   END generate;
			END plsql_dummy;
		''')
	}

	def static createPlsqlDummyDefault() {
		// create package specification of dummy generator without get_object_names function
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy_default IS
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB;
			END plsql_dummy_default;
		''')

		// create package body of dummy generator without get_object_names function
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy_default IS
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2) RETURN CLOB IS
			      l_result CLOB;
			   BEGIN
			      l_result := in_object_type || '.' || in_object_name;
			      RETURN l_result;
			   END generate;
			END plsql_dummy_default;
		''')
	}



}
