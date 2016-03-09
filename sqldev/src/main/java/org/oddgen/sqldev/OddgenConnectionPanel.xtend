package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.Container
import java.awt.GridBagConstraints
import java.awt.event.ItemEvent
import java.util.ArrayList
import java.util.List
import javax.swing.JComboBox
import javax.swing.JPanel
import oracle.dbtools.raptor.controls.ConnectionPanelUI

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

	def refresh() {
		RootNode.instance.dbServerGenerators.openImpl
	}

	override itemStateChanged(ItemEvent event) {
		checkConnection()
		if (event.stateChange == ItemEvent.SELECTED) {
			refresh()
		}
	}
}
