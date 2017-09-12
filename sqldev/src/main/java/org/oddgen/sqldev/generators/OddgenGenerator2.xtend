/*
 * Copyright 2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
import org.oddgen.sqldev.generators.model.Node

/**
 * Generators need to implement this interface to be shown in the Generators
 * window of oddgen for SQL Developer.
 * 
 * @since v0.3.0
 */
interface OddgenGenerator2 {
	public static String[] BOOLEAN_TRUE = #["true", "yes", "ja", "oui", "si", "1"]	
	public static String[] BOOLEAN_FALSE = #["false", "no", "nein", "non", "no", "0"]
	
	/**
	 * Checks if the current connection is supported by the generator.
	 * Called by oddgen before populating GUI components.
	 * @param conn active connection in the Generators window
	 * @return true if the generator supports the database vendor and version
	 */
	def boolean isSupported(Connection conn)
	
	/** 
	 * Get the name of the generator.
	 * Called by oddgen after establishing/refreshing a connection.
	 * @param conn active connection in the Generators window
	 * @return the name of the generator  
	 */
	def String getName(Connection conn)

	/** 
	 * Get the description of the generator.
	 * Called by oddgen after establishing/refreshing a connection.
	 * @param conn active connection in the Generators window
	 * @return the description of the generator
	 */
	def String getDescription(Connection conn)
	
	/**
	 * Get the list of folder names. The first entry in the list is the folder 
	 * under 'All Generators', the second one is the subfolder under the 
	 * first one and so on. The generator will be visible in the last folder
	 * of the list.
	 * @param conn active connection in the Generators window
	 * @return the list of folders under 'All Generators'
	 */
	def List<String> getFolders(Connection conn)

	/** 
	 * Get the help of the generator.
	 * Called by oddgen after pressing the help button in the Generator dialog.
	 * @param conn active connection in the Generators window
	 * @return the help of the generator
	 */
	def String getHelp(Connection conn)
	
	/**
	 * Get the list of nodes shown to be shown in the SQL Developer navigator tree.
	 * The implementation decides if nodes are returned eagerly oder lazily.
	 * Called by oddgen after opening a generator node and after opening other
	 * nodes, if no children have been fetched for this node before and if this 
	 * node is not a leaf.
	 * @param conn active connection in the Generators window
	 * @param parentNodeId root node to get children for
	 * @return a list of nodes in a hierarchical structure
	 */
	def List<Node> getNodes(Connection conn, String parentNodeId)

	/** 
	 * Get the list of values per parameter.
	 * Called by oddgen while initializing the Generate dialog and after 
	 * change of a parameter value.
	 * @param conn active connection in the Generators window
	 * @param params parameters with active values to determine list of values
	 * @param nodes list of selected nodes to be generated with default parameter values
	 * @return the list of values per parameter
	 */
	def HashMap<String, List<String>> getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes)

	/** 
	 * Get the list of parameter states (enabled/disabled).
	 * Called by oddgen while initializing the Generate dialog and after change 
	 * of a parameter value.
	 * @param conn active connection in the Generators window
	 * @param params parameters with active values to determine parameter state
	 * @param nodes list of selected nodes to be generated with default parameter values
	 * @return the list states per parameter, might be a subset of the parameters
	 */
	def HashMap<String, Boolean> getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes)
	
	/**
	 * Generate the prolog.
	 * Called by oddgen once for all selected nodes at the very beginning of the processing.
	 * @param conn active connection in the Generators window
	 * @param nodes list of selected nodes to be generated
	 * @return the generated prolog
	 */
	def String generateProlog(Connection conn, List<Node> nodes)
	
	/**
	 * Generates the separator between generate calls.
	 * Called by oddgen once for all selected nodes, but applied between generator calls.
	 * @param conn active connection in the Generators window
	 * @return the generator separator
	 */
	def String generateSeparator(Connection conn)

	/**
	 * Generate the epilog.
	 * Called by oddgen once for all selected nodes at the very end of the processing.
	 * @param conn active connection in the Generators window
	 * @param nodes list of selected nodes to be generated
	 * @return the generated epilog
	 */
	def String generateEpilog(Connection conn, List<Node> nodes)

	/** 
	 * Generates the result.
	 * Called for every selected and relevant node, including its children.
	 * @param conn active connection in the Generators window
	 * @param node node to be generated
	 * @return the generated code
	 */
	def String generate(Connection conn, Node node)
}
