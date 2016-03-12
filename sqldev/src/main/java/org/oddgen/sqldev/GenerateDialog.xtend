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
import java.awt.BorderLayout
import java.awt.Component
import java.awt.Dimension
import java.awt.GridBagConstraints
import java.awt.GridBagLayout
import java.awt.Insets
import java.awt.Toolkit
import java.awt.event.ActionEvent
import java.awt.event.ActionListener
import java.awt.event.WindowEvent
import java.util.HashMap
import java.util.List
import javax.swing.BorderFactory
import javax.swing.DefaultComboBoxModel
import javax.swing.JButton
import javax.swing.JComboBox
import javax.swing.JDialog
import javax.swing.JLabel
import javax.swing.JPanel
import javax.swing.JScrollPane
import javax.swing.JTextField
import javax.swing.ScrollPaneConstants
import javax.swing.SwingUtilities
import org.oddgen.sqldev.model.DatabaseGenerator

@Loggable(value=LoggableConstants.DEBUG)
class GenerateDialog extends JDialog implements ActionListener {
	private List<DatabaseGenerator> dbgens

	private JButton buttonGenerateToWorksheet
	private JButton buttonGenerateToClipboard
	private JButton buttonCancel

	private JPanel paneParams;
	private int paramPos = -1;
	private HashMap<String, Component> params = new HashMap<String, Component>()

	def static createAndShow(Component parent, List<DatabaseGenerator> dbgens) {
		SwingUtilities.invokeLater(new Runnable() {
			override run() {
				GenerateDialog.createAndShowWithinEventThread(parent, dbgens);
			}
		});
	}

	def private static createAndShowWithinEventThread(Component parent, List<DatabaseGenerator> dbgens) {
		// create and layout the dialog
		val dialog = new GenerateDialog(parent, dbgens)
		dialog.pack
		// center dialog
		val dim = Toolkit.getDefaultToolkit().getScreenSize();
		dialog.setLocation(dim.width / 2 - dialog.getSize().width / 2, dim.height / 2 - dialog.getSize().height / 2);
		dialog.visible = true
	}

	new(Component parent, List<DatabaseGenerator> dbgens) {
		super(SwingUtilities.windowForComponent(parent), '''oddgen - «dbgens.get(0).name»''',
			ModalityType.APPLICATION_MODAL)
		this.dbgens = dbgens
		val pane = this.getContentPane();
		pane.setLayout(new GridBagLayout());
		val c = new GridBagConstraints();

		// description pane
		val paneDescription = new JPanel(new BorderLayout());
		val textDescription = new JLabel('''<html><p>«dbgens.get(0).description»</p></html>''')
		paneDescription.add(textDescription, BorderLayout.NORTH);
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 2;
		c.insets = new Insets(10, 20, 0, 20); // top, left, bottom, right
		c.anchor = GridBagConstraints.NORTH;
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 0;
		c.weighty = 0;
		pane.add(paneDescription, c)

		// Parameters pane
		paneParams = new JPanel(new GridBagLayout())
		addParam("Object type")
		addParam("Object name")
		for (param : dbgens.get(0).params.keySet) {
			param.addParam
		}
		val scrollPaneParameters = new JScrollPane(paneParams)
		scrollPaneParameters.verticalScrollBarPolicy = ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED
		scrollPaneParameters.horizontalScrollBarPolicy = ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER
		scrollPaneParameters.border = BorderFactory.createEmptyBorder;
		c.gridx = 0;
		c.gridy = 1;
		c.gridwidth = 2;
		c.insets = new Insets(10, 10, 0, 10); // top, left, bottom, right
		c.anchor = GridBagConstraints.NORTH;
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 1;
		c.weighty = 1;
		pane.add(scrollPaneParameters, c)

		// Buttons pane
		val panelButtons = new JPanel(new GridBagLayout())
		buttonGenerateToWorksheet = new JButton("Generate to worksheet");
		buttonGenerateToWorksheet.addActionListener(this);
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 1;
		c.insets = new Insets(0, 0, 0, 0); // top, left, bottom, right
		c.fill = GridBagConstraints.NONE;
		c.weightx = 0;
		c.weighty = 0;
		panelButtons.add(buttonGenerateToWorksheet, c);
		buttonGenerateToClipboard = new JButton("Generate to clipboard");
		buttonGenerateToClipboard.addActionListener(this);
		c.gridx = 1;
		c.insets = new Insets(0, 10, 0, 0); // top, left, bottom, right
		c.fill = GridBagConstraints.NONE;
		c.weightx = 0;
		c.weighty = 0;
		panelButtons.add(buttonGenerateToClipboard, c);
		buttonCancel = new JButton("Cancel");
		buttonCancel.addActionListener(this);
		c.gridx = 2;
		c.gridy = 0;
		c.gridwidth = 1;
		c.insets = new Insets(0, 10, 0, 0); // top, left, bottom, right
		c.fill = GridBagConstraints.NONE;
		c.weightx = 0;
		c.weighty = 0;
		panelButtons.add(buttonCancel, c);
		c.gridx = 1;
		c.gridy = 2;
		c.gridwidth = 1;
		c.insets = new Insets(30, 10, 10, 10); // top, left, bottom, right
		c.anchor = GridBagConstraints.EAST
		c.fill = GridBagConstraints.NONE
		c.weightx = 0;
		c.weighty = 0;
		pane.add(panelButtons, c);
		pane.setPreferredSize(new Dimension(600, 375));
		SwingUtilities.getRootPane(buttonGenerateToWorksheet).defaultButton = buttonGenerateToWorksheet

	}

