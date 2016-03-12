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
import oracle.ide.config.Preferences
import oracle.ide.model.UpdateMessage
import org.oddgen.sqldev.model.PreferenceModel

@Loggable
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

	@Loggable(value=LoggableConstants.DEBUG)
	override protected addButtons(JPanel panel, GridBagConstraints constraints) {
		// called during object construction, therefore no setter for addButtons
		if (ADD_BUTTONS) {
			super.addButtons(panel, constraints)
			Logger.debug(this, "super.addButtons called.")
		}
	}

	def refreshBackground() {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		if (conn != null) {
			val folder = RootNode.instance.dbServerGenerators
			folder.removeAll
			folder.close
			UpdateMessage.fireStructureChanged(folder)
			folder.markDirty(false)
		}
	}

	def void refresh() {
		val preferences = PreferenceModel.getInstance(Preferences.getPreferences());
		if (preferences.discoverPlsqlGenerators) {
			RootNode.instance.dbServerGenerators.openImpl
		} else {
			val Runnable runnable = [|refreshBackground]
			val thread = new Thread(runnable)
			thread.name = "oddgen Refresh Connection"
			thread.start
		}
	}

	override itemStateChanged(ItemEvent event) {
		checkConnection()
		if (event.stateChange == ItemEvent.SELECTED) {
			refresh()
		}
	}
}
