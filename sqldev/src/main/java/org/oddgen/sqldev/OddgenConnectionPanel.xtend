package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.Container
import java.awt.GridBagConstraints
import java.awt.event.ItemEvent
import java.sql.Connection
import java.util.ArrayList
import java.util.List
import javax.swing.JComboBox
import javax.swing.JPanel
import oracle.dbtools.raptor.controls.ConnectionPanelUI
import oracle.dbtools.raptor.utils.Connections
import oracle.ide.net.URLFactory
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import oracle.ide.model.UpdateMessage

@Loggable(prepend=true)
class OddgenConnectionPanel extends ConnectionPanelUI {
	private static boolean ADD_BUTTONS = false

	def static protected List<JComboBox<?>> getComboBoxList(Container container) {
		val list = new ArrayList<JComboBox<?>>()
		for (comp : container.components) {
			if (comp instanceof JComboBox<?>) {
				list.add(comp as JComboBox<?>)
			} else if (comp instanceof Container) {
				list.addAll(getComboBoxList(comp as Container))
			}
		}
		Logger.debug(OddgenConnectionPanel, "JComboBox list: %s", list)
		return list
	}

	new() {
		// Oracle connections only, no details, no unshared connections
		// TODO: support non-Oracle connections
		super(#["oraJDBC"], false, false)
		val connComboBox = getComboBoxList(this).get(0) // alternative deprecated this.connCombo
		// ensure arrow keys do not throw ItemChangedState events
		connComboBox.putClientProperty("JComboBox.isTableCellEditor", Boolean.TRUE)
		connComboBox.selectedIndex = 0
	}

	@Loggable(value=LoggableConstants.DEBUG, prepend=true)
	override protected addButtons(JPanel panel, GridBagConstraints constraints) {
		// called during object construction, therefore no setter for addButtons
		if (ADD_BUTTONS) {
			super.addButtons(panel, constraints)
			Logger.debug(this, "super.addButtons called.")
		}
	}

	def protected openOrRefreshConnection() {
		try {
			val connectionInfo = Connections.instance.getConnectionInfo(connectionName)
			val alreadyOpen = Connections.instance.isConnectionOpen(connectionName)
			Logger.debug(this, "connectionInfo %s.", connectionInfo)
			Logger.debug(this, "isConnectionOpen %s.", alreadyOpen)
			val connName = connectionInfo.getProperty("ConnName")
			var Connection conn = null
			if (alreadyOpen) {
				Logger.debug(this, "connection %s is already open.", connName)
				conn = Connections.instance.getConnection(connectionName)
				Logger.debug(this, "connection %s reused.", connName)
			} else {
				Logger.debug(this, "connection %s is closed", connName)
				if (connectionInfo.getProperty("password") != null) {
					Logger.debug(this, "found a stored password for %s, trying to connect...", connName)
					conn = Connections.instance.getConnection(connectionName)
					Logger.debug(this, "connected to %s.", connName)
				}
			}
			if (conn != null) {
				val dao = new DatabaseGeneratorDao(conn)
				val dbgens = dao.findAll
				Logger.debug(this, "discovered %d database generators using connection %s.", dbgens.size, connName)
				val folder = RootNode.instance.dbServerGenerators
				folder.removeAll(true)
				for (dbgen : dbgens) {
					val node = new GeneratorNode(URLFactory.newURL(folder.URL, dbgen.name), dbgen)
					folder.add(node)
				}
				UpdateMessage.fireStructureChanged(folder)
				folder.expandNode
				folder.markDirty(false)
			}
		} catch (Exception e) {
			Logger.error(this, "Cannot open/refresh connection to %1$s. Got error %2$s.", connectionName, e.message)
		}
	}

	def refresh() {
		// run in own thread which might lead to odd behavior if the connection cannot be established
		val Runnable runnable = [|openOrRefreshConnection]
		val thread = new Thread(runnable)
		thread.name = "oddgen Connection Refresher"
		thread.start
	}

	override itemStateChanged(ItemEvent event) {
		checkConnection()
		if (event.stateChange == ItemEvent.SELECTED) {
			refresh()
		}
	}
}
