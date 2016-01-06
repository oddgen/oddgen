package org.oddgen.sqldev.tests;

import com.jcabi.log.Logger;
import java.net.URL;
import oracle.ide.net.URLFactory;
import oracle.ide.net.URLFileSystem;
import org.junit.Assert;
import org.junit.Test;
import org.oddgen.sqldev.net.OddgenURLFileSystemHelper;
import org.oddgen.sqldev.net.OddgenUrlStreamHandlerFactory;
import org.oddgen.sqldev.resources.OddgenResources;

@SuppressWarnings("all")
public class UrlTest {
  @Test
  public void newUrlTest() {
    final OddgenUrlStreamHandlerFactory factory = new OddgenUrlStreamHandlerFactory();
    final OddgenURLFileSystemHelper helper = new OddgenURLFileSystemHelper();
    URLFileSystem.addURLStreamHandlerFactory(OddgenURLFileSystemHelper.PROTOCOL, factory);
    URLFileSystem.registerHelper(OddgenURLFileSystemHelper.PROTOCOL, helper);
    String _get = OddgenResources.get("ROOT_NODE_LONG_LABEL");
    final URL url = URLFactory.newURL(OddgenURLFileSystemHelper.PROTOCOL, _get);
    Assert.assertNotNull(url);
    Logger.info(this, "url: %s", url);
  }
}
