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
		Assert.assertTrue(dir != null)
		val hostname = InetAddress.localHost.hostName
		if (hostname.startsWith("macphs")) {
			Assert.assertEquals(PluginUtils.SQLDEV_HOME_DIRS.get(0) + PluginUtils.SQLDEV_EXTENSION_DIR,
				dir.absolutePath)
		}
	}
}
