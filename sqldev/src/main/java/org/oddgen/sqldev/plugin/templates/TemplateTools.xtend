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
package org.oddgen.sqldev.plugin.templates

import com.jcabi.aspects.Loggable
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStreamWriter
import java.nio.charset.StandardCharsets
import org.oddgen.sqldev.LoggableConstants

@Loggable(LoggableConstants.DEBUG)
class TemplateTools {

	def String mkdirs(String dirName) {
		try {
			val file = new File (dirName)
			if (!file.exists) {
				file.mkdirs
				return '''«dirName» created.'''
			}
		} catch (Exception e) {
			return '''Cannot create directory «dirName». Got the following error message: «e.message».'''
		}
	}

	def String writeToFile(String fileName, String text) {
		try {
			val out = new OutputStreamWriter(new FileOutputStream(fileName), StandardCharsets.UTF_8)
			out.append(text)
			out.flush
			out.close
			return '''«fileName» created.'''
		} catch (Exception e) {
			return '''Cannot create «fileName». Got the following error message: «e.message».'''
		}
	}

}
