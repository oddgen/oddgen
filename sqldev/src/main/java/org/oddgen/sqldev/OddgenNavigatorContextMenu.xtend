/*
 * Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
import oracle.ide.Context
import oracle.ide.controller.ContextMenu
import oracle.ide.controller.ContextMenuListener
import org.oddgen.sqldev.plugin.templates.NewPlsqlGenerator
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class OddgenNavigatorContextMenu implements ContextMenuListener {

	private static OddgenNavigatorContextMenu INSTANCE

	def static synchronized getInstance() {
		if (INSTANCE === null) {
			INSTANCE = new OddgenNavigatorContextMenu()
		}
		return INSTANCE
	}

	override handleDefaultAction(Context context) {
		if (OddgenNavigatorController.allowGenerate(context)) {
			Logger.debug(this, "Default action allowed for context: %s", context)
			OddgenNavigatorController.GENERATE_TO_WORKSHEET_ACTION.performAction
			return true
		}
		Logger.debug(this, "Default action not allowed for context: %s", context)
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
		val subMenu = contextMenu.createSubMenu(OddgenResources.getString("CTX_MENU_NEW_LABEL"),null,1,1)
		val plsqlGeneratorMenu = contextMenu.createMenuItem(OddgenNavigatorController.NEW_PLSQL_GENERATOR_ACTION)
		subMenu.add(plsqlGeneratorMenu)
		subMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.NEW_XTEND_PLUGIN_ACTION))
		subMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.NEW_XTEND_SQLDEV_EXTENSION_ACTION)) 
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		if (conn === null) {
			subMenu.enabled = false
		} else {
			val gen = new NewPlsqlGenerator()
			plsqlGeneratorMenu.enabled = gen.isSupported(conn)
		}
		contextMenu.add(subMenu)
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.GENERATE_TO_WORKSHEET_ACTION))
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.GENERATE_TO_CLIPBOARD_ACTION))
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.GENERATE_DIALOG_ACTION))
	}
}
