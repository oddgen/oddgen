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

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenNavigatorViewController extends ShowNavigatorController {
  private final static Logger LOGGER = LoggerFactory.getLogger(OddgenNavigatorViewController.class.getName());
  
  public final static int SHOW_ODDGEN_NAVIGATOR_CMD_ID = Ide.findOrCreateCmdID("oddgen.SHOW_NAVIGATOR");
  
  private boolean initialized = false;
  
  @Override
  public boolean update(final IdeAction action, final Context context) {
    OddgenNavigatorViewController.LOGGER.debug(("expected id: " + Integer.valueOf(OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID)));
    final int id = action.getCommandId();
    OddgenNavigatorViewController.LOGGER.debug(("id: " + Integer.valueOf(id)));
    if ((id == OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID)) {
      action.setEnabled(true);
    }
    return action.isEnabled();
  }
  
  @Override
  public boolean handleEvent(final IdeAction action, final Context context) {
    OddgenNavigatorViewController.LOGGER.debug(("expected action: " + Integer.valueOf(OddgenNavigatorViewController.SHOW_ODDGEN_NAVIGATOR_CMD_ID)));
    boolean _notEquals = (!Objects.equal(action, null));
    if (_notEquals) {
      int _commandId = action.getCommandId();
      String _plus = ("got action.commandId: " + Integer.valueOf(_commandId));
      OddgenNavigatorViewController.LOGGER.debug(_plus);
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
      final OddgenNavigatorManager navigatorManager = OddgenNavigatorManager.getInstance();
      OddgenNavigatorViewController.LOGGER.debug(("navigator manager: " + navigatorManager));
      final IdeAction show = navigatorManager.getShowAction();
      OddgenNavigatorViewController.LOGGER.debug(("showAction: " + show));
      EventObject _event = context.getEvent();
      show.actionPerformed(((ActionEvent) _event));
      return true;
    } else {
      boolean _notEquals_1 = (!Objects.equal(action, null));
      if (_notEquals_1) {
        OddgenNavigatorViewController.LOGGER.debug(("else showAction: " + action));
        return true;
      }
    }
    return false;
  }
  
  @Override
  protected DefaultNavigatorManager getNavigatorManager() {
    return OddgenNavigatorManager.getInstance();
  }
}
