package org.oddgen.sqldev.net;

import java.io.IOException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLStreamHandler;
import java.net.URLStreamHandlerFactory;
import oracle.ide.net.AbstractURLStreamHandler;
import org.oddgen.sqldev.net.OddgenURLFileSystemHelper;

@SuppressWarnings("all")
public class OddgenUrlStreamHandlerFactory implements URLStreamHandlerFactory {
  public static class OddgenURLHandler extends AbstractURLStreamHandler {
    @Override
    public URLConnection openConnection(final URL url) throws IOException {
      return null;
    }
  }
  
  @Override
  public URLStreamHandler createURLStreamHandler(final String protocol) {
    boolean _equals = protocol.equals(OddgenURLFileSystemHelper.PROTOCOL);
    if (_equals) {
      return new OddgenUrlStreamHandlerFactory.OddgenURLHandler();
    }
    return null;
  }
}
