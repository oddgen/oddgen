package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.Container
import java.awt.GridBagConstraints
import java.awt.event.ItemEvent
import java.sql.DriverManager
import java.util.ArrayList
import java.util.List
import javax.swing.JComboBox
import javax.swing.JPanel
import oracle.dbtools.raptor.controls.ConnectionPanelUI

import static java.sql.DriverManager.*

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
		connComboBox.putClientProperty("JComboBox.isTableCellEditor", Boolean.TRUE);
	}

	@Loggable(value=LoggableConstants.DEBUG, prepend=true)
	override protected void addButtons(JPanel panel, GridBagConstraints constraints) {
		// called during object construction, therefore no setter for addButtons
		if (ADD_BUTTONS) {
			super.addButtons(panel, constraints)
			Logger.debug(this, "super.addButtons called.")
		}
	}

	def protected openConnection() {
		val prevLoginTimeout = DriverManager.loginTimeout
		DriverManager.loginTimeout = 5
		Logger.debug(this, "login timeout reset set to %d", DriverManager.loginTimeout)
		try {
			val connectionInfo = s_conns.getConnectionInfo(connectionName)
			Logger.debug(this, "connectionInfo %s", connectionInfo)
			if (connectionInfo != null) {
				// connection information available, so let's try to connect
				Logger.debug(this, "connection resolver class %1$s for connection name %2$s of type %3$s",
					s_conns.class, connectionName, s_conns.getConnectionType(connectionName))
				val conn = s_conns.getConnection(connectionName)
				Logger.debug(this, "connected to %s", conn)
				if (conn != null) {
					if (conn.closed) {
						// TODO:
					}
				}
			}
		} catch (Exception e) {
			Logger.error(this, "Cannot connect to %1$s. Got error %2$s.", connectionName, e.message)
		} finally {
			DriverManager.loginTimeout = prevLoginTimeout
			Logger.debug(this, "login timeout reset to original value oft %d", prevLoginTimeout)
		}
	}

	override itemStateChanged(ItemEvent event) {
		if (event.stateChange == ItemEvent.SELECTED) {
			checkConnection();
			val Runnable runnable = [|openConnection]
			val thread = new Thread(runnable)
			thread.name = "oddgen Connection Opener"
			thread.start
		}
	}
}