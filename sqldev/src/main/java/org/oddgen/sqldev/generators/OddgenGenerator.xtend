/*
 * Copyright 2015-2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List

/**
 * Generators need to implement this interface to be shown in the Generators
 * window of oddgen for SQL Developer.
 * 
 * @since v0.2.0
 * @deprecated use {@link OddgenGenerator2} instead.
 */
@Deprecated
interface OddgenGenerator {
	public static String[] BOOLEAN_TRUE = #["true", "yes", "ja", "oui", "si", "1"]	
	public static String[] BOOLEAN_FALSE = #["false", "no", "nein", "non", "no", "0"]
	
	/** 
	 * get name of the generator
	 * called by oddgen after establishing/refreshing a connection
	 * @param conn active connection in the Generators window
	 * @return the name of the generator  
	 */
	def String getName(Connection conn)

	/** 
	 * get description of the generator
	 * called by oddgen after establishing/refreshing a connection
	 * @param conn active connection in the Generators window
	 * @return the description of the generator
	 */
	def String getDescription(Connection conn)

	/** 
	 * get list of valid object types
	 * called by oddgen after opening a generator node
	 * @param conn active connection in the Generators window
	 * @return the list of valid object types for this generator  
	 */
	def List<String> getObjectTypes(Connection conn)

	/** 
	 * get list of valid object names
	 * called by oddgen after opening a object type node
	 * @param conn active connection in the Generators window
	 * @param objectType object type to filter object names
	 * @return the list of object names valid for this objectType
	 */
	def List<String> getObjectNames(Connection conn, String objectType)

	/**
	 * get list of parameters with their default values
	 * called by oddgen while generating code with default parameters and while initializing the Generate dialog
	 * @param conn active connection in the Generators window
	 * @param objectType object type to determine default parameter values
	 * @param objectName object name to determine default parameter values
	 * @return the list of parameters with their default values
	 */
	def LinkedHashMap<String, String> getParams(Connection conn, String objectType, String objectName)

	/** 
	 * get list of values per parameter
	 * called by oddgen while initializing the Generate dialog and after change of a parameter value
	 * @param conn active connection in the Generators window
	 * @param objectType object type to determine list of values
	 * @param objectName object name to determine list of values
	 * @param params parameters with active values to determine list of values
	 * @return the list of values per parameter
	 */
	def HashMap<String, List<String>> getLov(Connection conn, String objectType, String objectName,
		LinkedHashMap<String, String> params)

	/** 
	 * get parameter states (enabled/disabled)
	 * called by oddgen while initializing the Generate dialog and after change of a parameter value
	 * @param conn active connection in the Generators window
	 * @param objectType object type to determine parameter state
	 * @param objectName object name to determine parameter state
	 * @param params parameters with active values to determine parameter state
	 * @return the list states per parameter, might be a subset of the parameters according getParams
	 */
	def HashMap<String, Boolean> getParamStates(Connection conn, String objectType, String objectName,
		LinkedHashMap<String, String> params)

	/** 
	 * generate the result
	 * called by oddgen to generate code
	 * @param conn active connection in the Generators window
	 * @param objectType object type to generate code for
	 * @param objectName object name to generate code for
	 * @param params parameters to customize the code generation
	 * @return the generated code
	 */
	def String generate(Connection conn, String objectType, String objectName, LinkedHashMap<String, String> params)
}
