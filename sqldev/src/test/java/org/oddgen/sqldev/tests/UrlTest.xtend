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
