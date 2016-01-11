package org.oddgen.sqldev;

import com.google.common.base.Objects;
import com.jcabi.aspects.Loggable;
import com.jcabi.log.Logger;
import java.awt.Component;
import java.awt.Container;
import java.awt.GridBagConstraints;
import java.awt.event.ItemEvent;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import javax.swing.JComboBox;
import javax.swing.JPanel;
import oracle.dbtools.db.ConnectionResolver;
import oracle.dbtools.raptor.controls.ConnectionPanelUI;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.oddgen.sqldev.LoggableConstants;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenConnectionPanel extends ConnectionPanelUI {
  private static boolean ADD_BUTTONS = false;
  
  protected static List<JComboBox<?>> getComboBoxList(final Container container) {
    final ArrayList<JComboBox<?>> list = new ArrayList<JComboBox<?>>();
    Component[] _components = container.getComponents();
    for (final Component comp : _components) {
      if ((comp instanceof JComboBox<?>)) {
        list.add(((JComboBox<?>) comp));
      } else {
        if ((comp instanceof Container)) {
          List<JComboBox<?>> _comboBoxList = OddgenConnectionPanel.getComboBoxList(((Container) comp));
          list.addAll(_comboBoxList);
        }
      }
    }
    Logger.debug(OddgenConnectionPanel.class, "JComboBox list: %s", list);
    return list;
  }
  
  public OddgenConnectionPanel() {
    super(new String[] { "oraJDBC" }, false, false);
    List<JComboBox<?>> _comboBoxList = OddgenConnectionPanel.getComboBoxList(this);
    final JComboBox<?> connComboBox = _comboBoxList.get(0);
    connComboBox.putClientProperty("JComboBox.isTableCellEditor", Boolean.TRUE);
  }
  
  @Loggable(value = LoggableConstants.DEBUG, prepend = true)
  @Override
  protected void addButtons(final JPanel panel, final GridBagConstraints constraints) {
    if (OddgenConnectionPanel.ADD_BUTTONS) {
      super.addButtons(panel, constraints);
      Logger.debug(this, "super.addButtons called.");
    }
  }
  
  protected Object openConnection() {
    Object _xblockexpression = null;
    {
      final int prevLoginTimeout = DriverManager.getLoginTimeout();
      DriverManager.setLoginTimeout(5);
      int _loginTimeout = DriverManager.getLoginTimeout();
      Logger.debug(this, "login timeout reset set to %d", Integer.valueOf(_loginTimeout));
      Object _xtrycatchfinallyexpression = null;
      try {
        Object _xblockexpression_1 = null;
        {
          String _connectionName = this.getConnectionName();
          final Properties connectionInfo = ConnectionPanelUI.s_conns.getConnectionInfo(_connectionName);
          Logger.debug(this, "connectionInfo %s", connectionInfo);
          Object _xifexpression = null;
          boolean _notEquals = (!Objects.equal(connectionInfo, null));
          if (_notEquals) {
            Object _xblockexpression_2 = null;
            {
              Class<? extends ConnectionResolver> _class = ConnectionPanelUI.s_conns.getClass();
              String _connectionName_1 = this.getConnectionName();
              String _connectionName_2 = this.getConnectionName();
              String _connectionType = ConnectionPanelUI.s_conns.getConnectionType(_connectionName_2);
              Logger.debug(this, "connection resolver class %1$s for connection name %2$s of type %3$s", _class, _connectionName_1, _connectionType);
              String _connectionName_3 = this.getConnectionName();
              final Connection conn = ConnectionPanelUI.s_conns.getConnection(_connectionName_3);
              Logger.debug(this, "connected to %s", conn);
              Object _xifexpression_1 = null;
              boolean _notEquals_1 = (!Objects.equal(conn, null));
              if (_notEquals_1) {
                Object _xifexpression_2 = null;
                boolean _isClosed = conn.isClosed();
                if (_isClosed) {
                  _xifexpression_2 = null;
                }
                _xifexpression_1 = _xifexpression_2;
              }
              _xblockexpression_2 = _xifexpression_1;
            }
            _xifexpression = _xblockexpression_2;
          }
          _xblockexpression_1 = _xifexpression;
        }
        _xtrycatchfinallyexpression = _xblockexpression_1;
      } catch (final Throwable _t) {
        if (_t instanceof Exception) {
          final Exception e = (Exception)_t;
          String _connectionName = this.getConnectionName();
          String _message = e.getMessage();
          Logger.error(this, "Cannot connect to %1$s. Got error %2$s.", _connectionName, _message);
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      } finally {
        DriverManager.setLoginTimeout(prevLoginTimeout);
        Logger.debug(this, "login timeout reset to original value oft %d", Integer.valueOf(prevLoginTimeout));
      }
      _xblockexpression = _xtrycatchfinallyexpression;
    }
    return _xblockexpression;
  }
  
  @Override
  public void itemStateChanged(final ItemEvent event) {
    int _stateChange = event.getStateChange();
    boolean _equals = (_stateChange == ItemEvent.SELECTED);
    if (_equals) {
      this.checkConnection();
      final Runnable _function = new Runnable() {
        @Override
        public void run() {
          OddgenConnectionPanel.this.openConnection();
        }
      };
      final Runnable runnable = _function;
      final Thread thread = new Thread(runnable);
      thread.setName("oddgen Connection Opener");
      thread.start();
    }
  }
}
