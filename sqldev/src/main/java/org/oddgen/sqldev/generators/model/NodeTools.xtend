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

@Loggable(LoggableConstants.DEBUG)
class NodeTools {

	def String escapeSingleQuotes(String value) {
		return value.replace("'", "''")
	}
	
	def CharSequence toPlsql(Node node) '''
		l_node.id              := «IF node.id === null»NULL«ELSE»'«node.id.escapeSingleQuotes»'«ENDIF»;
		l_node.parent_id       := «IF node.parentId === null»NULL«ELSE»'«node.parentId.escapeSingleQuotes»'«ENDIF»;
		l_node.name            := «IF node.name === null»NULL«ELSE»'«node.name.escapeSingleQuotes»'«ENDIF»;
		l_node.description     := «IF node.description === null»NULL«ELSE»'«node.description.escapeSingleQuotes»'«ENDIF»;
		l_node.icon_name       := «IF node.iconName === null»NULL«ELSE»'«node.iconName»'«ENDIF»;
		l_node.icon_base64     := «IF node.iconBase64 === null»NULL«ELSE»'«node.iconBase64»'«ENDIF»;
		«IF node.params === null»
			l_node.params          := NULL;
		«ELSE»
			«IF node.params === null»
				l_node.params          := NULL;
			«ELSE»
				«FOR key : node.params.keySet»
					l_node.params('«key.escapeSingleQuotes»') := '«node.params.get(key)»';
				«ENDFOR»
			«ENDIF»
		«ENDIF»
		l_node.leaf            := «IF node.leaf === null»TRUE«ELSE»«IF node.leaf»TRUE«ELSE»FALSE«ENDIF»«ENDIF»;
		l_node.generatable     := «IF node.generatable === null»TRUE«ELSE»«IF node.generatable»TRUE«ELSE»FALSE«ENDIF»«ENDIF»;
		l_node.multiselectable := «IF node.multiselectable === null»FALSE«ELSE»«IF node.multiselectable»TRUE«ELSE»FALSE«ENDIF»«ENDIF»;
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
		var String ret
		if (node.name !== null) {
			ret = node.name
		} else {
			val parts = node.id.split("\\.")
			ret = parts.get(parts.size-1).toLowerCase.toFirstUpper
		}
		return ret
	}

}
