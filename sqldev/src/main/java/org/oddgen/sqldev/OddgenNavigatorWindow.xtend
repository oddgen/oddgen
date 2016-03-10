package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.Component
import java.awt.Dimension
import java.awt.event.ActionEvent
import java.awt.event.ActionListener
import java.sql.Connection
import oracle.dbtools.raptor.utils.Connections
import oracle.ide.Context
import oracle.ide.controller.ContextMenu
import oracle.ide.controls.Toolbar
import oracle.ide.util.MnemonicSolver
import oracle.ide.util.PropertyAccess
import oracle.ideri.navigator.DefaultNavigatorWindow
import oracle.javatools.ui.table.ToolbarButton
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(prepend=true)
class OddgenNavigatorWindow extends DefaultNavigatorWindow implements ActionListener {
	private Component gui
	private ContextMenu contextMenu
	private Toolbar tb
	private ToolbarButton refreshButton
	private ToolbarButton collapseallButton
	private OddgenConnectionPanel connectionPanel
	private OddgenNavigatorViewController controller

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

	@Loggable(value=LoggableConstants.DEBUG, prepend=true)
	def protected createToolbar() {
		if (tb != null) {
			tb.dispose
		}
		if (connectionPanel == null) {
			connectionPanel = new OddgenConnectionPanel()
			connectionPanel.connectionPrompt = null
			connectionPanel.connectionLabel = null
			connectionPanel.maximumSize = new Dimension(300, 50)
			connectionPanel.minimumSize = new Dimension(100, 0)
			refreshButton = new ToolbarButton(OddgenResources.getIcon("REFRESH_ICON"))
			collapseallButton = new ToolbarButton(OddgenResources.getIcon("COLLAPSEALL_ICON"))
		}
		toolbarVisible = true
		tb = toolbar
		tb?.add(connectionPanel)
		tb?.add(refreshButton)
		tb?.add(collapseallButton)
		refreshButton.addActionListener(this)
		collapseallButton.addActionListener(this)
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
			controller = new OddgenNavigatorViewController()
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

	override actionPerformed(ActionEvent e) {
		if (e.source == refreshButton) {
			connectionPanel.refresh
		} else if (e.source == collapseallButton) {
			RootNode.instance.collapseall
		}
	}

	def getConnectionName() {
		return connectionPanel.connectionName
	}

	def getConnection() {
		var Connection conn = null
		try {
			val connectionInfo = Connections.instance.getConnectionInfo(connectionName)
			val alreadyOpen = Connections.instance.isConnectionOpen(connectionName)
			Logger.debug(this, "connectionInfo %s.", connectionInfo)
			Logger.debug(this, "isConnectionOpen %s.", alreadyOpen)
			val connName = connectionInfo.getProperty("ConnName")
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
		} catch (Exception e) {
			Logger.error(this, "Cannot open/refresh connection to %1$s. Got error %2$s.", connectionName, e.message)
		}
		return conn
	}

}