	def private addParam(String name) {
		paramPos++
		val c = new GridBagConstraints();
		val label = new JLabel(name)
		val dbgen = dbgens.get(0)
		c.gridx = 0
		c.gridy = paramPos
		c.gridwidth = 1
		c.insets = new Insets(10, 10, 0, 0) // top, left, bottom, right
		c.anchor = GridBagConstraints.WEST
		c.fill = GridBagConstraints.HORIZONTAL
		c.weightx = 0
		c.weighty = 0
		paneParams.add(label, c);
		c.gridx = 1
		c.insets = new Insets(10, 10, 0, 10); // top, left, bottom, right
		c.weightx = 1
		if (name == "Object type") {
			val textObjectType = new JTextField(dbgen.objectType)
			textObjectType.editable = false
			textObjectType.enabled = false
			paneParams.add(textObjectType, c);
		} else if (name == "Object name") {
			val textObjectName = new JTextField(if(dbgens.size > 1) "***" else dbgen.objectName)
			textObjectName.editable = false
			textObjectName.enabled = false
			paneParams.add(textObjectName, c);
		} else {
			val lovs = dbgen.lovs.get(name)
			if (lovs != null && lovs.size > 0) {
				val comboBoxModel = new DefaultComboBoxModel<String>();
				for (lov : lovs) {
					comboBoxModel.addElement(lov)
				}
				val comboBox = new JComboBox<String>(comboBoxModel)
				comboBox.selectedItem = dbgen.params.get(name)
				paneParams.add(comboBox, c)
				params.put(name, comboBox)
			} else {
				val textField = new JTextField(dbgen.params.get(name))
				paneParams.add(textField, c);
				params.put(name, textField)
			}
		}
	}

	def updateDatabaseGenerators() {
		for (dbgen : dbgens) {
			for (name : dbgen.params.keySet) {
				val component = params.get(name)
				var String value
				if (component instanceof JTextField) {
					value = (component as JTextField).text
				} else {
					value = (component as JComboBox<String>).selectedItem as String
				}
				dbgen.params.put(name, value)
			}
		}
	}

	def exit() {
		this.dispatchEvent(new WindowEvent(this, WindowEvent.WINDOW_CLOSING));
	}

	def generateToWorksheet() {
		updateDatabaseGenerators()
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		OddgenNavigatorController.instance.generateToWorksheet(dbgens, conn)
	}

	def generateToClipboard() {
		updateDatabaseGenerators()
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		OddgenNavigatorController.instance.generateToClipboard(dbgens, conn)
	}

	override actionPerformed(ActionEvent e) {
		if (e.getSource == buttonCancel) {
			exit
		} else if (e.getSource == buttonGenerateToWorksheet) {
			val Runnable runnable = [|generateToWorksheet]
			val thread = new Thread(runnable)
			thread.name = "oddgen Worksheet Generator"
			thread.start
			exit
		} else if (e.getSource == buttonGenerateToClipboard) {
			val Runnable runnable = [|generateToClipboard]
			val thread = new Thread(runnable)
			thread.name = "oddgen Clipboard Generator"
			thread.start
			exit
		}
	}

}
