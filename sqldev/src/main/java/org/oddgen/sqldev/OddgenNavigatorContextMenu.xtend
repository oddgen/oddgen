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
import oracle.ide.Context
import oracle.ide.controller.ContextMenu
import oracle.ide.controller.ContextMenuListener

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
		Logger.debug(this, "handleDefaultAction context: %s", context)
		if (context.element instanceof NodeNode) {
			OddgenNavigatorController.GENERATE_TO_WORKSHEET_ACTION.performAction
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
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.GENERATE_TO_WORKSHEET_ACTION))
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.GENERATE_TO_CLIPBOARD_ACTION))
		contextMenu.add(contextMenu.createMenuItem(OddgenNavigatorController.GENERATE_DIALOG_ACTION))
	}
}
