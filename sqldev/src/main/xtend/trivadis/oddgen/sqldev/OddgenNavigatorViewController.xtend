package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.event.ActionEvent
import oracle.ide.Context
import oracle.ide.Ide
import oracle.ide.controller.IdeAction
import oracle.ideri.navigator.ShowNavigatorController

@Loggable(prepend=true)
class OddgenNavigatorViewController extends ShowNavigatorController {
	public static final int SHOW_ODDGEN_NAVIGATOR_CMD_ID = Ide.findOrCreateCmdID("oddgen.SHOW_NAVIGATOR");
	private boolean initialized = false

	override boolean update(IdeAction action, Context context) {
		Logger.debug(this, "expected id: " + SHOW_ODDGEN_NAVIGATOR_CMD_ID)
		val id = action.getCommandId();
		Logger.debug(this, "id: "+ id)
		if (id == SHOW_ODDGEN_NAVIGATOR_CMD_ID) {
			action.enabled = true
		}
		return action.enabled;
	}

	override boolean handleEvent(IdeAction action, Context context) {
		Logger.debug(this, "expected action: "+ SHOW_ODDGEN_NAVIGATOR_CMD_ID)
		if (action != null) {
 			Logger.debug(this, "got action.commandId: " + action.commandId)
		}
		if (action == null || action.commandId == SHOW_ODDGEN_NAVIGATOR_CMD_ID && !initialized) {
			initialized = true;
			val navigatorManager = OddgenNavigatorManager.instance
			Logger.debug(this, "navigator manager: " + navigatorManager)
			val show = navigatorManager.getShowAction();
			Logger.debug(this, "showAction: " + show)
			show.actionPerformed(context.event as ActionEvent);
			return true;
		} else if (action != null) {
			Logger.debug(this, "else showAction: " + action)
			return true;
			
		}
		return false;
	}
	
	override protected getNavigatorManager() {
		return OddgenNavigatorManager.getInstance();
	}
}