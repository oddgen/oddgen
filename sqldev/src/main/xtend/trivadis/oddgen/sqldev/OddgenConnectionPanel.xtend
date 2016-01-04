package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.GridBagConstraints
import javax.swing.JPanel
import oracle.dbtools.raptor.controls.ConnectionPanelUI

@Loggable(prepend=true)
class OddgenConnectionPanel extends ConnectionPanelUI {
	private boolean addButtons

	new() {
		// Oracle connections only, no details, no unshared connections
		super(#["oraJDBC"], false, false)
	}

	override protected void addButtons(JPanel panel, GridBagConstraints constraints) {
		if (addButtons) {
			super.addButtons(panel, constraints)
		}
	}

	def setAddButtons(boolean addButtons) {
		this.addButtons = addButtons
	}

}