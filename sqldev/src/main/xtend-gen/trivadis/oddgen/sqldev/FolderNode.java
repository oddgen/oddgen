package trivadis.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import java.net.URL;
import javax.swing.Icon;
import oracle.ide.model.DefaultContainer;
import trivadis.oddgen.sqldev.model.Folder;
import trivadis.oddgen.sqldev.resources.OddgenResources;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class FolderNode extends DefaultContainer {
  private Folder folder;
  
  public FolderNode() {
  }
  
  public FolderNode(final URL url) {
    this(url, null);
  }
  
  public FolderNode(final URL url, final Folder folder) {
    super(url);
    this.folder = folder;
  }
  
  @Override
  public Icon getIcon() {
    return OddgenResources.getIcon("ODDGEN_FOLDER_ICON");
  }
  
  @Override
  public String getLongLabel() {
    String _description = null;
    if (this.folder!=null) {
      _description=this.folder.getDescription();
    }
    return _description;
  }
  
  @Override
  public String getShortLabel() {
    String _name = null;
    if (this.folder!=null) {
      _name=this.folder.getName();
    }
    return _name;
  }
  
  @Override
  public String getToolTipText() {
    String _tooltip = null;
    if (this.folder!=null) {
      _tooltip=this.folder.getTooltip();
    }
    return _tooltip;
  }
  
  public Folder getFolder() {
    return this.folder;
  }
}
