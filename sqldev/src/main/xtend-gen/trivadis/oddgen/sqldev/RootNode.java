package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import com.jcabi.log.Logger;
import java.io.IOException;
import java.net.URL;
import javax.swing.Icon;
import oracle.ide.model.DefaultContainer;
import oracle.ide.net.URLFactory;
import org.eclipse.xtext.xbase.lib.Exceptions;
import trivadis.oddgen.sqldev.FolderNode;
import trivadis.oddgen.sqldev.model.Folder;
import trivadis.oddgen.sqldev.resources.OddgenResources;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class RootNode extends DefaultContainer {
  private static RootNode INSTANCE;
  
  private boolean initialized = false;
  
  private FolderNode clientGenerators;
  
  private FolderNode dbServerGenerators;
  
  public static synchronized RootNode getInstance() {
    boolean _equals = Objects.equal(RootNode.INSTANCE, null);
    if (_equals) {
      RootNode _rootNode = new RootNode();
      RootNode.INSTANCE = _rootNode;
      Logger.info(RootNode.class, "RootNode initialized");
    }
    return RootNode.INSTANCE;
  }
  
  private RootNode() {
    String _get = OddgenResources.get("ROOT_NODE_SHORT_LABEL");
    URL _newURL = URLFactory.newURL("oddgen.generators", _get);
    this.setURL(_newURL);
  }
  
  public FolderNode getClientGenerators() {
    try {
      this.open();
    } catch (final Throwable _t) {
      if (_t instanceof IOException) {
        final IOException e = (IOException)_t;
        String _message = e.getMessage();
        Logger.error(this, _message);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return this.clientGenerators;
  }
  
  public FolderNode getDbServerGenerators() {
    try {
      this.open();
    } catch (final Throwable _t) {
      if (_t instanceof IOException) {
        final IOException e = (IOException)_t;
        String _message = e.getMessage();
        Logger.error(this, _message);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return this.dbServerGenerators;
  }
  
  @Override
  public String getShortLabel() {
    return OddgenResources.get("ROOT_NODE_SHORT_LABEL");
  }
  
  @Override
  public String getLongLabel() {
    return OddgenResources.getString("ROOT_NODE_LONG_LABEL");
  }
  
  @Override
  public String getToolTipText() {
    return this.getLongLabel();
  }
  
  @Override
  public Icon getIcon() {
    return OddgenResources.getIcon("ODDGEN_FOLDER_ICON");
  }
  
  @Override
  protected void openImpl() {
    final Runnable _function = new Runnable() {
      @Override
      public void run() {
        RootNode.this.initialize();
      }
    };
    final Runnable runnable = _function;
    final Thread thread = new Thread(runnable);
    thread.setName("oddgen Tree Opener");
    thread.start();
  }
  
  protected boolean initialize() {
    boolean _xifexpression = false;
    if ((!this.initialized)) {
      boolean _xblockexpression = false;
      {
        this.initialized = true;
        final Folder clientFolder = new Folder();
        String _string = OddgenResources.getString("CLIENT_GEN_NODE_SHORT_LABEL");
        clientFolder.setName(_string);
        String _string_1 = OddgenResources.getString("CLIENT_GEN_NODE_LONG_LABEL");
        clientFolder.setDescription(_string_1);
        URL _uRL = this.getURL();
        String _description = clientFolder.getDescription();
        final URL url = URLFactory.newURL(_uRL, _description);
        final FolderNode clientFolderNode = new FolderNode(url, clientFolder);
        _xblockexpression = this._children.add(clientFolderNode);
      }
      _xifexpression = _xblockexpression;
    }
    return _xifexpression;
  }
}
