package org.oddgen.sqldev.resources;

import java.awt.Image;
import javax.swing.Icon;
import oracle.dbtools.raptor.utils.MessagesBase;

@SuppressWarnings("all")
public class OddgenResources extends MessagesBase {
  private final static ClassLoader CLASS_LOADER = OddgenResources.class.getClassLoader();
  
  private final static String CLASS_NAME = OddgenResources.class.getCanonicalName();
  
  private final static OddgenResources INSTANCE = new OddgenResources();
  
  private OddgenResources() {
    super(OddgenResources.CLASS_NAME, OddgenResources.CLASS_LOADER);
  }
  
  public static String getString(final String paramString) {
    return OddgenResources.INSTANCE.getStringImpl(paramString);
  }
  
  public static String get(final String paramString) {
    return OddgenResources.getString(paramString);
  }
  
  public static Image getImage(final String paramString) {
    return OddgenResources.INSTANCE.getImageImpl(paramString);
  }
  
  public static String format(final String paramString, final Object... paramVarArgs) {
    return OddgenResources.INSTANCE.formatImpl(paramString, paramVarArgs);
  }
  
  public static Icon getIcon(final String paramString) {
    return OddgenResources.INSTANCE.getIconImpl(paramString);
  }
  
  public static Integer getInteger(final String paramString) {
    return OddgenResources.INSTANCE.getIntegerImpl(paramString);
  }
}
