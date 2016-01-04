package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.event.ActionEvent
import oracle.ide.Context
import oracle.ide.Ide
import oracle.ide.controller.IdeAction
import oracle.ideri.navigator.ShowNavigatorController
import org.slf4j.Logger
import org.slf4j.LoggerFactory

@Loggable(prepend=true)
class OddgenNavigatorViewController extends ShowNavigatorController {
	private static final Logger LOGGER = LoggerFactory.getLogger(OddgenNavigatorViewController.name)
	public static final int SHOW_ODDGEN_NAVIGATOR_CMD_ID = Ide.findOrCreateCmdID("oddgen.SHOW_NAVIGATOR");
	private boolean initialized = false

	override boolean update(IdeAction action, Context context) {
		LOGGER.debug("expected id: " + SHOW_ODDGEN_NAVIGATOR_CMD_ID)
		val id = action.getCommandId();
		LOGGER.debug("id: "+ id)
		if (id == SHOW_ODDGEN_NAVIGATOR_CMD_ID) {
			action.enabled = true
		}
		return action.enabled;
	}

	override boolean handleEvent(IdeAction action, Context context) {
		LOGGER.debug("expected action: "+ SHOW_ODDGEN_NAVIGATOR_CMD_ID)
		if (action != null) {
 			LOGGER.debug("got action.commandId: " + action.commandId)
		}
		if (action == null || action.commandId == SHOW_ODDGEN_NAVIGATOR_CMD_ID && !initialized) {
			initialized = true;
			val navigatorManager = OddgenNavigatorManager.instance
			LOGGER.debug("navigator manager: " + navigatorManager)
			val show = navigatorManager.getShowAction();
			LOGGER.debug("showAction: " + show)
			show.actionPerformed(context.event as ActionEvent);
			return true;
		} else if (action != null) {
			LOGGER.debug("else showAction: " + action)
			return true;
			
		}
		return false;
	}
	
	override protected getNavigatorManager() {
		return OddgenNavigatorManager.getInstance();
	}
}