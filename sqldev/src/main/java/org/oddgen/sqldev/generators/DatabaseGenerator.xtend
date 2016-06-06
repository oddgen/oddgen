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
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.LoggableConstants
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.dal.ObjectNameDao
import org.oddgen.sqldev.model.DatabaseGeneratorMetaData
import org.oddgen.sqldev.model.ObjectType

@Loggable(LoggableConstants.DEBUG)
class DatabaseGenerator implements OddgenGenerator {
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

	override getObjectTypes(Connection conn) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getObjectTypes(metaData)
	}

	override getObjectNames(Connection conn, String objectType) {
		val dao = new ObjectNameDao(conn)
		val type = new ObjectType()
		type.generator = this
		type.name = objectType
		val result = new ArrayList<String>()
		for (r : dao.findObjectNames(type)) {
			result.add(r.name)
		}
		return result
	}

	override getParams(Connection conn, String objectType, String objectName) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.getParams(metaData)
	}

	override getLovs(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		var HashMap<String, List<String>> lovs
		if (metaData.hasRefreshLovs) {
			lovs = dao.getLovs(metaData, objectType, objectName, params)
		} else {
			lovs = dao.getLovs(metaData)
		}
		return lovs
	}

	override getParamStates(Connection conn, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		val HashMap<String, String> paramStates = if(metaData.hasRefreshParamStates) dao.getParamStates(metaData, objectType,
				objectName, params) else new HashMap<String, String>()
		val result = new HashMap<String, Boolean>()
		for (p : paramStates.keySet) {
			result.put(p, if(OddgenGenerator.BOOLEAN_TRUE.findFirst[it == paramStates.get(p)] != null) true else false)
		}
		return result
	}

	override generate(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.generate(metaData, objectType, objectName, params)
	}
}
