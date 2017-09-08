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
package org.oddgen.sqldev.plugin.templates

import java.io.File
import java.sql.Connection
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import oracle.ide.config.Preferences
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.model.PreferenceModel
import org.oddgen.sqldev.resources.OddgenResources
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class NewPlsqlGenerator implements OddgenGenerator2 {

	public static val PACKAGE_NAME = "Package name"
	public static val GENERATE_ODDGEN_TYPES = "Generate oddgen_types?"
	public static val GENERATE_FILES = "Generate files?"
	public static val OUTPUT_DIR = "Output directory"

	public static val YES = "Yes"
	public static val NO = "No"
	public static val ONLY_IF_MISSING = "Only if missing"
	public static val ALWAYS = "Always"
	public static val NEVER = "Never"

	var JdbcTemplate jdbcTemplate
	var Node node
	val extension TemplateTools templateTools = new TemplateTools
	val preferences = PreferenceModel.getInstance(Preferences.getPreferences());
	
	def private hasOddgenTypes() {
		val stmt = '''
			DECLARE
			   r_node oddgen_types.r_node_type;
			BEGIN
			   NULL;
			END;
		'''
		try {
			jdbcTemplate.execute(stmt)
			return true
		} catch (Exception e) {
			return false
		}
	}

	def private oddgenTypesTemplate() {
		return OddgenResources.getTextFile("ODDGEN_TYPES_PKS_FILE")
	}
	
	def private packageTemplate() {
		val template = OddgenResources.getTextFile("ODDGEN_INTERFACE_PKS_FILE")
		return template.replace("oddgen_interface", node.params.get(PACKAGE_NAME).toLowerCase)
	}
	
	def private packageBodyTemplate() '''
		CREATE OR REPLACE PACKAGE BODY «node.params.get(PACKAGE_NAME).toLowerCase» IS
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
		
		   --
		   -- parameter names used also as labels in the GUI
		   --
		   co_p1 CONSTANT oddgen_types.key_type := 'P1?';
		   co_p2 CONSTANT oddgen_types.key_type := 'P2';
		   co_p3 CONSTANT oddgen_types.key_type := 'P3';
		
		   --
		   -- get_name
		   --
		   FUNCTION get_name RETURN VARCHAR2 IS
		   BEGIN
		      RETURN '«node.params.get(PACKAGE_NAME).toFirstUpper»';
		   END get_name;
		
		   --
		   -- get_description
		   --
		   FUNCTION get_description RETURN VARCHAR2 IS
		   BEGIN
		      RETURN '«node.params.get(PACKAGE_NAME).toFirstUpper»';
		   END get_description;
		
		   --
		   -- get_folders
		   --
		   FUNCTION get_folders RETURN oddgen_types.t_value_type IS
		   BEGIN
		      RETURN NEW oddgen_types.t_value_type(«FOR f :preferences.defaultDatabaseServerGeneratorFolder.split(",").filter[!it.empty] SEPARATOR ", "»'«f.trim»'«ENDFOR»);
		   END get_folders;
		
		   --
		   -- get_help
		   --
		   FUNCTION get_help RETURN CLOB IS
		   BEGIN
		      RETURN '<p>Not yet available.</p>';
		   END get_help;
		
		   --
		   -- get_nodes
		   --
		   FUNCTION get_nodes(
		      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
		   ) RETURN oddgen_types.t_node_type IS
		      t_nodes  oddgen_types.t_node_type;
		      --
		      PROCEDURE add_node (
		         in_id          IN oddgen_types.key_type,
		         in_parent_id   IN oddgen_types.key_type,
		         in_leaf        IN BOOLEAN
		      ) IS
		         l_node oddgen_types.r_node_type;
		      BEGIN
		         l_node.id              := in_id;
		         l_node.parent_id       := in_parent_id;
		         l_node.leaf            := in_leaf;
		         l_node.generatable     := TRUE;
		         l_node.multiselectable := TRUE;
		         l_node.params(co_p1)   := 'Yes';
		         l_node.params(co_p2)   := 'Value 1';
		         l_node.params(co_p3)   := 'Some value';
		         t_nodes.extend;
		         t_nodes(t_nodes.count) := l_node;         
		      END add_node;
		   BEGIN
		      t_nodes  := oddgen_types.t_node_type();
		      IF in_parent_node_id IS NULL THEN
		         -- object types
		         add_node(
		            in_id        => 'TABLE',
		            in_parent_id => NULL,
		            in_leaf      => FALSE
		         );
		         add_node(
		            in_id        => 'VIEW',
		            in_parent_id => NULL,
		            in_leaf      => FALSE
		         );
		      ELSE
		         -- object names
		         <<nodes>>
		         FOR r IN (
		            SELECT object_name
		              FROM user_objects
		             WHERE object_type = in_parent_node_id
		               AND generated = 'N'
		         ) LOOP
		            add_node(
		               in_id        => in_parent_node_id || '.' || r.object_name,
		               in_parent_id => in_parent_node_id,
		               in_leaf      => TRUE
		            );
		         END LOOP nodes;
		      END IF;
		      RETURN t_nodes;
		   END get_nodes;
		
		   --
		   -- get_ordered_params
		   --
		   FUNCTION get_ordered_params RETURN oddgen_types.t_value_type IS
		   BEGIN
		      RETURN NEW oddgen_types.t_value_type(co_p1, co_p2, co_p3);
		   END get_ordered_params;
		
		   --
		   -- get_lov
		   --
		   FUNCTION get_lov(
		      in_params IN oddgen_types.t_param_type,
		      in_nodes  IN oddgen_types.t_node_type
		   ) RETURN oddgen_types.t_lov_type IS
		      l_lov oddgen_types.t_lov_type;
		   BEGIN
		      l_lov(co_p1) := NEW oddgen_types.t_value_type('Yes', 'No');
		      l_lov(co_p2) := NEW oddgen_types.t_value_type('Value 1', 'Value 2', 'Value 3');
		      RETURN l_lov;
		   END get_lov;
		
		   --
		   -- get_param_states
		   --
		   FUNCTION get_param_states(
		      in_params IN oddgen_types.t_param_type,
		      in_nodes  IN oddgen_types.t_node_type
		   ) RETURN oddgen_types.t_param_type IS
		      l_param_states oddgen_types.t_param_type;
		   BEGIN
		      IF in_params(co_p1) = 'Yes' THEN
		         l_param_states(co_p2) := '1'; -- enable
		      ELSE
		         l_param_states(co_p2) := '0'; -- disable
		      END IF;
		      RETURN l_param_states;
		   END get_param_states;
		
		   --
		   -- generate_prolog
		   --
		   FUNCTION generate_prolog(
		      in_nodes IN oddgen_types.t_node_type
		   ) RETURN CLOB IS
		   BEGIN
		      RETURN NULL;
		   END generate_prolog;
		
		   --
		   -- generate_separator
		   --
		   FUNCTION generate_separator RETURN VARCHAR2 IS
		   BEGIN
		      RETURN NULL;
		   END generate_separator;
		
		   --
		   -- generate_epilog
		   --
		   FUNCTION generate_epilog(
		      in_nodes IN oddgen_types.t_node_type
		   ) RETURN CLOB IS
		   BEGIN
		      RETURN NULL;
		   END generate_epilog;
		
		   --
		   -- generate
		   --
		   FUNCTION generate(
		      in_node IN oddgen_types.r_node_type
		   ) RETURN CLOB IS
		   BEGIN
		      RETURN '-- ' || in_node.id   || ' ' || 
		             in_node.params(co_p1) || ' ' || 
		             in_node.params(co_p2) || ' ' ||
		             in_node.params(co_p3);
		   END generate;
		
		END «node.params.get(PACKAGE_NAME).toLowerCase»;
		/
	'''
	
	def private installTemplate() '''
		«IF node.params.get(GENERATE_ODDGEN_TYPES) == ALWAYS || node.params.get(GENERATE_ODDGEN_TYPES) == ONLY_IF_MISSING && !hasOddgenTypes»
			@@oddgen_types.pks
		«ENDIF»
		@@«node.params.get(PACKAGE_NAME).toLowerCase».pks
		@@«node.params.get(PACKAGE_NAME).toLowerCase».pkb
	'''

	override getName(Connection conn) {
		return "PL/SQL generator"
	}

	override getDescription(Connection conn) {
		return "Generate a PL/SQL oddgen plugin"
	}

	override getFolders(Connection conn) {
		return #["Templates"]
	}

	override getHelp(Connection conn) {
		return "<p>not yet available</p>"
	}

	override getNodes(Connection conn, String parentNodeId) {
		val params = new LinkedHashMap<String, String>()
		params.put(PACKAGE_NAME, "new_generator")
		params.put(GENERATE_ODDGEN_TYPES, ONLY_IF_MISSING)
		params.put(GENERATE_FILES, NO)
		params.put(OUTPUT_DIR, '''«System.getProperty("user.home")»«File.separator»oddgen«File.separator»plsql''')
		val node = new Node
		node.id = "PL/SQL template"
		node.params = params
		node.leaf = true
		node.generatable = true
		return #[node]
	}

	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val lov = new HashMap<String, List<String>>
		lov.put(GENERATE_ODDGEN_TYPES, #[ONLY_IF_MISSING, ALWAYS, NEVER])
		lov.put(GENERATE_FILES, #[YES, NO])
		return lov
	}

	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val paramStates = new HashMap<String, Boolean>
		paramStates.put(OUTPUT_DIR, params.get(GENERATE_FILES) == YES)
		return paramStates
	}

	override generateProlog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generateSeparator(Connection conn) {
		return ""
	}

	override generateEpilog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generate(Connection conn, Node node) {
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		this.node = node
		var String result
		if (node.params.get(GENERATE_FILES) == YES) {
			val outputDir = node.params.get(OUTPUT_DIR)
			val packageName = node.params.get(PACKAGE_NAME)
			result = '''
				«mkdirs(outputDir)»
				«writeToFile('''«outputDir»«File.separator»install.sql''',  installTemplate.toString)»
				«IF node.params.get(GENERATE_ODDGEN_TYPES) == ALWAYS || node.params.get(GENERATE_ODDGEN_TYPES) == ONLY_IF_MISSING && !hasOddgenTypes»
					«writeToFile('''«outputDir»«File.separator»oddgen_types.pks''',  oddgenTypesTemplate)»
				«ENDIF»
				«writeToFile('''«outputDir»«File.separator»«packageName».pks''',  packageTemplate)»
				«writeToFile('''«outputDir»«File.separator»«packageName».pkb''',  packageBodyTemplate.toString)»
				
				To install the PL/SQL generator:

				@«outputDir»«File.separator»install.sql
			'''
		} else {
			result = '''
				«IF node.params.get(GENERATE_ODDGEN_TYPES) == ALWAYS || node.params.get(GENERATE_ODDGEN_TYPES) == ONLY_IF_MISSING && !hasOddgenTypes»
					«oddgenTypesTemplate»

				«ENDIF»
				«packageTemplate»

				«packageBodyTemplate»
			'''
		}
		return result
	}

}
