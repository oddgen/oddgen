package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import java.awt.event.ActionEvent;
import java.util.EventObject;
import oracle.ide.Context;
import oracle.ide.Ide;
import oracle.ide.controller.IdeAction;
import oracle.ideri.navigator.DefaultNavigatorManager;
import oracle.ideri.navigator.ShowNavigatorController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import trivadis.oddgen.sqldev.OddgenNavigatorManager;

@SuppressWarnings("all")
public class OddgenNavigatorViewController extends ShowNavigatorController {
  private final static Logger logger = LoggerFactory.getLogger(OddgenNavigatorViewController.class.getName());
  
  public final static int SHOW_ODDGEN_NAVIGATOR_CMD_ID = Ide.findOrCreateCmdID("oddgen.SHOW_NAVIGATOR");
  
  private boolean initialized = false;
  
  @Loggable(prepend = true)
  @Override
  public boolean update(final IdeAction action, final Context context) {
    OddgenNavigatorViewController.logger.debug(("expected id: " + Integer.valueOf(OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID)));
    final int id = action.getCommandId();
    OddgenNavigatorViewController.logger.debug(("id: " + Integer.valueOf(id)));
    if ((id == OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID)) {
      action.setEnabled(true);
    }
    return action.isEnabled();
  }
  
  @Loggable(prepend = true)
  @Override
  public boolean handleEvent(final IdeAction action, final Context context) {
    OddgenNavigatorViewController.logger.debug(("expected action: " + Integer.valueOf(OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID)));
    boolean _notEquals = (!Objects.equal(action, null));
    if (_notEquals) {
      int _commandId = action.getCommandId();
      String _plus = ("got action.commandId: " + Integer.valueOf(_commandId));
      OddgenNavigatorViewController.logger.debug(_plus);
    }
    boolean _or = false;
    boolean _equals = Objects.equal(action, null);
    if (_equals) {
      _or = true;
    } else {
      boolean _and = false;
      int _commandId_1 = action.getCommandId();
      boolean _equals_1 = (_commandId_1 == OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID);
      if (!_equals_1) {
        _and = false;
      } else {
        _and = (!this.initialized);
      }
      _or = _and;
    }
    if (_or) {
      this.initialized = true;
      OddgenNavigatorViewController.logger.debug("window factory called");
      final OddgenNavigatorManager navigatorManager = OddgenNavigatorManager.getInstance();
      OddgenNavigatorViewController.logger.debug(("navigator manager: " + navigatorManager));
      final IdeAction show = navigatorManager.getShowAction();
      OddgenNavigatorViewController.logger.debug(("showAction: " + show));
      EventObject _event = context.getEvent();
      show.actionPerformed(((ActionEvent) _event));
      return true;
    }
    return false;
  }
  
  @Loggable(prepend = true)
  @Override
  protected DefaultNavigatorManager getNavigatorManager() {
    return OddgenNavigatorManager.getInstance();
  }
}
