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

import java.sql.Connection
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashMap
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.dal.ObjectNameDao
import org.oddgen.sqldev.model.DatabaseGeneratorDto
import org.oddgen.sqldev.model.Generator
import org.oddgen.sqldev.model.ObjectType

class DatabaseGenerator implements OddgenGenerator {
	var DatabaseGeneratorDto dbgen

	new(DatabaseGeneratorDto dbgen) {
		this.dbgen = dbgen
	}
	
	def getDto() {
		return dbgen
	}

	override getName(Connection conn) {
		return dbgen.name
	}

	override getDescription(Connection conn) {
		return dbgen.description
	}

	override getObjectTypes(Connection conn) {
		return dbgen.objectTypes
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
		return dbgen.params
	}

	override getLovs(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		if (dbgen.isRefreshable) {
			val dao = new DatabaseGeneratorDao(conn)
			dao.refresh(dbgen, objectType, objectName, params)
		}
		return dbgen.lovs
	}

	override getParamStates(Connection conn, String objectType, String objectName,
		LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		dao.refresh(dbgen, objectType, objectName, params)
		val result = new HashMap<String, Boolean>()
		for (p : dbgen.paramStates.keySet) {
			result.put(p, if (Generator.BOOLEAN_TRUE.findFirst[it == dbgen.paramStates.get(p)] != null) {
				true
			} else {
				false
			})
		}
		return result
	}

	override generate(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params) {
		val dao = new DatabaseGeneratorDao(conn)
		return dao.generate(dbgen, objectType, objectName, params)
	}
}
