package org.oddgen.sqldev.net

import java.io.IOException
import java.net.URL
import java.net.URLConnection
import java.net.URLStreamHandlerFactory
import oracle.ide.net.AbstractURLStreamHandler

class OddgenUrlStreamHandlerFactory implements URLStreamHandlerFactory {

	override createURLStreamHandler(String protocol) {
		if (protocol.equals(OddgenURLFileSystemHelper.PROTOCOL)) {
			return new OddgenURLHandler();
		}
		return null;
	}

	static class OddgenURLHandler extends AbstractURLStreamHandler {
		override URLConnection openConnection(URL url) throws IOException {
			return null;
		}
	}
}