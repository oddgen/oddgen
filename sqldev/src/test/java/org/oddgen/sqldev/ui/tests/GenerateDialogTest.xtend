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
import org.junit.Test
import org.oddgen.sqldev.GenerateDialog
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.dal.tests.AbstractJdbcTest
import org.oddgen.sqldev.generators.DatabaseGenerator
import org.oddgen.sqldev.model.GeneratorSelection

class GenerateDialogTest extends AbstractJdbcTest {

	def getDatabaseSelection(DatabaseGenerator dbgen, String objectType, String objectName) {
		val gensel = new GeneratorSelection()
		gensel.generator = dbgen
		gensel.node = 	dbgen.getNodes(dataSource.connection, null).filter[it.id == "TABLE"].get(0)
		return gensel
	}

	@Test
	def void layoutTest() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst[it.metaData.generatorName == 'PLSQL_VIEW']
		val gensel1 = getDatabaseSelection(dbgen, "TABLE", "EMP")
		val gensel2 = getDatabaseSelection(dbgen, "TABLE", "DEPT")
		val gens = new ArrayList<GeneratorSelection>()
		gens.add(gensel1)
		gens.add(gensel2)
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
		GenerateDialog.createAndShow(frame, gens, dataSource.connection)
		Thread.sleep(2 * 1000)
	}
}
