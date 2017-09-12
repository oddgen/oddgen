/*
 * Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.model.DatabaseGeneratorMetaData

@Loggable(LoggableConstants.DEBUG)
class DatabaseGenerator implements OddgenGenerator2 {
	var DatabaseGeneratorMetaData metaData
	var Connection cachedConnection
	var DatabaseGeneratorDao cachedDao
	
	def getDao(Connection conn) {
		if (conn !== cachedConnection) {
			cachedConnection = conn;
			cachedDao = new DatabaseGeneratorDao(conn)
		}
		return cachedDao
	}

	new(DatabaseGeneratorMetaData metaData) {
		this.metaData = metaData
	}

	def getMetaData() {
		return metaData
	}
	
	override isSupported(Connection conn) {
		return true
	}
	
	override getName(Connection conn) {
		return metaData.name
	}

	override getDescription(Connection conn) {
		return metaData.description
	}
	
	override getFolders(Connection conn) {
		return conn.dao.getFolders(metaData);
	}
	
	override getHelp(Connection conn) {
		return conn.dao.getHelp(metaData)
	}
	
	override getNodes(Connection conn, String parentNodeId) {
		return conn.dao.getNodes(metaData, parentNodeId)
	}
	
	def getOrderedParams(Connection conn, Node node) {
		val params = new LinkedHashMap<String, String>
		// init parameter in the requested order (if any)
		for (p : conn.dao.getOrderedParams(metaData, node)) {
			params.put(p, "")
		}
		// update/add parameters from node
		for (key : node.params.keySet) {
			params.put(key, node.params.get(key))
		}
		return params		
	}
	
	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return conn.dao.getLov(metaData, params, nodes)
	}
	
	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val HashMap<String, String> paramStates = conn.dao.getParamStates(metaData, params, nodes);
		val result = new HashMap<String, Boolean>()
		for (p : paramStates.keySet) {
			result.put(p, if(OddgenGenerator2.BOOLEAN_TRUE.findFirst[it == paramStates.get(p)] !== null) true else false)
		}
		return result
	}
	
	override generateProlog(Connection conn, List<Node> nodes) {
		return conn.dao.generateProlog(metaData, nodes)
	}
	
	override generateSeparator(Connection conn) {
		return conn.dao.generateSeparator(metaData)
	}
	
	override generateEpilog(Connection conn, List<Node> nodes) {
		return conn.dao.generateEpilog(metaData, nodes)
	}

	def bulkGenerate(Connection conn, List<Node> nodes) {
		return conn.dao.bulkGenerate(metaData, nodes)
	}
	
	override generate(Connection conn, Node node) {
		return conn.dao.generate(metaData, node)
	}

}
