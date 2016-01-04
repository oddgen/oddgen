package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import oracle.dbtools.raptor.RaptorExtensionConstants
import oracle.ide.Context
import oracle.ide.IdeConstants
import oracle.ide.controller.IdeAction
import oracle.ide.docking.DockStation
import oracle.ide.docking.DockingParam
import oracle.ide.help.HelpInfo
import oracle.ide.layout.ViewId
import oracle.ideri.navigator.DefaultNavigatorManager
import oracle.ideri.navigator.DefaultNavigatorWindow
import org.slf4j.Logger
import org.slf4j.LoggerFactory

@Loggable(prepend=true)
class OddgenNavigatorManager extends DefaultNavigatorManager {
	private static final Logger LOGGER = LoggerFactory.getLogger(OddgenNavigatorManager.name)
	private static final String NAVIGATOR_WINDOW_ID = "oddgen.NAVIGATOR_WINDOW";

	static private OddgenNavigatorManager INSTANCE = null

	new() {
		// TODO: define and include accelerators
		// val registry = Ide.getKeyStrokeContextRegistry();
		// registry.addAcceleratorDefinitionFile(getClass().getClassLoader(),
		// "/trivadis/oddgen/sqldev/resources/accelerators.xml");
	}

	def static OddgenNavigatorManager getInstance() {
		if (INSTANCE == null) {
			INSTANCE = new OddgenNavigatorManager
			LOGGER.info("OddgenNavigatorManager initialized")
		}
		return INSTANCE
	}

	override protected createShowNavigatorAction() {
		return IdeAction.find(OddgenNavigatorViewController::SHOW_ODDGEN_NAVIGATOR_CMD_ID)
	}

	override protected createNavigatorWindow() {
		return createNavigatorWindow(RootNode.getInstance(), true, if (RaptorExtensionConstants.isStandAlone()) {
			1
		} else {
			0
		});
	}

	override protected DefaultNavigatorWindow createNavigatorWindow(Context context, ViewId viewId) {
		val window = new OddgenNavigatorWindow(context, viewId.id)
		return window;
	}

	override protected getDefaultName() {
		return "Default"
	}

	override protected getViewCategory() {
		return NAVIGATOR_WINDOW_ID
	}

	override protected createDockableFactory() {
		return null
	}

	override protected createNavigatorDockingParam() {
		val param = new DockingParam();
		val referenceView = new ViewId("DatabaseNavigatorWindow", "Default")
		val referenceDockable = DockStation.dockStation.findDockable(referenceView)
		param.setPosition(referenceDockable, IdeConstants.SOUTH, IdeConstants.WEST)
		return param
	}

	override HelpInfo getHelpInfo() {
		// TODO: provide some help
		return super.helpInfo
	}
}