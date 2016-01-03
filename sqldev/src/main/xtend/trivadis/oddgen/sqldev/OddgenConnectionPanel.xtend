package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.GridBagConstraints
import javax.swing.JPanel
import oracle.dbtools.raptor.controls.ConnectionPanelUI

class OddgenConnectionPanel extends ConnectionPanelUI {

	private boolean addButtons

	new() {
		// Oracle connections only, no details, no unshared connections
		super(#["oraJDBC"], false, false)
	}

	@Loggable(prepend=true)
	override protected void addButtons(JPanel panel, GridBagConstraints constraints) {
		if (addButtons) {
			super.addButtons(panel, constraints)
		}
	}
	
	@Loggable(prepend=true)
	def setAddButtons(boolean addButtons) {
		this.addButtons = addButtons
	}

}