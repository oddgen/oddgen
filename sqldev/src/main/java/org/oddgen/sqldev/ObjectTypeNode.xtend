package org.oddgen.sqldev

import java.net.URL
import oracle.ide.model.DefaultContainer
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import org.oddgen.sqldev.dal.ObjectNameDao
import org.oddgen.sqldev.model.DatabaseGenerator
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
	
	def openBackground() {
		if (objectType.generator instanceof DatabaseGenerator) {
			val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
			if (conn != null) {
				val dao = new ObjectNameDao(conn)
				val objectNames = dao.findObjectNames(objectType)
				for (objectName : objectNames) {
					val node = new ObjectNameNode(URLFactory.newURL(this.URL, objectName.name), objectName)
					this.add(node)
				}
			}
			UpdateMessage.fireStructureChanged(this)
			this.markDirty(false)
		}
	}

	override openImpl() {
		val Runnable runnable = [|openBackground]
		val thread = new Thread(runnable)
		thread.name = "oddgen Open Object Type"
		thread.start
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