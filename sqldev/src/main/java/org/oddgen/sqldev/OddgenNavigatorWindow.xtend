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
import java.awt.Component
import java.awt.event.ActionEvent
import java.awt.event.ActionListener
import java.sql.Connection
import javax.swing.DefaultComboBoxModel
import oracle.dbtools.raptor.utils.ConnectionDetails
import oracle.dbtools.raptor.utils.ConnectionDisconnectListener
import oracle.dbtools.raptor.utils.Connections
import oracle.dbtools.raptor.utils.DisconnectVetoException
import oracle.dbtools.worksheet.editor.ConnComboBox
import oracle.ide.Context
import oracle.ide.config.Preferences
import oracle.ide.controller.ContextMenu
import oracle.ide.controls.Toolbar
import oracle.ide.model.UpdateMessage
import oracle.ide.util.MnemonicSolver
import oracle.ide.util.PropertyAccess
import oracle.ideri.navigator.DefaultNavigatorWindow
import oracle.javatools.ui.table.ToolbarButton
import org.oddgen.sqldev.model.PreferenceModel
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class OddgenNavigatorWindow extends DefaultNavigatorWindow implements ActionListener, ConnectionDisconnectListener {
	private Component gui
	private ContextMenu contextMenu
	private Toolbar tb
	private ToolbarButton refreshButton
	private ToolbarButton collapseallButton
	private ConnComboBox connComboBox;
	private OddgenNavigatorController controller

	new(Context context, String string) {
		super(context, string)
	}

	def protected intitializeContextMenu() {
		contextMenu = new ContextMenu(new MnemonicSolver());
		contextMenu.addContextMenuListener(OddgenNavigatorContextMenu.instance)
	}

	def protected initialize() {
		createToolbar
		intitializeContextMenu
		Logger.info(this, "OddgenNavigatorWindow initialized")
	}

	@Loggable(value=LoggableConstants.DEBUG)
	def protected createToolbar() {
		if (tb != null) {
			tb.removeAll
			tb.dispose
			RootNode.instance.clientGenerators.removeAll(true)
			RootNode.instance.dbServerGenerators.removeAll(true)
			RootNode.instance.clientGenerators.markDirty(false)
			RootNode.instance.dbServerGenerators.markDirty(false)
		}
		connComboBox = new ConnComboBox()
		refreshButton = new ToolbarButton(OddgenResources.getIcon("REFRESH_ICON"))
		collapseallButton = new ToolbarButton(OddgenResources.getIcon("COLLAPSEALL_ICON"))
		toolbarVisible = true
		tb = toolbar
		tb?.add(connComboBox.JComboBox)
		tb?.add(refreshButton)
		tb?.add(collapseallButton)
		connComboBox.addActionListener(this)
		refreshButton.addActionListener(this)
		collapseallButton.addActionListener(this)
		Connections.instance.addConnectionDisconnectListener(this)
	}

	override getGUI() {
		if (gui == null) {
			gui = super.getGUI()
			initialize()
		}
		return gui
	}

	override getController() {
		if (controller == null) {
			controller = new OddgenNavigatorController()
		}
		return controller;
	}

	override getContextMenu() {
		return contextMenu
	}

	override getTitleName() {
		return OddgenResources.getString("NAVIGATOR_TITLE")
	}

	override show() {
		createToolbar
		super.show()
		Logger.info(this, "OddgenNavigatorWindow shown")
	}

	override saveLayout(PropertyAccess p) {
		super.saveLayout(p)
	}

	override loadLayout(PropertyAccess p) {
		super.loadLayout(p)
	}

	@Loggable(LoggableConstants.DEBUG)
	override actionPerformed(ActionEvent e) {
		if (e.source == connComboBox.JComboBox) {
			val selection = connComboBox.JComboBox.selectedItem as String
			connComboBox.currentConnection = selection
			if (selection != null) {
				refreshConnection
			}
		} else if (e.source == refreshButton) {
			repopulateConnections
			refreshConnection
		} else if (e.source == collapseallButton) {
			RootNode.instance.collapseall
		}
	}

	override checkDisconnect(ConnectionDetails connectionDetails) throws DisconnectVetoException {
	}

	@Loggable(LoggableConstants.DEBUG)
	override connectionDisconnected(ConnectionDetails connectionDetails) {
		if (connectionDetails.qualifiedConnectionName == connComboBox.JComboBox.model.selectedItem as String) {
			connComboBox.currentConnection = null
			refreshConnection
		}
	}

	def getConnectionName() {
		return connComboBox.JComboBox.selectedItem as String
	}

	def getConnection() {
		var Connection conn = null
		if (connectionName != null) {
			try {
				val connectionInfo = Connections.instance.getConnectionInfo(connectionName)
				val alreadyOpen = Connections.instance.isConnectionOpen(connectionName)
				val connName = connectionInfo.getProperty("ConnName")
				if (alreadyOpen) {
					conn = Connections.instance.getConnection(connectionName)
					Logger.debug(this, "connection %s reused.", connName)
				} else {
					conn = Connections.instance.getConnection(connectionName)
					Logger.debug(this, "connected to %s.", connName)
				}
			} catch (Exception e) {
				Logger.error(this, "Cannot open/refresh connection to %1$s. Got error %2$s.", connectionName, e.message)
			}
		}
		return conn
	}

	def refreshConnection() {
		val preferences = PreferenceModel.getInstance(Preferences.getPreferences());
		RootNode.instance.clientGenerators.openImpl
		if (preferences.discoverPlsqlGenerators) {
			RootNode.instance.dbServerGenerators.openImpl
		} else {
			val folder = RootNode.instance.dbServerGenerators
			folder.removeAll
			folder.close
			UpdateMessage.fireStructureChanged(folder)
			folder.markDirty(false)
		}
	}

	def repopulateConnections() {
		connComboBox.JComboBox.removeActionListener(this)
		val model = connComboBox.JComboBox.model as DefaultComboBoxModel<String>
		val selection = model.selectedItem as String
		model.removeAllElements
		for (name : Connections.instance.connNames) {
			model.addElement(name)
		}
		connComboBox.currentConnection = selection
		connComboBox.JComboBox.addActionListener(this)
		Logger.debug(this, "repopulated connections and set selection to %s", selection)
	}
}
