package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.Component
import java.awt.Dimension
import oracle.ide.Context
import oracle.ide.controls.Toolbar
import oracle.ide.util.PropertyAccess
import oracle.ideri.navigator.DefaultNavigatorWindow
import oracle.javatools.ui.table.ToolbarButton
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(prepend=true)
class OddgenNavigatorWindow extends DefaultNavigatorWindow {
	private Component gui
	private Toolbar tb;
	private ToolbarButton refreshButton;
	private ToolbarButton collapseallButton;
	private OddgenConnectionPanel connectionPanel;

	new(Context context, String string) {
		super(context, string)
	}

	def protected initialize() {
		// TODO: add ContextMenu, TreeExplorer
		createToolbar
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
	}

	override Component getGUI() {
		if (gui == null) {
			gui = super.getGUI()
			initialize()
		}
		return gui;
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
}