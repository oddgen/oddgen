package org.oddgen.sqldev.net

import java.io.IOException
import java.net.URL
import java.net.URLStreamHandlerFactory
import oracle.ide.net.AbstractURLStreamHandler

class OddgenUrlStreamHandlerFactory implements URLStreamHandlerFactory {

	override createURLStreamHandler(String protocol) {
		if (protocol == OddgenURLFileSystemHelper.PROTOCOL) {
			return new OddgenURLHandler()
		}
		return null
	}

	static class OddgenURLHandler extends AbstractURLStreamHandler {
		override openConnection(URL url) throws IOException {
			return null
		}
	}
}