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
import oracle.dbtools.raptor.RaptorExtensionConstants
import oracle.ide.Context
import oracle.ide.IdeConstants
import oracle.ide.controller.IdeAction
import oracle.ide.docking.DockStation
import oracle.ide.docking.DockingParam
import oracle.ide.help.HelpInfo
import oracle.ide.layout.ViewId
import oracle.ideri.navigator.DefaultNavigatorManager
import oracle.ideri.navigator.DefaultNavigatorWindow

@Loggable(LoggableConstants.DEBUG)
class OddgenNavigatorManager extends DefaultNavigatorManager {
	public static final String NAVIGATOR_WINDOW_ID = "ODDGEN_NAVIGATOR_WINDOW"

	static private OddgenNavigatorManager INSTANCE = null

	new() {
		// TODO: define and include accelerators
		// val registry = Ide.getKeyStrokeContextRegistry()
		// registry.addAcceleratorDefinitionFile(getClass().getClassLoader(),
		// "/org/oddgen/sqldev/resources/accelerators.xml")
	}

	def static OddgenNavigatorManager getInstance() {
		if (INSTANCE === null) {
			INSTANCE = new OddgenNavigatorManager
			Logger.debug(DefaultNavigatorManager, "OddgenNavigatorManager initialized")
		}
		return INSTANCE
	}

	override protected createShowNavigatorAction() {
		return IdeAction.find(OddgenNavigatorController::SHOW_ODDGEN_NAVIGATOR_CMD_ID)
	}

	override protected createNavigatorWindow() {
		return createNavigatorWindow(RootNode.getInstance(), true, if (RaptorExtensionConstants.isStandAlone()) {
			1
		} else {
			0
		})
	}

	override protected DefaultNavigatorWindow createNavigatorWindow(Context context, ViewId viewId) {
		val window = new OddgenNavigatorWindow(context, viewId.id)
		return window;
	}

	override protected getDefaultName() {
		return "Default"
	}

	override protected getViewCategory() {
		return NAVIGATOR_WINDOW_ID
	}

	override protected createDockableFactory() {
		return null
	}

	override protected createNavigatorDockingParam() {
		val param = new DockingParam()
		val referenceView = new ViewId(NAVIGATOR_WINDOW_ID, "Default")
		val referenceDockable = DockStation.dockStation.findDockable(referenceView)
		param.setPosition(referenceDockable, IdeConstants.WEST, IdeConstants.SOUTH)
		return param
	}

	override HelpInfo getHelpInfo() {
		// TODO: provide some help
		return super.helpInfo
	}
}