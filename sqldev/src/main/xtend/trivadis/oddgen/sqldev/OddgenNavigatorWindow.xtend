package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.Component
import oracle.ide.Context
import oracle.ide.controls.Toolbar
import oracle.ideri.navigator.DefaultNavigatorWindow
import oracle.javatools.ui.table.ToolbarButton
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import trivadis.oddgen.sqldev.resources.OddgenResources

class OddgenNavigatorWindow extends DefaultNavigatorWindow {
	static final Logger logger = LoggerFactory.getLogger(OddgenNavigatorWindow.name)
	private Component gui
	private Toolbar tb;
	private ToolbarButton refreshButton;
	private ToolbarButton collapseallButton;
	private OddgenConnectionPanel connectionPanel;

	new(Context context, String string) {
		super(context, string)
	}

	@Loggable(prepend=true)
	def Component getGui() {
		if (gui == null) {
			gui = super.getGUI()
			this.title = OddgenResources.getString("NAVIGATOR_TITLE")
			toolbarVisible = true
			tb = toolbar
			connectionPanel = new OddgenConnectionPanel()
			connectionPanel.connectionPrompt = null
			connectionPanel.connectionLabel = null
			connectionPanel.addButtons = false
			tb.add(connectionPanel)
			refreshButton = new ToolbarButton(OddgenResources.getIcon("REFRESH_ICON"))
			tb.add(refreshButton)
			collapseallButton = new ToolbarButton(OddgenResources.getIcon("COLLAPSEALL_ICON"))
			tb.add(collapseallButton)
			tb.validate
			logger.info("OddgenNavigatorWindow initialized")
		}
		return gui;
	}
}