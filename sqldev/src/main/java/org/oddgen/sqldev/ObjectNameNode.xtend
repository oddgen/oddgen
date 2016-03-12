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
		val typeName = objectName.objectType.name.toLowerCase
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

	override mayHaveChildren() {
		return false
	}
	
	override getData() {
		return objectName
	}

}
