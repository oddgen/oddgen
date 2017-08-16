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

	new(DatabaseGeneratorMetaData metaData) {
		this.metaData = metaData
	}

	def getMetaData() {
		return metaData
	}

	override getName(Connection conn) {
		return metaData.name
	}

	override getDescription(Connection conn) {
		return metaData.description
	}
	
	override getFolders(Connection conn) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getFolders(metaData);
	}
	
	override getHelp(Connection conn) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getHelp(metaData)
	}
	
	override List<Node> getNodes(Connection conn, String parentNodeId) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getNodes(metaData, parentNodeId)
	}
	
	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		// TODO
		return null
	}
	
	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		// TODO
		return null
	}
	
	override generateProlog(Connection conn, List<Node> nodes) {
		// TODO
		return null
	}
	
	override generateSeparator(Connection conn) {
		// TODO
		return null
	}
	
	override generateEpilog(Connection conn, List<Node> nodes) {
		// TODO
		return null
	}
	
	override generate(Connection conn, LinkedHashMap<String, String> params) {
		// TODO
		return null
	}

	def getObjectTypes(Connection conn) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getObjectTypes(metaData)
	}

	def getObjectNames(Connection conn, String objectType) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getObjectNames(metaData, objectType)
	}

	def getParams(Connection conn, String objectType, String objectName) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getParams(metaData, objectType, objectName)
	}

	def getLov(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getLov(metaData, objectType, objectName, params)
	}

	def getParamStates(Connection conn, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		val HashMap<String, String> paramStates = dao.getParamStates(metaData, objectType, objectName, params);
		val result = new HashMap<String, Boolean>()
		for (p : paramStates.keySet) {
			result.put(p, if(OddgenGenerator2.BOOLEAN_TRUE.findFirst[it == paramStates.get(p)] !== null) true else false)
		}
		return result
	}

	def generate(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.generate(metaData, objectType, objectName, params)
	}
}
