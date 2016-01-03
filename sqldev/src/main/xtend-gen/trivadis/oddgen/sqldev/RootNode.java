package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import javax.swing.Icon;
import oracle.ide.model.DefaultContainer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import trivadis.oddgen.sqldev.OddgenNavigatorWindow;
import trivadis.oddgen.sqldev.resources.OddgenResources;

@SuppressWarnings("all")
public class RootNode extends DefaultContainer {
  private final static Logger logger = LoggerFactory.getLogger(OddgenNavigatorWindow.class.getName());
  
  private static RootNode instance;
  
  @Loggable(prepend = true)
  public static RootNode getInstance() {
    boolean _equals = Objects.equal(RootNode.instance, null);
    if (_equals) {
      RootNode _rootNode = new RootNode();
      RootNode.instance = _rootNode;
      RootNode.logger.info("RootNode initialized");
    }
    return RootNode.instance;
  }
  
  @Override
  public String getShortLabel() {
    return OddgenResources.getString("ROOT_NODE_SHORT_LABEL");
  }
  
  @Override
  public String getLongLabel() {
    return OddgenResources.getString("ROOT_NODE_LONG_LABEL");
  }
  
  @Override
  public Icon getIcon() {
    return OddgenResources.getIcon("ODDGEN_FOLDER_ICON");
  }
}
