package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import oracle.dbtools.raptor.view.AbstractDockableFactory
import oracle.ide.IdeConstants
import oracle.ide.docking.DockStation
import oracle.ide.docking.DockableView
import oracle.ide.docking.DockingParam
import oracle.ide.layout.ViewId

class OddgenDockableFactory extends AbstractDockableFactory {
	@Loggable(prepend=true)
	override protected DockableView getDockableImpl() {
		return OddgenNavigatorManager.instance.navigatorWindow
	}

	@Loggable(prepend=true)
	override protected ViewId getDefaultViewId() {
		return OddgenNavigatorManager.instance.defaultViewId
	}

	@Loggable(prepend=true)
	override protected DockingParam createDockingParam() {
		val param = new DockingParam();
		val referenceView = new ViewId("DatabaseNavigatorWindow", "Default")
		val referenceDockable = DockStation.dockStation.findDockable(referenceView)
		param.setPosition(referenceDockable, IdeConstants.SOUTH, IdeConstants.WEST)
		return param
	}
}

