package org.oddgen.sqldev.model

import javax.swing.JButton
import javax.swing.JTextField
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class DirectoryBrowseButton {
	private JButton button
	private JTextField textField
	private String parameterName
}