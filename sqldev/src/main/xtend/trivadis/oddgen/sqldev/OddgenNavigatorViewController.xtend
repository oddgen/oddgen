package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.event.ActionEvent
import oracle.ide.Context
import oracle.ide.Ide
import oracle.ide.controller.IdeAction
import oracle.ideri.navigator.ShowNavigatorController
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class OddgenNavigatorViewController extends ShowNavigatorController {
	static final Logger logger = LoggerFactory.getLogger(OddgenNavigatorViewController.name)
	public static final int SHOW_ODDGEN_NAVIGATOR_CMD_ID = Ide.findOrCreateCmdID("oddgen.SHOW_NAVIGATOR");
	private boolean initialized = false

	@Loggable(prepend=true)
	override boolean update(IdeAction action, Context context) {
		logger.debug("expected id: " + SHOW_ODDGEN_NAVIGATOR_CMD_ID)
		val id = action.getCommandId();
		logger.debug("id: "+ id)
		if (id == SHOW_ODDGEN_NAVIGATOR_CMD_ID) {
			action.enabled = true
		}
		return action.enabled;
	}

	@Loggable(prepend=true)
	override boolean handleEvent(IdeAction action, Context context) {
		logger.debug("expected action: "+ SHOW_ODDGEN_NAVIGATOR_CMD_ID)
		if (action != null) {
 			logger.debug("got action.commandId: " + action.commandId)
		}
		if (action == null || action.commandId == SHOW_ODDGEN_NAVIGATOR_CMD_ID && !initialized) {
			initialized = true;
			//OddgenDockableFactory.showOddgenNavigatorWindow
			logger.debug("window factory called")
			val navigatorManager = OddgenNavigatorManager.instance;
			logger.debug("navigator manager: " + navigatorManager)
			val show = navigatorManager.getShowAction();
			logger.debug("showAction: " + show)
			show.actionPerformed(context.event as ActionEvent);
			return true;
		}
		return false;
	}

	@Loggable(prepend=true)
	override protected getNavigatorManager() {
		return OddgenNavigatorManager.getInstance();
	}


}