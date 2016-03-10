package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import oracle.ide.Context
import oracle.ide.controller.ContextMenu
import oracle.ide.controller.ContextMenuListener

@Loggable(prepend=true)
class OddgenNavigatorContextMenu implements ContextMenuListener {

	private static OddgenNavigatorContextMenu INSTANCE

	def static synchronized getInstance() {
		if (INSTANCE == null) {
			INSTANCE = new OddgenNavigatorContextMenu()
		}
		return INSTANCE
	}

	override handleDefaultAction(Context context) {
		Logger.debug(this, "handleDefaultAction context: %s", context)
		if (context.element instanceof ObjectNameNode) {
			OddgenNavigatorViewController.GENERATE_TO_WORKSHEET_ACTION.performAction
			return true
		}
		return false
	}

	override menuWillHide(ContextMenu paramContextMenu) {}

	override menuWillShow(ContextMenu contextMenu) {
		Logger.debug(this, "menuWillShow contextmenu: %1$s class is %2$s", contextMenu, contextMenu.class)
		Logger.debug(this, "menuWillShow context: %1$s class is %2$s", contextMenu.context, contextMenu.context.class)
		for (item : contextMenu.context.selection) {
			Logger.debug(this, "selection is : %s", item)
		}
		Logger.debug(this, "menuCount: %d", contextMenu.menuCount)
		for (component : contextMenu.getGUI(false).getComponents) {
			Logger.debug(this, "component of menu: %s", component)
		}
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorViewController.GENERATE_TO_WORKSHEET_ACTION))
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorViewController.GENERATE_TO_CLIPBOARD_ACTION))
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorViewController.GENERATE_DIALOG_ACTION))
	}
}
