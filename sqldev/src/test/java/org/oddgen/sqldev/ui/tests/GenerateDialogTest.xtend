package org.oddgen.sqldev.ui.tests

import java.awt.BorderLayout
import java.awt.Dimension
import java.awt.Toolkit
import java.util.ArrayList
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
		// create dataSource and jdbcTemplate
		dataSource = new SingleConnectionDataSource()
		dataSource.driverClassName = "oracle.jdbc.OracleDriver"
		dataSource.url = "jdbc:oracle:thin:@titisee.trivadis.com:1521/phspdb2"
		dataSource.username = "scott"
		dataSource.password = "tiger"
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
