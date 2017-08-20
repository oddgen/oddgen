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
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import org.oddgen.sqldev.generators.model.NodeTools
import org.oddgen.sqldev.model.ObjectName
import org.oddgen.sqldev.model.ObjectType
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class ObjectTypeNode extends DefaultContainer {
	val ObjectType objectType
	var String displayName
	val extension NodeTools nodeTools = new NodeTools

	new(URL url, ObjectType objectType) {
		super(url)
		this.objectType = objectType
		displayName = objectType.node.displayName
		if (displayName == "Table") {
			displayName = OddgenResources.getString("NODE_TABLE_DISPLAY_NAME")
		} else if (displayName == "Table partition") {
			displayName = OddgenResources.getString("NODE_TABLE_PARTITION_DISPLAY_NAME")
		} else if (displayName == "Table subpartition") {
			displayName = OddgenResources.getString("NODE_TABLE_SUBPARTITION_DISPLAY_NAME")
		} else if (displayName == "Cluster") {
			displayName = OddgenResources.getString("NODE_CLUSTER_DISPLAY_NAME")
		} else if (displayName == "View") {
			displayName = OddgenResources.getString("NODE_VIEW_DISPLAY_NAME")
		} else if (displayName == "Index") {
			displayName = OddgenResources.getString("NODE_INDEX_DISPLAY_NAME")
		} else if (displayName == "Indextype") {
			displayName = OddgenResources.getString("NODE_INDEXTYPE_DISPLAY_NAME")
		} else if (displayName == "Index partition") {
			displayName = OddgenResources.getString("NODE_INDEX_PARTITION_DISPLAY_NAME")
		} else if (displayName == "Index subpartition") {
			displayName = OddgenResources.getString("NODE_INDEX_SUBPARTITION_DISPLAY_NAME")
		} else if (displayName == "Synonym") {
			displayName = OddgenResources.getString("NODE_SYNONYM_DISPLAY_NAME")
		} else if (displayName == "Sequence") {
			displayName = OddgenResources.getString("NODE_SEQUENCE_DISPLAY_NAME")
		} else if (displayName == "Procedure") {
			displayName = OddgenResources.getString("NODE_PROCEDURE_DISPLAY_NAME")
		} else if (displayName == "Function") {
			displayName = OddgenResources.getString("NODE_FUNCTION_DISPLAY_NAME")
		} else if (displayName == "Package") {
			displayName = OddgenResources.getString("NODE_PACKAGE_DISPLAY_NAME")
		} else if (displayName == "Package body") {
			displayName = OddgenResources.getString("NODE_PACKAGE_BODY_DISPLAY_NAME")
		} else if (displayName == "Trigger") {
			displayName = OddgenResources.getString("NODE_TRIGGER_DISPLAY_NAME")
		} else if (displayName == "Type") {
			displayName = OddgenResources.getString("NODE_TYPE_DISPLAY_NAME")
		} else if (displayName == "Type body") {
			displayName = OddgenResources.getString("NODE_TYPE_BODY_DISPLAY_NAME")
		} else if (displayName == "Library") {
			displayName = OddgenResources.getString("NODE_LIBRARY_DISPLAY_NAME")
		} else if (displayName == "Directory") {
			displayName = OddgenResources.getString("NODE_DIRECTORY_DISPLAY_NAME")
		} else if (displayName == "Queue") {
			displayName = OddgenResources.getString("NODE_QUEUE_DISPLAY_NAME")
		} else if (displayName == "Java source") {
			displayName = OddgenResources.getString("NODE_JAVA_SOURCE_DISPLAY_NAME")
		} else if (displayName == "Java class") {
			displayName = OddgenResources.getString("NODE_JAVA_CLASS_DISPLAY_NAME")
		} else if (displayName == "Java resource") {
			displayName = OddgenResources.getString("NODE_JAVA_RESOURCE_DISPLAY_NAME")
		} else if (displayName == "Java data") {
			displayName = OddgenResources.getString("NODE_JAVA_DATA_DISPLAY_NAME")
		} else if (displayName == "Materialized view") {
			displayName = OddgenResources.getString("NODE_MATERIALIZED_VIEW_DISPLAY_NAME")
		} else if (displayName == "Rewrite equivalence") {
			displayName = OddgenResources.getString("NODE_REWRITE_EQUIVALENCE_DISPLAY_NAME")
		} else if (displayName == "Edition") {
			displayName = OddgenResources.getString("NODE_EDITION_DISPLAY_NAME")
		} else if (displayName == "Job") {
			displayName = OddgenResources.getString("NODE_JOB_DISPLAY_NAME")
		} else if (displayName == "Job class") {
			displayName = OddgenResources.getString("NODE_JOB_CLASS_DISPLAY_NAME")
		} else if (displayName == "Database link") {
			displayName = OddgenResources.getString("NODE_DATABASE_LINK_DISPLAY_NAME")
		} else if (displayName == "Consumer group") {
			displayName = OddgenResources.getString("NODE_CONSUMER_GROUP_DISPLAY_NAME")
		} else if (displayName == "Subscription") {
			displayName = OddgenResources.getString("NODE_SUBSCRIPTION_DISPLAY_NAME")
		} else if (displayName == "Location") {
			displayName = OddgenResources.getString("NODE_LOCATION_DISPLAY_NAME")
		} else if (displayName == "Capture") {
			displayName = OddgenResources.getString("NODE_CAPTURE_DISPLAY_NAME")
		} else if (displayName == "Apply") {
			displayName = OddgenResources.getString("NODE_APPLY_DISPLAY_NAME")
		} else if (displayName == "Dimension") {
			displayName = OddgenResources.getString("NODE_DIMENSION_DISPLAY_NAME")
		} else if (displayName == "Context") {
			displayName = OddgenResources.getString("NODE_CONTEXT_DISPLAY_NAME")
		} else if (displayName == "Evaluation context") {
			displayName = OddgenResources.getString("NODE_EVALUATION_CONTEXT_DISPLAY_NAME")
		} else if (displayName == "Destination") {
			displayName = OddgenResources.getString("NODE_DESTINATION_DISPLAY_NAME")
		} else if (displayName == "Lob") {
			displayName = OddgenResources.getString("NODE_LOB_DISPLAY_NAME")
		} else if (displayName == "Lob partition") {
			displayName = OddgenResources.getString("NODE_LOB_PARTITION_DISPLAY_NAME")
		} else if (displayName == "Lob subpartition") {
			displayName = OddgenResources.getString("NODE_LOB_SUBPARTITION_DISPLAY_NAME")
		} else if (displayName == "Operator") {
			displayName = OddgenResources.getString("NODE_OPERATOR_DISPLAY_NAME")
		} else if (displayName == "Program") {
			displayName = OddgenResources.getString("NODE_PROGRAM_DISPLAY_NAME")
		} else if (displayName == "Resource plan") {
			displayName = OddgenResources.getString("NODE_RESOURCE_PLAN_DISPLAY_NAME")
		} else if (displayName == "Rule") {
			displayName = OddgenResources.getString("NODE_RULE_DISPLAY_NAME")
		} else if (displayName == "Rule set") {
			displayName = OddgenResources.getString("NODE_RULE_SET_DISPLAY_NAME")
		} else if (displayName == "Schedule") {
			displayName = OddgenResources.getString("NODE_SCHEDULE_DISPLAY_NAME")
		} else if (displayName == "Chain") {
			displayName = OddgenResources.getString("NODE_CHAIN_DISPLAY_NAME")
		} else if (displayName == "File group") {
			displayName = OddgenResources.getString("NODE_FILE_GROUP_DISPLAY_NAME")
		} else if (displayName == "Mining model") {
			displayName = OddgenResources.getString("NODE_MINING_MODEL_DISPLAY_NAME")
		} else if (displayName == "Assembly") {
			displayName = OddgenResources.getString("NODE_ASSEMBLY_DISPLAY_NAME")
		} else if (displayName == "Credential") {
			displayName = OddgenResources.getString("NODE_CREDENTIAL_DISPLAY_NAME")
		} else if (displayName == "Cube dimension") {
			displayName = OddgenResources.getString("NODE_CUBE_DIMENSION_DISPLAY_NAME")
		} else if (displayName == "Cube") {
			displayName = OddgenResources.getString("NODE_CUBE_DISPLAY_NAME")
		} else if (displayName == "Measure folder") {
			displayName = OddgenResources.getString("NODE_MEASURE_FOLDER_DISPLAY_NAME")
		} else if (displayName == "Cube build process") {
			displayName = OddgenResources.getString("NODE_CUBE_BUILD_PROCESS_DISPLAY_NAME")
		} else if (displayName == "File watcher") {
			displayName = OddgenResources.getString("NODE_FILE_WATCHER_DISPLAY_NAME")
		} else if (displayName == "Sql translation profile") {
			displayName = OddgenResources.getString("NODE_SQL_TRANSLATION_PROFILE_DISPLAY_NAME")
		} else if (displayName == "Scheduler group") {
			displayName = OddgenResources.getString("NODE_SCHEDULER_GROUP_DISPLAY_NAME")
		} else if (displayName == "Unified audit policy") {
			displayName = OddgenResources.getString("NODE_UNIFIED_AUDIT_POLICY_DISPLAY_NAME")
		} else if (displayName == "Window") {
			displayName = OddgenResources.getString("NODE_WINDOW_DISPLAY_NAME")
		} else if (displayName == "Xml schema") {
			displayName = OddgenResources.getString("NODE_XML_SCHEMA_DISPLAY_NAME")
		}
	}

	override getIcon() {
		if (objectType.node.name.startsWith("TABLE") || objectType.node.name == "CLUSTER") {
			return OddgenResources.getIcon("TABLE_FOLDER_ICON")
		} else if (objectType.node.name == "VIEW") {
			return OddgenResources.getIcon("VIEW_FOLDER_ICON")
		} else if (objectType.node.name.startsWith("INDEX")) {
			return OddgenResources.getIcon("INDEX_FOLDER_ICON")
		} else if (objectType.node.name == "SYNONYM") {
			return OddgenResources.getIcon("SYNONYM_FOLDER_ICON")
		} else if (objectType.node.name == "SEQUENCE") {
			return OddgenResources.getIcon("SEQUENCE_FOLDER_ICON")
		} else if (objectType.node.name == "PROCEDURE") {
			return OddgenResources.getIcon("PROCEDURE_FOLDER_ICON")
		} else if (objectType.node.name == "FUNCTION") {
			return OddgenResources.getIcon("FUNCTION_FOLDER_ICON")
		} else if (objectType.node.name.startsWith("PACKAGE")) {
			return OddgenResources.getIcon("PACKAGE_FOLDER_ICON")
		} else if (objectType.node.name == "TRIGGER") {
			return OddgenResources.getIcon("TRIGGER_FOLDER_ICON")
		} else if (objectType.node.name.startsWith("TYPE")) {
			return OddgenResources.getIcon("TYPE_FOLDER_ICON")
		} else if (objectType.node.name == "LIBRARY") {
			return OddgenResources.getIcon("LIBRARY_FOLDER_ICON")
		} else if (objectType.node.name == "DIRECTORY") {
			return OddgenResources.getIcon("DIRECTORY_FOLDER_ICON")
		} else if (objectType.node.name == "QUEUE") {
			return OddgenResources.getIcon("QUEUE_FOLDER_ICON")
		} else if (objectType.node.name.startsWith("JAVA")) {
			return OddgenResources.getIcon("JAVA_FOLDER_ICON")
		} else if (objectType.node.name == "MATERIALIZED VIEW" || objectType.node.name == "REWRITE EQUIVALENCE") {
			return OddgenResources.getIcon("MATERIALIZED_VIEW_FOLDER_ICON")
		} else if (objectType.node.name == "EDITION") {
			return OddgenResources.getIcon("EDITION_FOLDER_ICON")
		} else if (objectType.node.name.startsWith("JOB")) {
			return OddgenResources.getIcon("JOB_FOLDER_ICON")
		} else if (objectType.node.name == "DATABASE LINK") {
			return OddgenResources.getIcon("DBLINK_FOLDER_ICON")
		} else if (objectType.node.name == "CONSUMER GROUP" || objectType.node.name.contains("CONTEXT") ||
			objectType.node.name == "DESTINATION" || objectType.node.name.startsWith("LOB") || objectType.node.name == "OPERATOR" ||
			objectType.node.name == "PROGRAM" || objectType.node.name == "RESOURCE PLAN" || objectType.node.name.startsWith("RULE") ||
			objectType.node.name.startsWith("SCHEDULE") || objectType.node.name == "UNIFIED AUDIT POLICY" ||
			objectType.node.name == "WINDOW" || objectType.node.name == "XML SCHEMA" || objectType.node.name == "DIMENSION" ||
			objectType.node.name == "SUBSCRIPTION" || objectType.node.name == "LOCATION" || objectType.node.name == "CAPTURE" ||
			objectType.node.name == "APPLY" || objectType.node.name == "CHAIN" || objectType.node.name == "FILE GROUP" ||
			objectType.node.name == "MINING MODEL" || objectType.node.name == "ASSEMBLY" || objectType.node.name == "CREDENTIAL" ||
			objectType.node.name == "CUBE DIMENSION" || objectType.node.name == "CUBE" || objectType.node.name == "MEASURE FOLDER" ||
			objectType.node.name == "CUBE BUILD PROCESS" || objectType.node.name == "FILE WATCHER" ||
			objectType.node.name == "SQL TRANSLATION PROFILE") {
				return OddgenResources.getIcon("OBJECT_FOLDER_ICON")
			} else {
				return OddgenResources.getIcon("UNKNOWN_FOLDER_ICON")
			}
		}

		def openBackground() {
			val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
			if (conn !== null) {
				for (node : objectType.generator.getNodes(conn, objectType.node.id)) {
					val objectName = new ObjectName()
					objectName.objectType = objectType
					objectName.node = node
					val navigatorNode = new ObjectNameNode(URLFactory.newURL(this.URL, objectName.node.id), objectName)
					this.add(navigatorNode)
				}
			}
			UpdateMessage.fireStructureChanged(this)
			this.markDirty(false)
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
	