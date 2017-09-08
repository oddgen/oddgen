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
	 * enabled/disable bulk process (for database server generators only)
	 */
	static final String KEY_BULK_PROCESS = "bulkProcess"
	
	/**
	 * enable/disable client generator examples
	 */
	static final String KEY_SHOW_CLIENT_GENERATOR_EXAMPLES = "showClientGeneratorExamples"
	
	/**
	 * Default folder for client generators
	 */
	static final String KEY_DEFAULT_CLIENT_GENERATORS_FOLDER = "defaultClientGeneratorFolder"
	
	/**
	 * Default folder for database server generators
	 */
	static final String KEY_DEFAULT_DATABASE_SERVER_GENERATORS_FOLDER = "defaultDatabaseServerGeneratorFolder"

	def isBulkProcess() {
		return getHashStructure.getBoolean(org.oddgen.sqldev.model.PreferenceModel.KEY_BULK_PROCESS, true)
	}

	def setBulkProcess(boolean bulkProcess) {
		getHashStructure.putBoolean(org.oddgen.sqldev.model.PreferenceModel.KEY_BULK_PROCESS, bulkProcess)
	}
	
	def isShowClientGeneratorExamples() {
		return getHashStructure.getBoolean(org.oddgen.sqldev.model.PreferenceModel.KEY_SHOW_CLIENT_GENERATOR_EXAMPLES, true)
	}
	
	def setShowClientGeneratorExamples(boolean showClientGeneratorExamples) {
		getHashStructure.putBoolean(org.oddgen.sqldev.model.PreferenceModel.KEY_SHOW_CLIENT_GENERATOR_EXAMPLES, showClientGeneratorExamples)
	}
	
	def getDefaultClientGeneratorFolder() {
		return getHashStructure.getString(org.oddgen.sqldev.model.PreferenceModel.KEY_DEFAULT_CLIENT_GENERATORS_FOLDER, "Client Generators")
	}
	
	def setDefaultClientGeneratorFolder(String folder) {
		getHashStructure.putString(org.oddgen.sqldev.model.PreferenceModel.KEY_DEFAULT_CLIENT_GENERATORS_FOLDER, folder)
	}

	def getDefaultDatabaseServerGeneratorFolder() {
		return getHashStructure.getString(org.oddgen.sqldev.model.PreferenceModel.KEY_DEFAULT_DATABASE_SERVER_GENERATORS_FOLDER, "Database Server Generators")
	}

	def setDefaultDatabaseServerGeneratorFolder(String folder) {
		getHashStructure.putString(org.oddgen.sqldev.model.PreferenceModel.KEY_DEFAULT_DATABASE_SERVER_GENERATORS_FOLDER, folder)
	}

	override toString() {
		new ToStringBuilder(this).addAllFields.toString
	}
}
