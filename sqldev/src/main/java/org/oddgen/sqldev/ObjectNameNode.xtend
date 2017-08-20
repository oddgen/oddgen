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
import java.net.URL
import oracle.ide.model.DefaultContainer
import org.oddgen.sqldev.generators.model.NodeTools
import org.oddgen.sqldev.model.ObjectName
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class ObjectNameNode extends DefaultContainer {
	var ObjectName objectName
	var String displayName
	val extension NodeTools nodeTools = new NodeTools

	new(URL url, ObjectName objectName) {
		super(url)
		this.objectName = objectName
		displayName = objectName.node.displayName
	}

	override getIcon() {
		if (objectName.objectType.node.name.startsWith("TABLE") || objectName.objectType.node.name == "CLUSTER") {
			return OddgenResources.getIcon("TABLE_ICON")
		} else if (objectName.objectType.node.name == "VIEW") {
			return OddgenResources.getIcon("VIEW_ICON")
		} else if (objectName.objectType.node.name.startsWith("INDEX")) {
			return OddgenResources.getIcon("INDEX_ICON")
		} else if (objectName.objectType.node.name == "SYNONYM") {
			return OddgenResources.getIcon("SYNONYM_ICON")
		} else if (objectName.objectType.node.name == "SEQUENCE") {
			return OddgenResources.getIcon("SEQUENCE_ICON")
		} else if (objectName.objectType.node.name == "PROCEDURE") {
			return OddgenResources.getIcon("PROCEDURE_ICON")
		} else if (objectName.objectType.node.name == "FUNCTION") {
			return OddgenResources.getIcon("FUNCTION_ICON")
		} else if (objectName.objectType.node.name.startsWith("PACKAGE")) {
			return OddgenResources.getIcon("PACKAGE_ICON")
		} else if (objectName.objectType.node.name == "TRIGGER") {
			return OddgenResources.getIcon("TRIGGER_ICON")
		} else if (objectName.objectType.node.name.startsWith("TYPE")) {
			return OddgenResources.getIcon("TYPE_ICON")
		} else if (objectName.objectType.node.name == "LIBRARY") {
			return OddgenResources.getIcon("LIBRARY_ICON")
		} else if (objectName.objectType.node.name == "DIRECTORY") {
			return OddgenResources.getIcon("DIRECTORY_ICON")
		} else if (objectName.objectType.node.name == "QUEUE") {
			return OddgenResources.getIcon("QUEUE_ICON")
		} else if (objectName.objectType.node.name.startsWith("JAVA")) {
			return OddgenResources.getIcon("JAVA_ICON")
		} else if (objectName.objectType.node.name == "MATERIALIZED VIEW" ||
			objectName.objectType.node.name == "REWRITE EQUIVALENCE") {
			return OddgenResources.getIcon("MATERIALIZED_VIEW_ICON")
		} else if (objectName.objectType.node.name == "EDITION") {
			return OddgenResources.getIcon("EDITION_ICON")
		} else if (objectName.objectType.node.name.startsWith("JOB")) {
			return OddgenResources.getIcon("JOB_ICON")
		} else if (objectName.objectType.node.name == "DATABASE LINK") {
			return OddgenResources.getIcon("DBLINK_ICON")
		} else if (objectName.objectType.node.name == "CONSUMER GROUP" || objectName.objectType.node.name.contains("CONTEXT") ||
			objectName.objectType.node.name == "DESTINATION" || objectName.objectType.node.name.startsWith("LOB") ||
			objectName.objectType.node.name == "OPERATOR" || objectName.objectType.node.name == "PROGRAM" ||
			objectName.objectType.node.name == "RESOURCE PLAN" || objectName.objectType.node.name.startsWith("RULE") ||
			objectName.objectType.node.name.startsWith("SCHEDULE") || objectName.objectType.node.name == "UNIFIED AUDIT POLICY" ||
			objectName.objectType.node.name == "WINDOW" || objectName.objectType.node.name == "XML SCHEMA" ||
			objectName.objectType.node.name == "DIMENSION" || objectName.objectType.node.name == "SUBSCRIPTION" ||
			objectName.objectType.node.name == "LOCATION" || objectName.objectType.node.name == "CAPTURE" ||
			objectName.objectType.node.name == "APPLY" || objectName.objectType.node.name == "CHAIN" ||
			objectName.objectType.node.name == "FILE GROUP" || objectName.objectType.node.name == "MINING MODEL" ||
			objectName.objectType.node.name == "ASSEMBLY" || objectName.objectType.node.name == "CREDENTIAL" ||
			objectName.objectType.node.name == "CUBE DIMENSION" || objectName.objectType.node.name == "CUBE" ||
			objectName.objectType.node.name == "MEASURE FOLDER" || objectName.objectType.node.name == "CUBE BUILD PROCESS" ||
			objectName.objectType.node.name == "FILE WATCHER" || objectName.objectType.node.name == "SQL TRANSLATION PROFILE") {
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
