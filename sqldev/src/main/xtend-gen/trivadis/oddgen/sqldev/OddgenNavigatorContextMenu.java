package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import com.jcabi.log.Logger;
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
import trivadis.oddgen.sqldev.GeneratorNode;
import trivadis.oddgen.sqldev.TreeUtils;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenNavigatorContextMenu implements ContextMenuListener, Controller {
  private final static int OPEN_CMD_ID = Ide.findOrCreateCmdID("oddgen.OPEN");
  
  private final static int REFRESH_CMD_ID = Ide.findOrCreateCmdID("oddgen.REFRESH");
  
  private final static int COLLAPSEALL_CMD_ID = Ide.findOrCreateCmdID("oddgen.COLLAPSEALL");
  
  private final static IdeAction OPEN_ACTION = OddgenNavigatorContextMenu.getAction(OddgenNavigatorContextMenu.OPEN_CMD_ID);
  
  private final static IdeAction REFRESH_ACTION = OddgenNavigatorContextMenu.getAction(OddgenNavigatorContextMenu.REFRESH_CMD_ID);
  
  private final static IdeAction COLLAPSEALL_ACTION = OddgenNavigatorContextMenu.getAction(OddgenNavigatorContextMenu.COLLAPSEALL_CMD_ID);
  
  private static OddgenNavigatorContextMenu INSTANCE;
  
  private static IdeAction getAction(final int actionId) {
    final IdeAction action = IdeAction.get(actionId);
    OddgenNavigatorContextMenu _instance = OddgenNavigatorContextMenu.getInstance();
    action.addController(_instance);
    return action;
  }
  
  public static synchronized OddgenNavigatorContextMenu getInstance() {
    boolean _equals = Objects.equal(OddgenNavigatorContextMenu.INSTANCE, null);
    if (_equals) {
      OddgenNavigatorContextMenu _oddgenNavigatorContextMenu = new OddgenNavigatorContextMenu();
      OddgenNavigatorContextMenu.INSTANCE = _oddgenNavigatorContextMenu;
    }
    return OddgenNavigatorContextMenu.INSTANCE;
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
                Logger.debug(this, ("on node " + node));
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
