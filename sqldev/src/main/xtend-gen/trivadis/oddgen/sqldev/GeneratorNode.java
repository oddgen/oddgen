package trivadis.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import java.net.URL;
import javax.swing.Icon;
import oracle.ide.model.DefaultContainer;
import trivadis.oddgen.sqldev.LoggableConstants;
import trivadis.oddgen.sqldev.model.Generator;
import trivadis.oddgen.sqldev.resources.OddgenResources;

@Loggable(value = LoggableConstants.DEBUG, prepend = true)
@SuppressWarnings("all")
public class GeneratorNode extends DefaultContainer {
  private Generator generator;
  
  public GeneratorNode() {
  }
  
  public GeneratorNode(final URL url) {
    this(url, null);
  }
  
  public GeneratorNode(final URL url, final Generator generator) {
    super(url);
    this.generator = generator;
  }
  
  @Override
  public Icon getIcon() {
    return OddgenResources.getIcon("ODDGEN_ICON");
  }
  
  @Override
  public String getLongLabel() {
    String _description = null;
    if (this.generator!=null) {
      _description=this.generator.getDescription();
    }
    return _description;
  }
  
  @Override
  public String getShortLabel() {
    String _name = null;
    if (this.generator!=null) {
      _name=this.generator.getName();
    }
    return _name;
  }
  
  @Override
  public String getToolTipText() {
    String _description = null;
    if (this.generator!=null) {
      _description=this.generator.getDescription();
    }
    return _description;
  }
  
  public Generator getGenerator() {
    return this.generator;
  }
}
