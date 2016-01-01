package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import oracle.dbtools.raptor.view.AbstractDockableFactory
import oracle.ide.docking.DockableView
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
}

