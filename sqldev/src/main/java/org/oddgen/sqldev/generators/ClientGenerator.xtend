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
package org.oddgen.sqldev.generators

import com.jcabi.aspects.Loggable
import java.sql.Connection
import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.generators.model.NodeTools

/**
 * Implements the OddgenGenerator2 interface for old generators implementing deprecated OddgenGenerator interface 
 */
@Loggable(LoggableConstants.DEBUG)
class ClientGenerator implements OddgenGenerator2 {
	var OddgenGenerator gen
	val extension NodeTools nodeTools = new NodeTools

	new(OddgenGenerator gen) {
		this.gen = gen
	}

	def getGenerator() {
		return gen
	}

	override getName(Connection conn) {
		return gen.getName(conn)
	}

	override getDescription(Connection conn) {
		return gen.getDescription(conn)
	}

	override getFolders(Connection conn) {
		val folders = new ArrayList<String>
		folders.add("Client Generators")
		return folders
	}

	override getHelp(Connection conn) {
		return '''<p>«getDescription(conn)»</p>'''
	}

	override getNodes(Connection conn, String parentNodeId) {
		val nodes = new ArrayList<Node>
		if (parentNodeId === null || parentNodeId.empty) {
			val objectTypes = gen.getObjectTypes(conn)
			for (objectType : objectTypes) {
				val node = new Node
				node.id = objectType
				node.params = gen.getParams(conn, objectType, null)
				node.leaf = false
				node.generatable = false
				node.multiselectable = false
				nodes.add(node)
			}
		} else {
			val objectNames = gen.getObjectNames(conn, parentNodeId)
			for (objectName : objectNames) {
				val node = new Node
				node.id = '''«parentNodeId».«objectName»'''
				node.parentId = parentNodeId
				node.params = gen.getParams(conn, parentNodeId, objectName)
				node.leaf = true
				node.generatable = true
				node.multiselectable = true
				nodes.add(node)
			}
		}
		return nodes
	}

	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val node = nodes.get(0)
		return gen.getLov(conn, node.toObjectType, node.toObjectName, node.params)
	}

	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val node = nodes.get(0)
		return gen.getParamStates(conn, node.toObjectType, node.toObjectName, node.params)
	}

	override generateProlog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generateSeparator(Connection conn) {
		return "\n"
	}

	override generateEpilog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generate(Connection conn, Node node) {
		return gen.generate(conn, node.toObjectType, node.toObjectName, node.params)
	}

}
