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
		if (objectName.objectType.name.startsWith("TABLE") || objectName.objectType.name == "CLUSTER") {
			return OddgenResources.getIcon("TABLE_ICON")
		} else if (objectName.objectType.name == "VIEW") {
			return OddgenResources.getIcon("VIEW_ICON")
		} else if (objectName.objectType.name.startsWith("INDEX")) {
			return OddgenResources.getIcon("INDEX_ICON")
		} else if (objectName.objectType.name == "SYNONYM") {
			return OddgenResources.getIcon("SYNONYM_ICON")
		} else if (objectName.objectType.name == "SEQUENCE") {
			return OddgenResources.getIcon("SEQUENCE_ICON")
		} else if (objectName.objectType.name == "PROCEDURE") {
			return OddgenResources.getIcon("PROCEDURE_ICON")
		} else if (objectName.objectType.name == "FUNCTION") {
			return OddgenResources.getIcon("FUNCTION_ICON")
		} else if (objectName.objectType.name.startsWith("PACKAGE")) {
			return OddgenResources.getIcon("PACKAGE_ICON")
		} else if (objectName.objectType.name == "TRIGGER") {
			return OddgenResources.getIcon("TRIGGER_ICON")
		} else if (objectName.objectType.name.startsWith("TYPE")) {
			return OddgenResources.getIcon("TYPE_ICON")
		} else if (objectName.objectType.name == "LIBRARY") {
			return OddgenResources.getIcon("LIBRARY_ICON")
		} else if (objectName.objectType.name == "DIRECTORY") {
			return OddgenResources.getIcon("DIRECTORY_ICON")
		} else if (objectName.objectType.name == "QUEUE") {
			return OddgenResources.getIcon("QUEUE_ICON")
		} else if (objectName.objectType.name.startsWith("JAVA")) {
			return OddgenResources.getIcon("JAVA_ICON")
		} else if (objectName.objectType.name == "MATERIALIZED VIEW" ||
			objectName.objectType.name == "REWRITE EQUIVALENCE") {
			return OddgenResources.getIcon("MATERIALIZED_VIEW_ICON")
		} else if (objectName.objectType.name == "EDITION") {
			return OddgenResources.getIcon("EDITION_ICON")
		} else if (objectName.objectType.name.startsWith("JOB")) {
			return OddgenResources.getIcon("JOB_ICON")
		} else if (objectName.objectType.name == "DATABASE LINK") {
			return OddgenResources.getIcon("DBLINK_ICON")
		} else if (objectName.objectType.name == "CONSUMER GROUP" || objectName.objectType.name.contains("CONTEXT") ||
			objectName.objectType.name == "DESTINATION" || objectName.objectType.name.startsWith("LOB") ||
			objectName.objectType.name == "OPERATOR" || objectName.objectType.name == "PROGRAM" ||
			objectName.objectType.name == "RESOURCE PLAN" || objectName.objectType.name.startsWith("RULE") ||
			objectName.objectType.name.startsWith("SCHEDULE") || objectName.objectType.name == "UNIFIED AUDIT POLICY" ||
			objectName.objectType.name == "WINDOW" || objectName.objectType.name == "XML SCHEMA" ||
			objectName.objectType.name == "DIMENSION" || objectName.objectType.name == "SUBSCRIPTION" ||
			objectName.objectType.name == "LOCATION" || objectName.objectType.name == "CAPTURE" ||
			objectName.objectType.name == "APPLY" || objectName.objectType.name == "CHAIN" ||
			objectName.objectType.name == "FILE GROUP" || objectName.objectType.name == "MINING MODEL" ||
			objectName.objectType.name == "ASSEMBLY" || objectName.objectType.name == "CREDENTIAL" ||
			objectName.objectType.name == "CUBE DIMENSION" || objectName.objectType.name == "CUBE" ||
			objectName.objectType.name == "MEASURE FOLDER" || objectName.objectType.name == "CUBE BUILD PROCESS" ||
			objectName.objectType.name == "FILE WATCHER" || objectName.objectType.name == "SQL TRANSLATION PROFILE") {
			return OddgenResources.getIcon("OBJECT_ICON")
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
