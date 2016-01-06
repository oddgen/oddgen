package org.oddgen.sqldev.net;

import java.net.URL;
import oracle.ide.net.URLFileSystemHelper;

@SuppressWarnings("all")
public class OddgenURLFileSystemHelper extends URLFileSystemHelper {
  public final static String PROTOCOL = "oddgen.generators";
  
  @Override
  public long lastModified(final URL url) {
    return Long.MAX_VALUE;
  }
}
