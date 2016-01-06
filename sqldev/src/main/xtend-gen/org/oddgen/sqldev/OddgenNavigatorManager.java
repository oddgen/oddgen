package org.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import com.jcabi.log.Logger;
import oracle.dbtools.raptor.RaptorExtensionConstants;
import oracle.ide.Context;
import oracle.ide.IdeConstants;
import oracle.ide.controller.IdeAction;
import oracle.ide.docking.DockStation;
import oracle.ide.docking.Dockable;
import oracle.ide.docking.DockableFactory;
import oracle.ide.docking.DockingParam;
import oracle.ide.help.HelpInfo;
import oracle.ide.layout.ViewId;
import oracle.ide.navigator.NavigatorWindow;
import oracle.ideri.navigator.DefaultNavigatorManager;
import oracle.ideri.navigator.DefaultNavigatorWindow;
import org.oddgen.sqldev.OddgenNavigatorViewController;
import org.oddgen.sqldev.OddgenNavigatorWindow;
import org.oddgen.sqldev.RootNode;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenNavigatorManager extends DefaultNavigatorManager {
  private final static String NAVIGATOR_WINDOW_ID = "oddgen.NAVIGATOR_WINDOW";
  
  private static OddgenNavigatorManager INSTANCE = null;
  
  public OddgenNavigatorManager() {
  }
  
  public static OddgenNavigatorManager getInstance() {
    boolean _equals = Objects.equal(OddgenNavigatorManager.INSTANCE, null);
    if (_equals) {
      OddgenNavigatorManager _oddgenNavigatorManager = new OddgenNavigatorManager();
      OddgenNavigatorManager.INSTANCE = _oddgenNavigatorManager;
      Logger.info(DefaultNavigatorManager.class, "OddgenNavigatorManager initialized");
    }
    return OddgenNavigatorManager.INSTANCE;
  }
  
  @Override
  protected IdeAction createShowNavigatorAction() {
    return IdeAction.find(OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID);
  }
  
  @Override
  protected NavigatorWindow createNavigatorWindow() {
    RootNode _instance = RootNode.getInstance();
    int _xifexpression = (int) 0;
    boolean _isStandAlone = RaptorExtensionConstants.isStandAlone();
    if (_isStandAlone) {
      _xifexpression = 1;
    } else {
      _xifexpression = 0;
    }
    return this.createNavigatorWindow(_instance, true, _xifexpression);
  }
  
  @Override
  protected DefaultNavigatorWindow createNavigatorWindow(final Context context, final ViewId viewId) {
    String _id = viewId.getId();
    final OddgenNavigatorWindow window = new OddgenNavigatorWindow(context, _id);
    return window;
  }
  
  @Override
  protected String getDefaultName() {
    return "Default";
  }
  
  @Override
  protected String getViewCategory() {
    return OddgenNavigatorManager.NAVIGATOR_WINDOW_ID;
  }
  
  @Override
  protected DockableFactory createDockableFactory() {
    return null;
  }
  
  @Override
  protected DockingParam createNavigatorDockingParam() {
    final DockingParam param = new DockingParam();
    final ViewId referenceView = new ViewId("DatabaseNavigatorWindow", "Default");
    DockStation _dockStation = DockStation.getDockStation();
    final Dockable referenceDockable = _dockStation.findDockable(referenceView);
    param.setPosition(referenceDockable, IdeConstants.SOUTH, IdeConstants.WEST);
    return param;
  }
  
  @Override
  public HelpInfo getHelpInfo() {
    return super.getHelpInfo();
  }
}
