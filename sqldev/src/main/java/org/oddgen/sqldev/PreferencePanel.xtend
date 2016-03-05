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
package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import javax.swing.JCheckBox
import oracle.ide.panels.DefaultTraversablePanel
import oracle.ide.panels.TraversableContext
import oracle.ide.panels.TraversalException
import oracle.javatools.ui.layout.FieldLayoutBuilder
import org.oddgen.sqldev.model.PreferenceModel

@Loggable(prepend=true)
class PreferencePanel extends DefaultTraversablePanel {
	final JCheckBox discoverPlsqlGeneratorsCheckBox = new JCheckBox()

	new() {
		layoutControls()
	}

	def private void layoutControls() {
		val FieldLayoutBuilder b = new FieldLayoutBuilder(this)
		b.setAlignLabelsLeft(true)
		b.add(
			b.field.label.withText("&Discover PL/SQL generators:").component(discoverPlsqlGeneratorsCheckBox).
				withHint(
					"If checked, PL/SQL generators are discovered within the current database instance when opening the oddgen folder."
				))
		b.addVerticalSpring
	}

	override void onEntry(TraversableContext traversableContext) {
		var PreferenceModel info = getUserInformation(traversableContext)
		discoverPlsqlGeneratorsCheckBox.setSelected(info.isDiscoverPlsqlGenerators())
		super.onEntry(traversableContext)
	}

	override void onExit(TraversableContext traversableContext) throws TraversalException {
		var PreferenceModel info = getUserInformation(traversableContext)
		info.setDiscoverPlsqlGenerators(discoverPlsqlGeneratorsCheckBox.selected)
		super.onExit(traversableContext)
	}

	def private static PreferenceModel getUserInformation(TraversableContext tc) {
		return PreferenceModel.getInstance(tc.propertyStorage)
	}
}
