package org.oddgen.sqldev.model;

import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@SuppressWarnings("all")
public abstract class AbstractModel {
  @Override
  public String toString() {
    ToStringBuilder _toStringBuilder = new ToStringBuilder(this);
    ToStringBuilder _addAllFields = _toStringBuilder.addAllFields();
    return _addAllFields.toString();
  }
}
