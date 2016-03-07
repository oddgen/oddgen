package org.oddgen.sqldev.tests

import com.jcabi.log.Logger
import oracle.ide.net.URLFactory
import oracle.ide.net.URLFileSystem
import org.junit.Assert
import org.junit.Test
import org.oddgen.sqldev.net.OddgenURLFileSystemHelper
import org.oddgen.sqldev.net.OddgenUrlStreamHandlerFactory
import org.oddgen.sqldev.resources.OddgenResources

class UrlTest {

	@Test
	def newUrlTest() {
		// manually register factory and helper
		// SQL Developer provides hooks in extension.xml for that purpose 
		val factory = new OddgenUrlStreamHandlerFactory
		val helper = new OddgenURLFileSystemHelper
		URLFileSystem.addURLStreamHandlerFactory(OddgenURLFileSystemHelper.PROTOCOL, factory)
		URLFileSystem.registerHelper(OddgenURLFileSystemHelper.PROTOCOL, helper)
		val url = URLFactory.newURL(OddgenURLFileSystemHelper.PROTOCOL, OddgenResources.get("ROOT_NODE_LONG_LABEL"))
		Assert.assertNotNull(url)
		Logger.info(this, "url: %s", url)
	}

}
