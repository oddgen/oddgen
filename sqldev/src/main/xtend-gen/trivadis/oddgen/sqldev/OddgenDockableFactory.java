package trivadis.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import oracle.dbtools.raptor.view.AbstractDockableFactory;
import oracle.ide.IdeConstants;
import oracle.ide.docking.DockStation;
import oracle.ide.docking.Dockable;
import oracle.ide.docking.DockableView;
import oracle.ide.docking.DockingParam;
import oracle.ide.layout.ViewId;
import trivadis.oddgen.sqldev.OddgenNavigatorManager;

@SuppressWarnings("all")
public class OddgenDockableFactory extends AbstractDockableFactory {
  @Loggable(prepend = true)
  @Override
  protected DockableView getDockableImpl() {
    OddgenNavigatorManager _instance = OddgenNavigatorManager.getInstance();
    return _instance.getNavigatorWindow();
  }
  
  @Loggable(prepend = true)
  @Override
  protected ViewId getDefaultViewId() {
    OddgenNavigatorManager _instance = OddgenNavigatorManager.getInstance();
    return _instance.getDefaultViewId();
  }
  
  @Loggable(prepend = true)
  @Override
  protected DockingParam createDockingParam() {
    final DockingParam param = new DockingParam();
    final ViewId referenceView = new ViewId("DatabaseNavigatorWindow", "Default");
    DockStation _dockStation = DockStation.getDockStation();
    final Dockable referenceDockable = _dockStation.findDockable(referenceView);
    param.setPosition(referenceDockable, IdeConstants.SOUTH, IdeConstants.WEST);
    return param;
  }
}
