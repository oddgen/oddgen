package org.oddgen.sqldev.model;

import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Pure;
import org.oddgen.sqldev.model.AbstractModel;

@Accessors
@SuppressWarnings("all")
public class Generator extends AbstractModel {
  private String name;
  
  private String description;
  
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
}
