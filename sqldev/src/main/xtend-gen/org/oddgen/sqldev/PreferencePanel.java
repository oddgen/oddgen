/**
 * Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import javax.swing.JCheckBox;
import oracle.ide.panels.DefaultTraversablePanel;
import oracle.ide.panels.TraversableContext;
import oracle.ide.panels.TraversalException;
import oracle.javatools.data.PropertyStorage;
import oracle.javatools.ui.layout.FieldLayoutBuilder;
import org.oddgen.sqldev.model.PreferenceModel;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class PreferencePanel extends DefaultTraversablePanel {
  private final JCheckBox discoverPlsqlGeneratorsCheckBox = new JCheckBox();
  
  public PreferencePanel() {
    this.layoutControls();
  }
  
  private void layoutControls() {
    final FieldLayoutBuilder b = new FieldLayoutBuilder(this);
    b.setAlignLabelsLeft(true);
    FieldLayoutBuilder.LabelSetup _field = b.field();
    FieldLayoutBuilder.LabelTextSetup _label = _field.label();
    FieldLayoutBuilder.ComponentSetup _withText = _label.withText("&Discover PL/SQL generators:");
    FieldLayoutBuilder.ComponentTextSetupWithButton _component = _withText.component(this.discoverPlsqlGeneratorsCheckBox);
    FieldLayoutBuilder.FieldSetup _withHint = _component.withHint(
      "If checked, PL/SQL generators are discovered within the current database instance when opening the oddgen folder.");
    b.add(_withHint);
    b.addVerticalSpring();
  }
  
  @Override
  public void onEntry(final TraversableContext traversableContext) {
    PreferenceModel info = PreferencePanel.getUserInformation(traversableContext);
    boolean _isDiscoverPlsqlGenerators = info.isDiscoverPlsqlGenerators();
    this.discoverPlsqlGeneratorsCheckBox.setSelected(_isDiscoverPlsqlGenerators);
    super.onEntry(traversableContext);
  }
  
  @Override
  public void onExit(final TraversableContext traversableContext) throws TraversalException {
    PreferenceModel info = PreferencePanel.getUserInformation(traversableContext);
    boolean _isSelected = this.discoverPlsqlGeneratorsCheckBox.isSelected();
    info.setDiscoverPlsqlGenerators(_isSelected);
    super.onExit(traversableContext);
  }
  
  private static PreferenceModel getUserInformation(final TraversableContext tc) {
    PropertyStorage _propertyStorage = tc.getPropertyStorage();
    return PreferenceModel.getInstance(_propertyStorage);
  }
}
