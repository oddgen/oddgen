/*
 * Copyright 2015-2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.Cursor
import java.awt.Toolkit
import java.awt.datatransfer.StringSelection
import java.awt.event.ActionEvent
import java.sql.Connection
import java.util.ArrayList
import java.util.List
import javax.swing.SwingUtilities
import oracle.dbtools.worksheet.editor.OpenWorksheetWizard
import oracle.dbtools.worksheet.editor.Worksheet
import oracle.ide.Context
import oracle.ide.Ide
import oracle.ide.controller.IdeAction
import oracle.ideri.navigator.ShowNavigatorController
import oracle.javatools.dialogs.MessageDialog
import org.oddgen.sqldev.model.GeneratorSelection
import org.oddgen.sqldev.model.ObjectName
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(value=LoggableConstants.DEBUG)
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

	def selectedDatabaseGenerators(Context context) {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		val gens = new ArrayList<GeneratorSelection>
		for (selection : context.selection) {
			val node = selection as ObjectNameNode
			val objectName = node.data as ObjectName
		 	val sel = new GeneratorSelection()
		 	sel.objectName = objectName
		 	sel.params = objectName.objectType.generator.getParams(conn, objectName.objectType.name, objectName.name)
			gens.add(sel)
		}
		return gens
	}

	@Loggable
	def generateToString(List<GeneratorSelection> gens, Connection conn) {
		var String result;
		val gui = OddgenNavigatorManager.instance.navigatorWindow.GUI
		try {
			gui.cursor = Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR)
			result = '''
				«FOR gen : gens SEPARATOR '\n'»
					«Logger.debug(this, "Generating %1$s.%2$s to string...", gen.objectName.objectType.name, gen.objectName.name)»
					«gen.objectName.objectType.generator.generate(conn, gen.objectName.objectType.name, gen.objectName.name, gen.params)»
				«ENDFOR»
			'''
		} finally {
			gui.cursor = Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR)
		}
		return result
	}

	def generateToWorksheet(List<GeneratorSelection> gens, Connection conn) {
		val result = gens.generateToString(conn)
		SwingUtilities.invokeAndWait(new Runnable() {
			override run() {
				val worksheet = OpenWorksheetWizard.openNewTempWorksheet(OddgenResources.getString("WORKSHEET_TITLE"), result) as Worksheet
				worksheet.comboConnection = null
			}
		});
	}

	def generateToClipboard(List<GeneratorSelection> gens, Connection conn) {
		val result = gens.generateToString(conn)
		SwingUtilities.invokeAndWait(
			new Runnable() {
				override run() {
					val selection = new StringSelection(result)
					val clipboard = Toolkit.getDefaultToolkit().getSystemClipboard()
					clipboard.setContents(selection, null)
					// dialog properties are managed in $HOME/.sqldeveloper/system*/o.ide.*/.oracle_javatools_msgdlg.properties
					// TODO: find out how to manage these properties via SQL Developer					
					MessageDialog.optionalInformation("oddgen: confirm generate to clipboard",
						OddgenNavigatorManager.instance.navigatorWindow.GUI, OddgenResources.getString("MESSAGE_DIALOG_CONFIRM_GENERATE_TO_CLIPBOARD_MESSAGE"),
						OddgenResources.getString("MESSAGE_DIALOG_CONFIRM_GENERATE_TO_CLIPBOARD_TITLE"), null);
				}
			});
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
				val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
				val dbgens = selectedDatabaseGenerators(context)
				val Runnable runnable = [|dbgens.generateToWorksheet(conn)]
				val thread = new Thread(runnable)
				thread.name = "oddgen Worksheet Generator"
				thread.start
				return true
			} else if (action.commandId == GENERATE_TO_CLIPBOARD_CMD_ID) {
				val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
				val dbgens = selectedDatabaseGenerators(context)
				val Runnable runnable = [|dbgens.generateToClipboard(conn)]
				val thread = new Thread(runnable)
				thread.name = "oddgen Clipboard Generator"
				thread.start
				return true
			} else if (action.commandId == GENERATE_DIALOG_CMD_ID) {
				val dbgens = selectedDatabaseGenerators(context)
				val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
				GenerateDialog.createAndShow(OddgenNavigatorManager.instance.navigatorWindow.GUI, dbgens, conn)
				return true
			}
		}
		return false
	}

	override protected getNavigatorManager() {
		return OddgenNavigatorManager.getInstance()
	}
}
