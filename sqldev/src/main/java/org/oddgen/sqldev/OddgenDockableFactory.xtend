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
import oracle.ide.IdeConstants
import oracle.ide.docking.DockStation
import oracle.ide.docking.DockableFactory
import oracle.ide.docking.DockingParam
import oracle.ide.layout.ViewId

@Loggable(LoggableConstants.DEBUG)
class OddgenDockableFactory implements DockableFactory {

	private OddgenNavigatorWindow dockable

	override void install() {
		val dockStation = DockStation.getDockStation()
		dockStation.dock(getLocalDockable(), createDockingParam)
	}

	def private getLocalDockable() {
		if (dockable === null) {
			dockable = OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow
		}
		return dockable
	}

	def protected createDockingParam() {
		val param = new DockingParam()
		val referenceView = new ViewId(OddgenNavigatorManager.NAVIGATOR_WINDOW_ID, "Default")
		Logger.debug(this, "referenceView = " + referenceView)
		val referenceDockable = DockStation.dockStation.findDockable(referenceView)
		param.setPosition(referenceDockable, IdeConstants.WEST, IdeConstants.SOUTH )
		return param
	}

	override getDockable(ViewId paramViewId) {
		Logger.debug(this, "paramViewId: "+paramViewId)
		return getLocalDockable()
	}

}
