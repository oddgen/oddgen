/*
 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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

import com.jcabi.log.Logger
import java.sql.Connection
import java.util.HashMap
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.plugin.PluginUtils

class OddgenGeneratorUtils {
	def static getPath(OddgenGenerator2 gen, Connection conn) {
		return '''/«FOR folder : gen.getFolders(conn)»«folder»/«ENDFOR»«gen.getName(conn)»'''
	}
	
	/**
	 * Finds all generators
	 * 
	 * @param conn Connection used to find generators in the database and more
	 * @return list of generators implementing the OddgenGenerator2 interface
	 */
	def static findAll(Connection conn) {
		val result = new  HashMap<String, OddgenGenerator2>
		// 1st priority
		for (gen : PluginUtils.findOddgenGenerators2(PluginUtils.findJars)) {
			val name = gen.class.name
			if (gen.isSupported(conn)) {
				Logger.debug(OddgenGeneratorUtils,'''adding v2 client generator «name»''')
				result.put(name, gen)
			}
		}		
		// 2nd priority (do not add generators with same class name)
		for (gen : PluginUtils.findOddgenGenerators(PluginUtils.findJars)) {
			if (gen.isSupported(conn)) {
				val name = gen.generator.class.name
				if (result.get(name) === null) {
					Logger.debug(OddgenGeneratorUtils,'''adding v1 client generator «name»''')
					result.put(name, gen)
				} else {
					// ok, v2 generator has precedence over v1 generator 
					Logger.info(OddgenGeneratorUtils,'''ignoring v1 client generator «name»''')
				}
			}
		}
		// 3rd priority
		val dao = new DatabaseGeneratorDao(conn)
		for (gen : dao.findAll) {
			if (gen.isSupported(conn)) {
				val name = '''«gen.metaData.generatorOwner».«gen.metaData.generatorName»'''
				if (result.get(name) === null) {
					Logger.debug(OddgenGeneratorUtils,'''adding database generator «name»''')
					result.put(name, gen)
				} else {
					// name is unique in a database instance, hence this should never happen
					Logger.error(OddgenGeneratorUtils,'''ignoring database generator «name»''')
				}
			}
		}
		return result.values
	}
}