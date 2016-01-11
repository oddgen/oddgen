package org.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.log.Logger;
import java.io.IOException;
import java.net.URL;
import javax.swing.Icon;
import oracle.ide.model.DefaultContainer;
import oracle.ide.model.Subject;
import oracle.ide.model.UpdateMessage;
import oracle.ide.net.URLFactory;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.oddgen.sqldev.FolderNode;
import org.oddgen.sqldev.model.Folder;
import org.oddgen.sqldev.resources.OddgenResources;

@SuppressWarnings("all")
public class RootNode extends DefaultContainer {
  private static String ROOT_NODE_NAME = OddgenResources.getString("ROOT_NODE_LONG_LABEL");
  
  private static String CLIENT_GEN_NAME = OddgenResources.getString("CLIENT_GEN_NODE_LONG_LABEL");
  
  private static String DBSERVER_GEN_NAME = OddgenResources.getString("DBSERVER_GEN_NODE_LONG_LABEL");
  
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
    final URL url = URLFactory.newURL("oddgen.generators", RootNode.ROOT_NODE_NAME);
    boolean _equals = Objects.equal(url, null);
    if (_equals) {
      Logger.error(this, "root node URL is null");
    }
    this.setURL(url);
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
    return RootNode.ROOT_NODE_NAME;
  }
  
  @Override
  public String getLongLabel() {
    return RootNode.ROOT_NODE_NAME;
  }
  
  @Override
  public String getToolTipText() {
    return RootNode.ROOT_NODE_NAME;
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
  
  protected void addFolder(final String name) {
    final Folder folder = new Folder();
    folder.setName(name);
    folder.setDescription(name);
    URL _uRL = this.getURL();
    final URL folderUrl = URLFactory.newURL(_uRL, name);
    final FolderNode folderNode = new FolderNode(folderUrl, folder);
    this._children.add(folderNode);
    UpdateMessage.fireChildAdded(((Subject) this), folderNode);
  }
  
  public boolean initialize() {
    boolean _xifexpression = false;
    if ((!this.initialized)) {
      boolean _xblockexpression = false;
      {
        this.addFolder(RootNode.CLIENT_GEN_NAME);
        this.addFolder(RootNode.DBSERVER_GEN_NAME);
        UpdateMessage.fireStructureChanged(((Subject) this));
        this.markDirty(false);
        Logger.info(this, "RootNode initialized");
        _xblockexpression = this.initialized = true;
      }
      _xifexpression = _xblockexpression;
    }
    return _xifexpression;
  }
}
