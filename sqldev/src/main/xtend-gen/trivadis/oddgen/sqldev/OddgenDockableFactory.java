package trivadis.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import oracle.dbtools.raptor.view.AbstractDockableFactory;
import oracle.ide.docking.DockableView;
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
}
