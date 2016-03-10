package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.event.ActionEvent
import oracle.dbtools.worksheet.editor.OpenWorksheetWizard
import oracle.dbtools.worksheet.editor.Worksheet
import oracle.ide.Context
import oracle.ide.Ide
import oracle.ide.controller.IdeAction
import oracle.ideri.navigator.ShowNavigatorController
import oracle.javatools.dialogs.MessageDialog
import oracle.javatools.editor.BasicEditorPane
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.model.DatabaseGenerator
import org.oddgen.sqldev.model.ObjectName

@Loggable(value=LoggableConstants.DEBUG, prepend=true)
class OddgenNavigatorController extends ShowNavigatorController {
	private static OddgenNavigatorController INSTANCE

	private static final int GENERATE_TO_WORKSHEET_CMD_ID = Ide.findOrCreateCmdID("ODDGEN_GENERATE_TO_WORKSHEET")
	private static final int GENERATE_TO_CLIPBOARD_CMD_ID = Ide.findOrCreateCmdID("ODDGEN_GENERATE_TO_CLIPBOARD")
	private static final int GENERATE_DIALOG_CMD_ID = Ide.findOrCreateCmdID("ODDGEN_GENERATE_DIALOG")
	public static final IdeAction GENERATE_TO_WORKSHEET_ACTION = getAction(GENERATE_TO_WORKSHEET_CMD_ID)
	public static final IdeAction GENERATE_TO_CLIPBOARD_ACTION = getAction(GENERATE_TO_CLIPBOARD_CMD_ID)
	public static final IdeAction GENERATE_DIALOG_ACTION = getAction(GENERATE_DIALOG_CMD_ID)

	public static final int SHOW_ODDGEN_NAVIGATOR_CMD_ID = Ide.findOrCreateCmdID("ODDGEN_SHOW_NAVIGATOR")
	private boolean initialized = false

	def private static IdeAction getAction(int actionId) {
		val action = IdeAction.get(actionId)
		action.addController(getInstance())
		return action
	}

	def static synchronized getInstance() {
		if (INSTANCE == null) {
			INSTANCE = new OddgenNavigatorController()
		}
		return INSTANCE
	}

	def generateToWorksheet(Context context) {
		val worksheet = OpenWorksheetWizard.openNewTempWorksheet("oddgen", null) as Worksheet
		worksheet.comboConnection = null
		val editorPane = worksheet.getDefaultFocusComponent() as BasicEditorPane
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		val dao = new DatabaseGeneratorDao(conn)
		val result = '''
				«FOR selection : context.selection SEPARATOR '\n'»
					«val node = selection as ObjectNameNode»
					«Logger.debug(this, "Generating %s to worksheet...", node.shortLabel)»
					«val objectName = node.data as ObjectName»
					«val dbgen = (objectName.objectType.generator as DatabaseGenerator).clone as DatabaseGenerator»
					«dbgen.objectType = objectName.objectType.name»
					«dbgen.objectName = objectName.name»
					«dao.generate(dbgen)»
				«ENDFOR»
		'''
		editorPane.text = result
	}

	override update(IdeAction action, Context context) {
		val id = action.getCommandId()
		if (id == SHOW_ODDGEN_NAVIGATOR_CMD_ID) {
			Logger.debug(this, "enable oddgen navigator window.")
			action.enabled = true
		} else if (id == GENERATE_TO_WORKSHEET_CMD_ID || id == GENERATE_TO_CLIPBOARD_CMD_ID ||
			id == GENERATE_DIALOG_CMD_ID) {
			action.enabled = false
			if (context.selection.length > 0) {
				if (context.selection.get(0) instanceof ObjectNameNode) {
					action.enabled = true
					Logger.debug(this, "enable generator command.")
				}
			}
		}
		return action.enabled
	}

	override handleEvent(IdeAction action, Context context) {
		if (action != null) {
			if (action.commandId == SHOW_ODDGEN_NAVIGATOR_CMD_ID) {
				if (!initialized) {
					initialized = true
					val navigatorManager = OddgenNavigatorManager.instance
					val show = navigatorManager.getShowAction()
					show.actionPerformed(context.event as ActionEvent)
				}
				return true
			} else if (action.commandId == GENERATE_TO_WORKSHEET_CMD_ID) {
				// run it in this thread to avoid deadlocks
				generateToWorksheet(context)
//				val Runnable runnable = [|generateToWorksheet(context)]
//				val thread = new Thread(runnable)
//				thread.name = "oddgen Worksheet Generator"
//				thread.start
				return true
			} else if (action.commandId == GENERATE_TO_CLIPBOARD_CMD_ID) {
				MessageDialog.information(OddgenNavigatorManager.instance.navigatorWindow.GUI,
					"Generate to clipboard is currently not implemented.", "oddgen", null);
				return true
			} else if (action.commandId == GENERATE_DIALOG_CMD_ID) {
				MessageDialog.information(OddgenNavigatorManager.instance.navigatorWindow.GUI,
					"Generate dialog is currently not implemented.", "oddgen", null);
				return true
			}
		}
		return false
	}

	override protected getNavigatorManager() {
		return OddgenNavigatorManager.getInstance()
	}
}
