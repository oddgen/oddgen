package org.oddgen.sqldev;

import com.jcabi.aspects.Loggable;
import java.awt.GridBagConstraints;
import javax.swing.JPanel;
import oracle.dbtools.raptor.controls.ConnectionPanelUI;

@Loggable(prepend = true)
@SuppressWarnings("all")
public class OddgenConnectionPanel extends ConnectionPanelUI {
  private boolean addButtons;
  
  public OddgenConnectionPanel() {
    super(new String[] { "oraJDBC" }, false, false);
  }
  
  @Override
  protected void addButtons(final JPanel panel, final GridBagConstraints constraints) {
    if (this.addButtons) {
      super.addButtons(panel, constraints);
    }
  }
  
  public boolean setAddButtons(final boolean addButtons) {
    return this.addButtons = addButtons;
  }
}
