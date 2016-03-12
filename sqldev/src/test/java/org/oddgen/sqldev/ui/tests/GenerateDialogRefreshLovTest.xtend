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
import javax.swing.JFrame
import javax.swing.JLabel
import javax.swing.SwingUtilities
import org.junit.AfterClass
import org.junit.BeforeClass
import org.junit.Test
import org.oddgen.sqldev.GenerateDialog
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.model.DatabaseGenerator
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class GenerateDialogRefreshLovTest {

	private static SingleConnectionDataSource dataSource
	private static JdbcTemplate jdbcTemplate

	@BeforeClass
	def static void setup() {
		// create dataSource and jdbcTemplate
		dataSource = new SingleConnectionDataSource()
		dataSource.driverClassName = "oracle.jdbc.OracleDriver"
		dataSource.url = "jdbc:oracle:thin:@titisee.trivadis.com:1521/phspdb2"
		dataSource.username = "oddgen"
		dataSource.password = "oddgen"
		jdbcTemplate = new JdbcTemplate(dataSource)

		// deploy PL/SQL packages 
		createPlsqlDummy
	}

	@Test
	def void refreshLovTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen1 = dao.findAll.findFirst[it.generatorName == 'PLSQL_DUMMY']
		dbgen1.objectType = 'TABLE'
		dbgen1.objectName = 'SOME_TABLE'
		val dbgens = new ArrayList<DatabaseGenerator>()
		dbgens.add(dbgen1)
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

	@AfterClass
	def static tearDown() {
		val jdbcTemplate = new JdbcTemplate(dataSource)
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy")
	}

	def static createPlsqlDummy() {
		// create package specification of dummy generator with refresh_lov function
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy AUTHID CURRENT_USER IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(30 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;
			
			   FUNCTION get_params RETURN t_param;
			
			   FUNCTION get_lov RETURN t_lov;
			
			   FUNCTION refresh_lov(in_object_type IN VARCHAR2,
			                        in_object_name IN VARCHAR2,
			                        in_params      IN t_param) RETURN t_lov;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2,
			                     in_params      IN t_param) RETURN CLOB;
			END plsql_dummy;
		''')

		// create package body of dummy generator with refresh_lov function
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy IS
			   FUNCTION get_params RETURN t_param IS
			      l_params t_param;
			   BEGIN
			      l_params('With children?') := 'Yes';
			      l_params('With grandchildren?') := 'Yes';
			      RETURN l_params;
			   END get_params;
			
			   FUNCTION get_lov RETURN t_lov IS
			      l_lov t_lov;
			   BEGIN
			      l_lov('With children?') := NEW t_string('Yes', 'No');
			      l_lov('With grandchildren?') := NEW t_string('Yes', 'No');
			      RETURN l_lov;
			   END get_lov;
			
			   FUNCTION refresh_lov(in_object_type IN VARCHAR2,
			                        in_object_name IN VARCHAR2,
			                        in_params      IN t_param) RETURN t_lov IS
			      l_lov t_lov;
			   BEGIN
			      l_lov('With children?') := NEW t_string('Yes', 'No');
			      IF in_params('With children?') = 'Yes' THEN
			         l_lov('With grandchildren?') := NEW t_string('Yes', 'No');
			      ELSE
			         l_lov('With grandchildren?') := NEW t_string('No');
			      END IF;
			      RETURN l_lov;
			   END refresh_lov;
			
			   FUNCTION generate(in_object_type IN VARCHAR2,
			                     in_object_name IN VARCHAR2,
			                     in_params      IN t_param) RETURN CLOB IS
			      l_result CLOB;
			   BEGIN
			      l_result := 'Object type: ' || in_object_type;
			      l_result := l_result || chr(10) || 'Object name: ' || in_object_name;
			      l_result := l_result || chr(10) || 'With children: ' || in_params('With children?');
			      l_result := l_result || chr(10) || 'With grandchildren: ' || in_params('With grandchildren?');
			      RETURN l_result;
			   END generate;
			END plsql_dummy;
		''')
	}
}
