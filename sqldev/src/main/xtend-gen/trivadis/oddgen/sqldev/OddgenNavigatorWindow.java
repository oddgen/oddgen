package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import java.awt.Component;
import javax.swing.Icon;
import oracle.ide.Context;
import oracle.ide.controls.Toolbar;
import oracle.ideri.navigator.DefaultNavigatorWindow;
import oracle.javatools.ui.table.ToolbarButton;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import trivadis.oddgen.sqldev.OddgenConnectionPanel;
import trivadis.oddgen.sqldev.resources.OddgenResources;

@SuppressWarnings("all")
public class OddgenNavigatorWindow extends DefaultNavigatorWindow {
  private final static Logger logger = LoggerFactory.getLogger(OddgenNavigatorWindow.class.getName());
  
  private Component gui;
  
  private Toolbar tb;
  
  private ToolbarButton refreshButton;
  
  private ToolbarButton collapseallButton;
  
  private OddgenConnectionPanel connectionPanel;
  
  public OddgenNavigatorWindow(final Context context, final String string) {
    super(context, string);
  }
  
  @Loggable(prepend = true)
  public Component getGui() {
    boolean _equals = Objects.equal(this.gui, null);
    if (_equals) {
      Component _gUI = super.getGUI();
      this.gui = _gUI;
      String _string = OddgenResources.getString("NAVIGATOR_TITLE");
      this.setTitle(_string);
      this.setToolbarVisible(true);
      Toolbar _toolbar = this.getToolbar();
      this.tb = _toolbar;
      OddgenConnectionPanel _oddgenConnectionPanel = new OddgenConnectionPanel();
      this.connectionPanel = _oddgenConnectionPanel;
      this.connectionPanel.setConnectionPrompt(null);
      this.connectionPanel.setConnectionLabel(null);
      this.connectionPanel.setAddButtons(false);
      this.tb.add(this.connectionPanel);
      Icon _icon = OddgenResources.getIcon("REFRESH_ICON");
      ToolbarButton _toolbarButton = new ToolbarButton(_icon);
      this.refreshButton = _toolbarButton;
      this.tb.add(this.refreshButton);
      Icon _icon_1 = OddgenResources.getIcon("COLLAPSEALL_ICON");
      ToolbarButton _toolbarButton_1 = new ToolbarButton(_icon_1);
      this.collapseallButton = _toolbarButton_1;
      this.tb.add(this.collapseallButton);
      this.tb.validate();
      OddgenNavigatorWindow.logger.info("OddgenNavigatorWindow initialized");
    }
    return this.gui;
  }
}
