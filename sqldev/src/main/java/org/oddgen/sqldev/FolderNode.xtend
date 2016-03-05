package org.oddgen.sqldev

import java.net.URL
import oracle.ide.model.DefaultContainer
import org.oddgen.sqldev.model.Folder
import org.oddgen.sqldev.resources.OddgenResources

class FolderNode extends DefaultContainer {
	Folder folder;

	new () {}
	
	new (URL url) {
		this(url, null)
	}
	
	new (URL url, Folder folder) {
		super(url)
		this.folder = folder
	}
	
	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_FOLDER_ICON")
	}
	
	override getLongLabel() {
		return folder?.getDescription
	}
	
	override getShortLabel() {
		return folder?.name
	}
	
	override getToolTipText() {
		return folder?.tooltip
	}
	
	def getFolder() {
		return folder;
	}	
}