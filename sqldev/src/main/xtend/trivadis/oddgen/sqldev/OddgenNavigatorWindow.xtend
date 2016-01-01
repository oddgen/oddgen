package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.Component
import oracle.ide.Context
import oracle.ideri.navigator.DefaultNavigatorWindow
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class OddgenNavigatorWindow extends DefaultNavigatorWindow {
	static final Logger logger = LoggerFactory.getLogger(OddgenNavigatorWindow.name)
	private Component gui

	new(Context context, String string) {
		super(context, string)
	}

	@Loggable(prepend=true)
	def Component getGui() {
		if (gui == null) {
			gui = super.getGUI();
			logger.info("initialized")
		}
		return gui;
	}
}