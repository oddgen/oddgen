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
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class PreferencePanel extends DefaultTraversablePanel {
	final JCheckBox bulkProcessCheckBox = new JCheckBox()
	final JCheckBox showClientGeneratorExamplesCheckBox = new JCheckBox()

	new() {
		layoutControls()
	}

	def private layoutControls() {
		val FieldLayoutBuilder builder = new FieldLayoutBuilder(this)
		builder.alignLabelsLeft = true
		builder.add(
			builder.field.label.withText(OddgenResources.getString("PREF_BULK_PROCESS_LABEL")).component(
				bulkProcessCheckBox).withHint(
				OddgenResources.getString("PREF_BULK_PROCESS_HINT")
			))
		builder.add(
			builder.field.label.withText(OddgenResources.getString("PREF_SHOW_CLIENT_GENERATOR_EXAMPLES_LABEL")).component(
				showClientGeneratorExamplesCheckBox).withHint(
				OddgenResources.getString("PREF_SHOW_CLIENT_GENERATOR_EXAMPLES_HINT")
			))
		builder.addVerticalSpring
	}

	override onEntry(TraversableContext traversableContext) {
		var PreferenceModel info = traversableContext.userInformation
		bulkProcessCheckBox.selected = info.isBulkProcess
		showClientGeneratorExamplesCheckBox.selected = info.isShowClientGeneratorExamples
		super.onEntry(traversableContext)
	}

	override onExit(TraversableContext traversableContext) throws TraversalException {
		var PreferenceModel info = traversableContext.userInformation
		info.bulkProcess = bulkProcessCheckBox.selected
		info.showClientGeneratorExamples = showClientGeneratorExamplesCheckBox.selected
		super.onExit(traversableContext)
	}

	def private static PreferenceModel getUserInformation(TraversableContext tc) {
		return PreferenceModel.getInstance(tc.propertyStorage)
	}
}
