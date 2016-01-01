package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import java.awt.Component;
import oracle.ide.Context;
import oracle.ideri.navigator.DefaultNavigatorWindow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("all")
public class OddgenNavigatorWindow extends DefaultNavigatorWindow {
  private final static Logger logger = LoggerFactory.getLogger(OddgenNavigatorWindow.class.getName());
  
  private Component gui;
  
  public OddgenNavigatorWindow(final Context context, final String string) {
    super(context, string);
  }
  
  @Loggable(prepend = true)
  public Component getGui() {
    boolean _equals = Objects.equal(this.gui, null);
    if (_equals) {
      Component _gUI = super.getGUI();
      this.gui = _gUI;
      OddgenNavigatorWindow.logger.info("initialized");
    }
    return this.gui;
  }
}
