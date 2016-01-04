package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import java.awt.Component;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import javax.swing.JTree;
import javax.swing.tree.TreePath;
import oracle.ide.Context;
import oracle.ide.Ide;
import oracle.ide.controller.ContextMenu;
import oracle.ide.controller.ContextMenuListener;
import oracle.ide.controller.Controller;
import oracle.ide.controller.IdeAction;
import oracle.ide.model.Node;
import oracle.ideimpl.explorer.CustomTree;
import oracle.ideimpl.explorer.ExplorerNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import trivadis.oddgen.sqldev.GeneratorNode;
import trivadis.oddgen.sqldev.OddgenNavigatorWindow;
import trivadis.oddgen.sqldev.TreeUtils;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenNavigatorContextMenuController implements ContextMenuListener, Controller {
  private final static Logger LOGGER = LoggerFactory.getLogger(OddgenNavigatorWindow.class.getName());
  
  private final static int OPEN_CMD_ID = Ide.findOrCreateCmdID("oddgen.OPEN");
  
  private final static int REFRESH_CMD_ID = Ide.findOrCreateCmdID("oddgen.REFRESH");
  
  private final static int COLLAPSEALL_CMD_ID = Ide.findOrCreateCmdID("oddgen.COLLAPSEALL");
  
  private final static IdeAction OPEN_ACTION = OddgenNavigatorContextMenuController.getAction(OddgenNavigatorContextMenuController.OPEN_CMD_ID);
  
  private final static IdeAction REFRESH_ACTION = OddgenNavigatorContextMenuController.getAction(OddgenNavigatorContextMenuController.REFRESH_CMD_ID);
  
  private final static IdeAction COLLAPSEALL_ACTION = OddgenNavigatorContextMenuController.getAction(OddgenNavigatorContextMenuController.COLLAPSEALL_CMD_ID);
  
  private static OddgenNavigatorContextMenuController INSTANCE;
  
  private static IdeAction getAction(final int actionId) {
    final IdeAction action = IdeAction.get(actionId);
    OddgenNavigatorContextMenuController _instance = OddgenNavigatorContextMenuController.getInstance();
    action.addController(_instance);
    return action;
  }
  
  public static synchronized OddgenNavigatorContextMenuController getInstance() {
    boolean _equals = Objects.equal(OddgenNavigatorContextMenuController.INSTANCE, null);
    if (_equals) {
      OddgenNavigatorContextMenuController _oddgenNavigatorContextMenuController = new OddgenNavigatorContextMenuController();
      OddgenNavigatorContextMenuController.INSTANCE = _oddgenNavigatorContextMenuController;
    }
    return OddgenNavigatorContextMenuController.INSTANCE;
  }
  
  public void attachMouseListener(final Component component) {
    JTree tree = TreeUtils.findTree(component);
    tree.addMouseListener(
      new MouseAdapter() {
        @Override
        public void mousePressed(final MouseEvent event) {
          boolean _and = false;
          boolean _and_1 = false;
          boolean _and_2 = false;
          int _button = event.getButton();
          boolean _equals = (_button == MouseEvent.BUTTON1);
          if (!_equals) {
            _and_2 = false;
          } else {
            Object _source = event.getSource();
            _and_2 = (_source instanceof CustomTree);
          }
          if (!_and_2) {
            _and_1 = false;
          } else {
            Object _source_1 = event.getSource();
            Object _lastSelectedPathComponent = ((CustomTree) _source_1).getLastSelectedPathComponent();
            boolean _tripleNotEquals = (((ExplorerNode) _lastSelectedPathComponent) != null);
            _and_1 = _tripleNotEquals;
          }
          if (!_and_1) {
            _and = false;
          } else {
            Object _source_2 = event.getSource();
            Object _lastSelectedPathComponent_1 = ((CustomTree) _source_2).getLastSelectedPathComponent();
            Object _userObject = ((ExplorerNode) _lastSelectedPathComponent_1).getUserObject();
            boolean _tripleNotEquals_1 = (_userObject != null);
            _and = _tripleNotEquals_1;
          }
          if (_and) {
            Object _source_3 = event.getSource();
            int _x = event.getX();
            int _y = event.getY();
            final TreePath treePath = ((CustomTree) _source_3).getPathForLocation(_x, _y);
            if ((treePath != null)) {
              Object _lastPathComponent = treePath.getLastPathComponent();
              final ExplorerNode explorerNode = ((ExplorerNode) _lastPathComponent);
              Object _userObject_1 = explorerNode.getUserObject();
              final Node node = ((Node) _userObject_1);
              if ((node instanceof GeneratorNode)) {
                OddgenNavigatorContextMenuController.LOGGER.debug(("on node " + node));
              }
            }
          }
        }
      });
    tree.addKeyListener(new KeyListener() {
      @Override
      public void keyPressed(final KeyEvent event) {
      }
      
      @Override
      public void keyReleased(final KeyEvent event) {
      }
      
      @Override
      public void keyTyped(final KeyEvent event) {
      }
    });
  }
  
  @Override
  public boolean handleDefaultAction(final Context paramContext) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
  
  @Override
  public void menuWillHide(final ContextMenu paramContextMenu) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
  
  @Override
  public void menuWillShow(final ContextMenu paramContextMenu) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
  
  @Override
  public boolean handleEvent(final IdeAction paramIdeAction, final Context paramContext) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
  
  @Override
  public boolean update(final IdeAction paramIdeAction, final Context paramContext) {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
}
