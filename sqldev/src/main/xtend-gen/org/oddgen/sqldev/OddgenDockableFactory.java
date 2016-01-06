package org.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import oracle.dbtools.raptor.view.AbstractDockableFactory;
import oracle.ide.IdeConstants;
import oracle.ide.docking.DockStation;
import oracle.ide.docking.Dockable;
import oracle.ide.docking.DockableView;
import oracle.ide.docking.DockingParam;
import oracle.ide.layout.ViewId;
import org.oddgen.sqldev.OddgenNavigatorManager;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenDockableFactory extends AbstractDockableFactory {
  @Override
  protected DockableView getDockableImpl() {
    OddgenNavigatorManager _instance = OddgenNavigatorManager.getInstance();
    return _instance.getNavigatorWindow();
  }
  
  @Override
  protected ViewId getDefaultViewId() {
    OddgenNavigatorManager _instance = OddgenNavigatorManager.getInstance();
    return _instance.getDefaultViewId();
  }
  
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
