package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import oracle.dbtools.raptor.RaptorExtensionConstants
import oracle.ide.Context
import oracle.ide.controller.IdeAction
import oracle.ide.docking.DockingParam
import oracle.ide.help.HelpInfo
import oracle.ide.layout.ViewId
import oracle.ideri.navigator.DefaultNavigatorManager
import oracle.ideri.navigator.DefaultNavigatorWindow
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class OddgenNavigatorManager extends DefaultNavigatorManager {
	static final Logger logger = LoggerFactory.getLogger(OddgenNavigatorManager.name)
	private static final String NAVIGATOR_WINDOW_ID = "oddgen.NAVIGATOR_WINDOW";
	private static final String DEFAULT_NAME = "oddgen";

	static private OddgenNavigatorManager instance = null

	new() {
		// TODO: define and include accelerators
		// val registry = Ide.getKeyStrokeContextRegistry();
		// registry.addAcceleratorDefinitionFile(getClass().getClassLoader(),
		// "/trivadis/oddgen/sqldev/resources/accelerators.xml");
	}

	@Loggable(prepend=true)
	def static OddgenNavigatorManager getInstance() {
		if (instance == null) {
			instance = new OddgenNavigatorManager
			logger.info("OddgenNavigatorManager initialized")
		}
		return instance
	}

	@Loggable(prepend=true)
	override protected createShowNavigatorAction() {
		return IdeAction.find(OddgenNavigatorViewController::SHOW_ODDGEN_NAVIGATOR_CMD_ID)
	}

	@Loggable(prepend=true)
	override protected createNavigatorWindow() {
		return createNavigatorWindow(RootNode.getInstance(), true, if (RaptorExtensionConstants.isStandAlone()) {
			1
		} else {
			0
		});
	}

	@Loggable(prepend=true)
	override protected DefaultNavigatorWindow createNavigatorWindow(Context context, ViewId viewId) {
		return new OddgenNavigatorWindow(context, viewId.id);
	}

	@Loggable(prepend=true)
	override protected getDefaultName() {
		return DEFAULT_NAME
	}

	@Loggable(prepend=true)
	override protected getViewCategory() {
		return NAVIGATOR_WINDOW_ID
	}

	@Loggable(prepend=true)
	override protected createDockableFactory() {
		return null
	}

	@Loggable(prepend=true)
	override protected createNavigatorDockingParam() {
		val dockingParam = new DockingParam();
		return dockingParam;
	}

	@Loggable(prepend=true)
	override HelpInfo getHelpInfo() {
		// TODO: provide some help
		return super.helpInfo
	}
}