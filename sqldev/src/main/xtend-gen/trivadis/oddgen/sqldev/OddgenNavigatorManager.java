package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import oracle.dbtools.raptor.RaptorExtensionConstants;
import oracle.ide.Context;
import oracle.ide.controller.IdeAction;
import oracle.ide.docking.DockableFactory;
import oracle.ide.docking.DockingParam;
import oracle.ide.help.HelpInfo;
import oracle.ide.layout.ViewId;
import oracle.ide.navigator.NavigatorWindow;
import oracle.ideri.navigator.DefaultNavigatorManager;
import oracle.ideri.navigator.DefaultNavigatorWindow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import trivadis.oddgen.sqldev.OddgenNavigatorViewController;
import trivadis.oddgen.sqldev.OddgenNavigatorWindow;
import trivadis.oddgen.sqldev.RootNode;

@SuppressWarnings("all")
public class OddgenNavigatorManager extends DefaultNavigatorManager {
  private final static Logger logger = LoggerFactory.getLogger(OddgenNavigatorManager.class.getName());
  
  private final static String NAVIGATOR_WINDOW_ID = "oddgen.NAVIGATOR_WINDOW";
  
  private static OddgenNavigatorManager instance = null;
  
  public OddgenNavigatorManager() {
  }
  
  @Loggable(prepend = true)
  public static OddgenNavigatorManager getInstance() {
    boolean _equals = Objects.equal(OddgenNavigatorManager.instance, null);
    if (_equals) {
      OddgenNavigatorManager _oddgenNavigatorManager = new OddgenNavigatorManager();
      OddgenNavigatorManager.instance = _oddgenNavigatorManager;
      OddgenNavigatorManager.logger.info("OddgenNavigatorManager initialized");
    }
    return OddgenNavigatorManager.instance;
  }
  
  @Loggable(prepend = true)
  @Override
  protected IdeAction createShowNavigatorAction() {
    return IdeAction.find(OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID);
  }
  
  @Loggable(prepend = true)
  @Override
  protected IdeAction createToggleToolbarAction() {
    return IdeAction.find(OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID);
  }
  
  @Loggable(prepend = true)
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
  
  @Loggable(prepend = true)
  @Override
  protected DefaultNavigatorWindow createNavigatorWindow(final Context context, final ViewId viewId) {
    String _id = viewId.getId();
    final OddgenNavigatorWindow window = new OddgenNavigatorWindow(context, _id);
    window.getGui();
    return window;
  }
  
  @Loggable(prepend = true)
  @Override
  protected String getDefaultName() {
    return OddgenNavigatorManager.NAVIGATOR_WINDOW_ID;
  }
  
  @Loggable(prepend = true)
  @Override
  protected String getViewCategory() {
    return OddgenNavigatorManager.NAVIGATOR_WINDOW_ID;
  }
  
  @Loggable(prepend = true)
  @Override
  protected DockableFactory createDockableFactory() {
    return null;
  }
  
  @Loggable(prepend = true)
  @Override
  protected DockingParam createNavigatorDockingParam() {
    final DockingParam dockingParam = new DockingParam();
    return dockingParam;
  }
  
  @Loggable(prepend = true)
  @Override
  public HelpInfo getHelpInfo() {
    return super.getHelpInfo();
  }
}
