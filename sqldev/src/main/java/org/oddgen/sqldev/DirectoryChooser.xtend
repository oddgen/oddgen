/*
 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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

import java.io.File
import javax.swing.JFileChooser
import javax.swing.JTextField

class DirectoryChooser {
	def static String choose(String title, String initialDirectory) {
		var String returnValue = null
		val chooser = new JFileChooser;
		chooser.currentDirectory = new File(initialDirectory)
		chooser.dialogTitle = title
		chooser.fileSelectionMode = JFileChooser.DIRECTORIES_ONLY
		chooser.acceptAllFileFilterUsed = false
		if (chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
			returnValue = chooser.selectedFile.absolutePath
		}
		return returnValue
	}

	def static void choose(String title, JTextField textField) {
		val directory = choose(title, textField.text)
		if (directory !== null) {
			textField.text = directory;
		}
	}
}
