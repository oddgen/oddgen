package trivadis.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import com.jcabi.log.Logger;
import java.awt.Component;
import java.awt.Dimension;
import javax.swing.Icon;
import oracle.ide.Context;
import oracle.ide.controls.Toolbar;
import oracle.ide.util.PropertyAccess;
import oracle.ideri.navigator.DefaultNavigatorWindow;
import oracle.javatools.ui.table.ToolbarButton;
import trivadis.oddgen.sqldev.LoggableConstants;
import trivadis.oddgen.sqldev.OddgenConnectionPanel;
import trivadis.oddgen.sqldev.resources.OddgenResources;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenNavigatorWindow extends DefaultNavigatorWindow {
  private Component gui;
  
  private Toolbar tb;
  
  private ToolbarButton refreshButton;
  
  private ToolbarButton collapseallButton;
  
  private OddgenConnectionPanel connectionPanel;
  
  public OddgenNavigatorWindow(final Context context, final String string) {
    super(context, string);
  }
  
  protected void initialize() {
    this.createToolbar();
    Logger.info(this, "OddgenNavigatorWindow initialized");
  }
  
  @Loggable(value = LoggableConstants.DEBUG, prepend = true)
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
  
  @Override
  public Component getGUI() {
    boolean _equals = Objects.equal(this.gui, null);
    if (_equals) {
      Component _gUI = super.getGUI();
      this.gui = _gUI;
      this.initialize();
    }
    return this.gui;
  }
  
  @Override
  public String getTitleName() {
    return OddgenResources.getString("NAVIGATOR_TITLE");
  }
  
  @Override
  public void show() {
    this.createToolbar();
    super.show();
    Logger.info(this, "OddgenNavigatorWindow shown");
  }
  
  @Override
  public void saveLayout(final PropertyAccess p) {
    super.saveLayout(p);
  }
  
  @Override
  public void loadLayout(final PropertyAccess p) {
    super.loadLayout(p);
  }
}
