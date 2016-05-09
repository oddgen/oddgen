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
package org.oddgen.sqldev.ui.tests

import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.Toolkit
import java.util.ArrayList
import java.util.Properties
import javax.swing.JFrame
import javax.swing.JLabel
import javax.swing.SwingUtilities
import org.junit.BeforeClass
import org.junit.Test
import org.oddgen.sqldev.GenerateDialog
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.model.DatabaseGenerator
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class GenerateDialogTest {

	private static SingleConnectionDataSource dataSource
	private static JdbcTemplate jdbcTemplate

	@BeforeClass
	def static void setup() {
		// get properties
		val p = new Properties()
		p.load(GenerateDialogTest.getClass().getResourceAsStream("/test.properties"))		
		// create dataSource and jdbcTemplate
		dataSource = new SingleConnectionDataSource()
		dataSource.driverClassName = "oracle.jdbc.OracleDriver"
		dataSource.url = '''jdbc:oracle:thin:@«p.getProperty("host")»:«p.getProperty("port")»/«p.getProperty("service")»'''
		dataSource.username = p.getProperty("scott_username")
		dataSource.password = p.getProperty("scott_password")
		jdbcTemplate = new JdbcTemplate(dataSource)
	}

	@Test
	def void layoutTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen1 = dao.findAll.findFirst[it.generatorName == 'PLSQL_VIEW']
		dbgen1.objectType = 'TABLE'
		dbgen1.objectName = 'EMP'
		val dbgen2 = dbgen1.copy
		dbgen2.objectName = 'DEPT'
		val dbgens = new ArrayList<DatabaseGenerator>()
		dbgens.add(dbgen1)
		dbgens.add(dbgen2)
		val frame = new JFrame("Main")
		SwingUtilities.invokeAndWait(
			new Runnable() {
				override run() {
					frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE)
					frame.getContentPane().add(new JLabel(""), BorderLayout.CENTER)
					frame.preferredSize = new Dimension(200, 100)
					frame.pack
					val dim = Toolkit.getDefaultToolkit().getScreenSize();
					frame.setLocation(dim.width / 2 - frame.getSize().width / 2,
						dim.height / 2 - frame.getSize().height / 2);
					frame.setVisible(true)
				}
			});
		// show gui end exit
		GenerateDialog.createAndShow(frame, dbgens)
		Thread.sleep(4*1000)
	}
}
