package trivadis.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import java.awt.Component;
import java.awt.Container;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import javax.swing.JTree;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class TreeUtils {
  public static void immatateDblClick(final Component paramComponent) {
    JTree _findTree = TreeUtils.findTree(paramComponent);
    TreeUtils.immatateDblClick(_findTree);
  }
  
  public static void immatateDblClick(final JTree paramJTree) {
    paramJTree.addMouseListener(new MouseAdapter() {
      @Override
      public void mousePressed(final MouseEvent paramAnonymousMouseEvent) {
      }
    });
  }
  
  public static JTree findTree(final Component component) {
    final LinkedList<Component> components = new LinkedList<Component>();
    components.add(component);
    while ((!components.isEmpty())) {
      {
        Component _removeLast = components.removeLast();
        Component comp = ((Component) _removeLast);
        Object obj = null;
        if ((comp instanceof JTree)) {
          obj = ((JTree) comp);
          return ((JTree) obj);
        }
        if ((comp instanceof Container)) {
          obj = ((Container) comp);
          Component[] _components = ((Container) obj).getComponents();
          List<Component> _asList = Arrays.<Component>asList(_components);
          components.addAll(_asList);
        }
      }
    }
    return null;
  }
}
