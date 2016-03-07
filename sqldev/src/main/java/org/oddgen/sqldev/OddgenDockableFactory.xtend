package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import oracle.ide.IdeConstants
import oracle.ide.docking.DockStation
import oracle.ide.docking.DockableFactory
import oracle.ide.docking.DockingParam
import oracle.ide.layout.ViewId

@Loggable(prepend=true)
class OddgenDockableFactory implements DockableFactory {

	private OddgenNavigatorWindow dockable

	override void install() {
		val dockStation = DockStation.getDockStation()
		dockStation.dock(getLocalDockable(), createDockingParam)
	}

	def private getLocalDockable() {
		if (dockable == null) {
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
