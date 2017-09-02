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
package org.oddgen.sqldev.generators.model

import com.jcabi.aspects.Loggable
import java.util.Arrays
import java.util.List
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class NodeTools {

	def String escapeSingleQuotes(String value) {
		return value.replace("'", "''")
	}
	
	def CharSequence toXml(List<Node> nodes, boolean withParams) '''
		<nodes>
			«FOR node : nodes»
				<node>
					<id>«node.id»</id>
					<parent_id>«node.parentId»</parent_id>
					<name>«node.name»</name>
					<description>«node.description»</description>
					<icon_name>«node.iconName»</icon_name>
					<icon_base64>«node.iconBase64»</icon_base64>
					«IF withParams»
						<params>
							«FOR key : node.params.keySet»
								<key>«key»</key>
								<value>«node.params.get(key)»</value>
							«ENDFOR»
						</params>
					«ENDIF»
					<leaf>«IF node.isLeaf»true«ELSE»false«ENDIF»</leaf>
					<generatable>«IF node.isGeneratable»true«ELSE»false«ENDIF»</generatable>
					<multiselectable>«IF node.isMultiselectable»true«ELSE»false«ENDIF»</multiselectable>
					<relevant>«IF node.isRelevant»true«ELSE»false«ENDIF»</relevant>
				</node>
			«ENDFOR»
		</nodes>
	'''
	
	def CharSequence toPlsql(Node node) '''
		l_node.id              := «IF node.id === null»NULL«ELSE»'«node.id.escapeSingleQuotes»'«ENDIF»;
		l_node.parent_id       := «IF node.parentId === null»NULL«ELSE»'«node.parentId.escapeSingleQuotes»'«ENDIF»;
		l_node.name            := «IF node.name === null»NULL«ELSE»'«node.name.escapeSingleQuotes»'«ENDIF»;
		l_node.description     := «IF node.description === null»NULL«ELSE»'«node.description.escapeSingleQuotes»'«ENDIF»;
		l_node.icon_name       := «IF node.iconName === null»NULL«ELSE»'«node.iconName»'«ENDIF»;
		l_node.icon_base64     := «IF node.iconBase64 === null»NULL«ELSE»'«node.iconBase64»'«ENDIF»;
		«IF node.params !== null»
			«FOR key : node.params.keySet»
				l_node.params('«key.escapeSingleQuotes»') := '«node.params.get(key).escapeSingleQuotes»';
			«ENDFOR»
		«ENDIF»
		l_node.leaf            := «IF node.leaf === null»TRUE«ELSE»«IF node.leaf»TRUE«ELSE»FALSE«ENDIF»«ENDIF»;
		l_node.generatable     := «IF node.generatable === null»l_node.leaf«ELSE»«IF node.generatable»TRUE«ELSE»FALSE«ENDIF»«ENDIF»;
		l_node.multiselectable := «IF node.multiselectable === null»l_node.leaf«ELSE»«IF node.multiselectable»TRUE«ELSE»FALSE«ENDIF»«ENDIF»;
		l_node.relevant        := «IF node.relevant === null»l_node.leaf«ELSE»«IF node.relevant»TRUE«ELSE»FLSE«ENDIF»«ENDIF»;
	'''

	def CharSequence toPlsql(List<Node> nodes) '''
		«IF nodes !== null»
			«FOR node : nodes»
				«node.toPlsql»
				l_nodes.extend;
				l_nodes(l_nodes.count) := l_node;
			«ENDFOR»
		«ENDIF»
	'''

	def String getDotDelimitedEntry(String input, Integer index) {
		var String result = null
		if (input !== null) {
			val entries = Arrays.asList(input.split("\\."))
			if (entries.size > index) {
				result = entries.get(index)
			}
		}
		return result;
	}
	
	def toObjectType(Node node) {
		return getDotDelimitedEntry(node?.id, 0)
	}

	def toObjectType(List<Node> nodes) {
		var String objectType = null
		if (nodes !== null && nodes.size > 0) {
			objectType = nodes.get(0).toObjectType
		}
		return objectType
	}

	def toObjectName(Node node) {
		return getDotDelimitedEntry(node?.id, 1)
	}

	def toObjectName(List<Node> nodes) {
		var String objectName = null
		if (nodes !== null && nodes.size > 0) {
			objectName = nodes.get(0).toObjectName
		}
		return objectName
	}
	
	def getDisplayName(Node node) {
		var String displayName
		if (node.name !== null && !node.name.empty) {
			displayName = node.name
		} else {
			val parts = node.id.split("\\.")
			displayName = parts.get(parts.size-1).toLowerCase.toFirstUpper
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
		return displayName
	}
	
	def getDisplayDescription(Node node) {
		if (node.description !== null) {
			return node.description
		} else {
			return node.displayName
		}
	}	
	
	def isLeaf (Node node) {
		if (node.leaf === null) {
			return false
		} else {
			return node.leaf
		}
	}
	
	def isGeneratable (Node node) {
		if (node.generatable === null) {
			return node.isLeaf
		} else {
			return node.generatable
		}
	}
	
	def isMultiselectable (Node node) {
		if (node.multiselectable === null) {
			return node.isLeaf
		} else {
			return node.multiselectable
		}
	}
	
	def isRelevant (Node node) {
		if (node.relevant === null) {
			return node.isLeaf
		} else {
			return node.relevant
		}
	}

}
