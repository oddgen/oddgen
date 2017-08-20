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
package org.oddgen.sqldev.plugin.tests

import java.net.InetAddress
import org.junit.Assert
import org.junit.Test
import org.oddgen.sqldev.plugin.PluginUtils

class PluginUtilsTest {

	@Test
	def findOddgenGeneratorsTest() {
		val jars = PluginUtils.findJars
		Assert.assertTrue(jars.size >= 0)
		val gens = PluginUtils.findOddgenGenerators(jars)
		Assert.assertTrue(gens.size >= 0)
	}

	@Test
	def getSqlDevExtensionDirTest() {
		val dir = PluginUtils.sqlDevExtensionDir
		Assert.assertTrue(dir !== null)
		val hostname = InetAddress.localHost.hostName
		if (hostname.startsWith("macphs")) {
			Assert.assertEquals(PluginUtils.SQLDEV_HOME_DIRS.get(0) + PluginUtils.SQLDEV_EXTENSION_DIR,
				dir.absolutePath)
		}
	}
}
