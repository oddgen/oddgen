/*
 * Copyright 2015-2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
package org.oddgen.sqldev.plugin

import com.jcabi.aspects.Loggable
import java.io.File
import java.io.FilenameFilter
import java.net.URL
import java.net.URLClassLoader
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.reflections.Reflections
import org.reflections.scanners.SubTypesScanner
import org.reflections.util.ConfigurationBuilder
import org.springframework.util.ResourceUtils

@Loggable(LoggableConstants.DEBUG)
class PluginUtils {
	public static val SQLDEV_HOME_DIRS = #[
		"/Applications/SQLDeveloper4.1.3.app/Contents/Resources/sqldeveloper",
		"/Applications/SQLDeveloper.app/Contents/Resources/sqldeveloper",
		"C:/app/sqldeveloper4.1.3",
		"C:/app/sqldeveloper",
		"C:/Program Files/sqldeveloper",
		"C:/Program Files (x86)/sqldeveloper"
	]

	public static val SQLDEV_EXTENSION_DIR = "/sqldeveloper/extensions"

	static def getSqlDevExtensionDir() {
		var file = ResourceUtils.getFile(PluginUtils.protectionDomain.codeSource.location)
		if (file !== null && file.name.endsWith(".jar")) {
			return file.parentFile
		} else {
			for (d : SQLDEV_HOME_DIRS) {
				var f = new File(d)
				if (f.exists) {
					return new File('''«d»«SQLDEV_EXTENSION_DIR»''')
				}
			}
			return null
		}
	}

	static def findJars() {
		return findJars(getSqlDevExtensionDir)
	}

	static def findJars(File dir) {
		if (dir === null || !dir.exists) {
			val URL[] emptyJarArray = newArrayOfSize(0)
			return emptyJarArray
		} else {
			val jarFiles = dir.listFiles(
			new FilenameFilter() {
				override accept(File dir, String name) {
					return name.endsWith(".jar") && !name.startsWith("oracle.sqldeveloper") &&
						!name.startsWith("oracle.datamodeler") && !name.startsWith("oracle.dmt.dataminer") &&
						!name.startsWith("oracle.olap")
				}
			})
			val jarList = jarFiles.map[it.toURI.toURL]
			var URL[] jarArray = newArrayOfSize(jarList.size)
			jarArray = jarList.toArray(jarArray)
			return jarArray
		}
	}
	
	static def hasDefaultConstructor(Class<?> clazz) {
		return clazz.constructors.filter[parameterTypes.size == 0].toList.size == 1
	}
	
	static def findOddgenGenerators(URL[] jars) {
		val classLoader = new URLClassLoader(jars, PluginUtils.classLoader)
		val reflections = new Reflections(
			new ConfigurationBuilder().addUrls(jars).addClassLoader(classLoader).addScanners(new SubTypesScanner()))
		val gens = reflections.getSubTypesOf(OddgenGenerator2).filter[hasDefaultConstructor]
		return gens.toList
	}
}
