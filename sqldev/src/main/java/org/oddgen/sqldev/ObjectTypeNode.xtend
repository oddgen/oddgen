package org.oddgen.sqldev

import java.net.URL
import oracle.ide.model.DefaultContainer
import org.oddgen.sqldev.model.ObjectType
import org.oddgen.sqldev.resources.OddgenResources

class ObjectTypeNode extends DefaultContainer {
	private ObjectType objectType
	private String displayName

	new(URL url, ObjectType objectType) {
		super(url)
		this.objectType = objectType
		displayName = objectType.name.toLowerCase.toFirstUpper
		if (displayName == "Table") {
			displayName = "Tables"
		} else if (displayName == "View") {
			displayName = "Views"
		}	
	}

	override getIcon() {
		if (displayName.startsWith("Table")) {
			return OddgenResources.getIcon("TABLE_FOLDER_ICON")
		} else if (displayName.startsWith("View")) {
			return OddgenResources.getIcon("VIEW_FOLDER_ICON")
		} else {
			return OddgenResources.getIcon("UNKNOWN_FOLDER_ICON")			
		}
	}

	override getLongLabel() {
		return displayName
	}

	override getShortLabel() {
		return displayName
	}

	override getToolTipText() {
		return displayName
	}
	
}