package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import java.awt.Component;
import java.awt.Dimension;
import javax.swing.Icon;
import oracle.ide.Context;
import oracle.ide.controls.Toolbar;
import oracle.ide.util.PropertyAccess;
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
  @Override
  public Component getGUI() {
    boolean _equals = Objects.equal(this.gui, null);
    if (_equals) {
      Component _gUI = super.getGUI();
      this.gui = _gUI;
      OddgenNavigatorWindow.logger.info("OddgenNavigatorWindow initialized");
    }
    return this.gui;
  }
  
  @Loggable(prepend = true)
  @Override
  public String getTitleName() {
    return OddgenResources.getString("NAVIGATOR_TITLE");
  }
  
  @Loggable(prepend = true)
  protected Component createToolbar() {
    Component _xblockexpression = null;
    {
      boolean _notEquals = (!Objects.equal(this.tb, null));
      if (_notEquals) {
        this.tb.dispose();
      }
      boolean _equals = Objects.equal(this.connectionPanel, null);
      if (_equals) {
        OddgenConnectionPanel _oddgenConnectionPanel = new OddgenConnectionPanel();
        this.connectionPanel = _oddgenConnectionPanel;
        this.connectionPanel.setConnectionPrompt(null);
        this.connectionPanel.setConnectionLabel(null);
        this.connectionPanel.setAddButtons(false);
        Dimension _dimension = new Dimension(300, 50);
        this.connectionPanel.setMaximumSize(_dimension);
        Dimension _dimension_1 = new Dimension(100, 0);
        this.connectionPanel.setMinimumSize(_dimension_1);
        Icon _icon = OddgenResources.getIcon("REFRESH_ICON");
        ToolbarButton _toolbarButton = new ToolbarButton(_icon);
        this.refreshButton = _toolbarButton;
        Icon _icon_1 = OddgenResources.getIcon("COLLAPSEALL_ICON");
        ToolbarButton _toolbarButton_1 = new ToolbarButton(_icon_1);
        this.collapseallButton = _toolbarButton_1;
      }
      this.setToolbarVisible(true);
      Toolbar _toolbar = this.getToolbar();
      this.tb = _toolbar;
      if (this.tb!=null) {
        this.tb.add(this.connectionPanel);
      }
      if (this.tb!=null) {
        this.tb.add(this.refreshButton);
      }
      Component _add = null;
      if (this.tb!=null) {
        _add=this.tb.add(this.collapseallButton);
      }
      _xblockexpression = _add;
    }
    return _xblockexpression;
  }
  
  @Loggable(prepend = true)
  @Override
  public void show() {
    this.createToolbar();
    super.show();
    OddgenNavigatorWindow.logger.info("OddgenNavigatorWindow initialized");
  }
  
  @Loggable(prepend = true)
  @Override
  public void saveLayout(final PropertyAccess p) {
    super.saveLayout(p);
  }
  
  @Loggable(prepend = true)
  @Override
  public void loadLayout(final PropertyAccess p) {
    super.loadLayout(p);
  }
}
