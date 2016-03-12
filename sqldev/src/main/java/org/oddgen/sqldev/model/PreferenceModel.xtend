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
package org.oddgen.sqldev.model

import oracle.javatools.data.HashStructure
import oracle.javatools.data.HashStructureAdapter
import oracle.javatools.data.PropertyStorage
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

class PreferenceModel extends HashStructureAdapter {
	static final String DATA_KEY = "oddgen"

	private new(HashStructure hash) {
		super(hash)
	}

	def static getInstance(PropertyStorage prefs) {
		return new PreferenceModel(findOrCreate(prefs, DATA_KEY))
	}

	/** 
	 * enabled/disable automatic discovery of PL/SQL Generations when opening an oddgen node
	 */
	static final String KEY_DISCOVER_PLSQL_GENERATORS = "discoverPlsqlGenerators"

	def isDiscoverPlsqlGenerators() {
		return getHashStructure.getBoolean(KEY_DISCOVER_PLSQL_GENERATORS, true)
	}

	def setDiscoverPlsqlGenerators(boolean discoverPlsqlGenerators) {
		getHashStructure.putBoolean(KEY_DISCOVER_PLSQL_GENERATORS, discoverPlsqlGenerators)
	}

	override toString() {
		new ToStringBuilder(this).addAllFields.toString
	}

}
