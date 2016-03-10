package org.oddgen.sqldev

import java.net.URL
import oracle.ide.model.DefaultContainer
import org.oddgen.sqldev.model.ObjectName
import org.oddgen.sqldev.resources.OddgenResources

class ObjectNameNode extends DefaultContainer {
	private ObjectName objectName
	private String displayName

	new(URL url, ObjectName objectName) {
		super(url)
		this.objectName = objectName
		displayName = objectName.name
	}

	override getIcon() {
		val typeName = objectName.typeName.toLowerCase
		if (typeName.startsWith("table")) {
			return OddgenResources.getIcon("TABLE_ICON")
		} else if (typeName.startsWith("view")) {
			return OddgenResources.getIcon("VIEW_ICON")
		} else {
			return OddgenResources.getIcon("UNKNOWN_ICON")
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
