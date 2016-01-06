package org.oddgen.sqldev.model;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Pure;
import org.oddgen.sqldev.LoggableConstants;

@Loggable(value = LoggableConstants.DEBUG, prepend = true)
@Accessors
@SuppressWarnings("all")
public class Folder {
  private String name;
  
  private String description;
  
  private String tooltip;
  
  public String getTooltip() {
    String _xifexpression = null;
    boolean _equals = Objects.equal(this.tooltip, null);
    if (_equals) {
      _xifexpression = this.description;
    } else {
      _xifexpression = this.tooltip;
    }
    return _xifexpression;
  }
  
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
  
  public void setTooltip(final String tooltip) {
    this.tooltip = tooltip;
  }
}
