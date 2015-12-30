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
package trivadis.oddgen.sqldev.ui;

import java.util.logging.Logger;
import javax.swing.JCheckBox;
import oracle.ide.panels.DefaultTraversablePanel;
import oracle.ide.panels.TraversableContext;
import oracle.ide.panels.TraversalException;
import oracle.javatools.data.PropertyStorage;
import oracle.javatools.ui.layout.FieldLayoutBuilder;
import trivadis.oddgen.sqldev.model.PreferenceModel;

@SuppressWarnings("all")
public class PreferencePanel extends DefaultTraversablePanel {
  private final static Logger logger = Logger.getLogger(PreferencePanel.class.getName());
  
  private final JCheckBox discoverPlsqlGeneratorsCheckBox = new JCheckBox();
  
  public PreferencePanel() {
    this.layoutControls();
  }
  
  private void layoutControls() {
    PreferencePanel.logger.fine("start layoutControls");
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
    PreferencePanel.logger.fine("end layoutControls");
  }
  
  @Override
  public void onEntry(final TraversableContext traversableContext) {
    PreferencePanel.logger.fine("start onEntry");
    PreferenceModel info = PreferencePanel.getUserInformation(traversableContext);
    boolean _isDiscoverPlsqlGenerators = info.isDiscoverPlsqlGenerators();
    this.discoverPlsqlGeneratorsCheckBox.setSelected(_isDiscoverPlsqlGenerators);
    super.onEntry(traversableContext);
    PreferencePanel.logger.fine("end onEntry");
  }
  
  @Override
  public void onExit(final TraversableContext traversableContext) throws TraversalException {
    PreferencePanel.logger.fine("start onExit");
    PreferenceModel info = PreferencePanel.getUserInformation(traversableContext);
    boolean _isSelected = this.discoverPlsqlGeneratorsCheckBox.isSelected();
    info.setDiscoverPlsqlGenerators(_isSelected);
    super.onExit(traversableContext);
    PreferencePanel.logger.fine("end onExit");
  }
  
  private static PreferenceModel getUserInformation(final TraversableContext tc) {
    PreferencePanel.logger.fine("start/end getUserInformation");
    PropertyStorage _propertyStorage = tc.getPropertyStorage();
    return PreferenceModel.getInstance(_propertyStorage);
  }
}
