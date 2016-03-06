package org.oddgen.sqldev.dal.tests

import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class DatabaseGeneratorTest {
	
	private static SingleConnectionDataSource dataSource
	
	@BeforeClass
	def static setup() {
		dataSource = new SingleConnectionDataSource()
		dataSource.driverClassName = "oracle.jdbc.OracleDriver"
		dataSource.url = "jdbc:oracle:thin:@titisee.trivadis.com:1521/phspdb2"
		dataSource.username = "oddgen"
		dataSource.password = "oddgen"
	}
		
	@Test
	def databaseGeneratDaoTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgens = dao.findAll
		Assert.assertTrue(dbgens.size == 8)
		val plsqlView = dbgens.findFirst[it.owner == "ODDGEN" && it.objectName == "PLSQL_VIEW"]
		Assert.assertTrue(plsqlView.hasParams)
		Assert.assertTrue(plsqlView.name == "1:1 View (PL/SQL)")
		Assert.assertTrue(plsqlView.description == "Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger.")
		Assert.assertTrue(plsqlView.objectTypes.size == 1)
		Assert.assertTrue(plsqlView.objectTypes.get(0) == "TABLES")
		Assert.assertTrue(plsqlView.params.get("View suffix") == "_V")
		Assert.assertTrue(plsqlView.params.get("Table suffix to be replaced") == "_T")
		Assert.assertTrue(plsqlView.params.get("Instead-of-trigger suffix") == "_TRG")
		Assert.assertTrue(plsqlView.params.get("Generate instead-of-trigger?") == "Yes")
		Assert.assertFalse(plsqlView.isRefreshable)
	}
}