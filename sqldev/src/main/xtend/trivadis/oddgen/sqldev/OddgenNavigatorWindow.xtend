package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.Component
import java.awt.Dimension
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
	override Component getGUI() {
		if (gui == null) {
			gui = super.getGUI()
			logger.info("OddgenNavigatorWindow initialized")
		}
		return gui;
	}
	
	@Loggable(prepend=true)
	def override getTitleName() {
		return OddgenResources.getString("NAVIGATOR_TITLE")
	}

	@Loggable(prepend=true)
	def protected createToolbar() {
		if (tb != null) {
			tb.dispose
		}
		if (connectionPanel == null) {
			connectionPanel = new OddgenConnectionPanel()
			connectionPanel.connectionPrompt = null
			connectionPanel.connectionLabel = null
			connectionPanel.addButtons = false
			connectionPanel.maximumSize = new Dimension(300,50)
			connectionPanel.minimumSize = new Dimension(100,0)
			refreshButton = new ToolbarButton(OddgenResources.getIcon("REFRESH_ICON"))
			collapseallButton = new ToolbarButton(OddgenResources.getIcon("COLLAPSEALL_ICON"))
		}
		toolbarVisible = true
		tb = toolbar
		tb?.add(connectionPanel)
		tb?.add(refreshButton)
		tb?.add(collapseallButton)
	}

	@Loggable(prepend=true)
	override show() {
		createToolbar
		super.show()
		logger.info("OddgenNavigatorWindow initialized")
	}
	

}