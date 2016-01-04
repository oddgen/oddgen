package trivadis.oddgen.sqldev.model;

import com.jcabi.aspects.Loggable;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Pure;

@Loggable(prepend = true)
@Accessors
@SuppressWarnings("all")
public class Folder {
  private String name;
  
  private String description;
  
  private String tooltip;
  
  @Pure
  public String getName() {
    return this.name;
  }
  
  public void setName(final String name) {
    this.name = name;
  }
  
  @Pure
  public String getDescription() {
    return this.description;
  }
  
  public void setDescription(final String description) {
    this.description = description;
  }
  
  @Pure
  public String getTooltip() {
    return this.tooltip;
  }
  
  public void setTooltip(final String tooltip) {
    this.tooltip = tooltip;
  }
}
