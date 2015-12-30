/*
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
package trivadis.oddgen.sqldev.ui

import java.util.logging.Logger
import javax.swing.JCheckBox
import oracle.ide.panels.DefaultTraversablePanel
import oracle.ide.panels.TraversableContext
import oracle.ide.panels.TraversalException
import oracle.javatools.ui.layout.FieldLayoutBuilder
import trivadis.oddgen.sqldev.model.PreferenceModel

class PreferencePanel extends DefaultTraversablePanel {
	static final Logger logger = Logger.getLogger(PreferencePanel.getName())
	final JCheckBox discoverPlsqlGeneratorsCheckBox = new JCheckBox()

	new() {
		layoutControls()
	}

	def private void layoutControls() {
		logger.fine("start layoutControls")
		val FieldLayoutBuilder b = new FieldLayoutBuilder(this)
		b.setAlignLabelsLeft(true)
		b.add(
			b.field.label.withText("&Discover PL/SQL generators:").component(discoverPlsqlGeneratorsCheckBox).
				withHint(
					"If checked, PL/SQL generators are discovered within the current database instance when opening the oddgen folder."
				))
		b.addVerticalSpring
		logger.fine("end layoutControls")
	}

	override void onEntry(TraversableContext traversableContext) {
		logger.fine("start onEntry")
		var PreferenceModel info = getUserInformation(traversableContext)
		discoverPlsqlGeneratorsCheckBox.setSelected(info.isDiscoverPlsqlGenerators())
		super.onEntry(traversableContext)
		logger.fine("end onEntry")
	}

	override void onExit(TraversableContext traversableContext) throws TraversalException {
		logger.fine("start onExit")
		var PreferenceModel info = getUserInformation(traversableContext)
		info.setDiscoverPlsqlGenerators(discoverPlsqlGeneratorsCheckBox.isSelected())
		super.onExit(traversableContext)
		logger.fine("end onExit")
	}

	def private static PreferenceModel getUserInformation(TraversableContext tc) {
		logger.fine("start/end getUserInformation")
		return PreferenceModel.getInstance(tc.getPropertyStorage())
	}

}
		