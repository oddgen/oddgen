CREATE OR REPLACE PACKAGE dropall AUTHID CURRENT_USER IS
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

   /**
   * oddgen PL/SQL database server generator 
   * Implementing the interface version 0.3.0.
   * 
   * Shows objects in the SQL Developer navigator.
   * Generates drop statements.
   *
   * @headcom
   */

   /**
   * Get the name of the generator, used in tree view
   * If this function is not implemented, the package name will be used.
   *
   * @returns name of the generator
   *
   * @since v0.1
   */
   FUNCTION get_name RETURN VARCHAR2;

   /**
   * Get the description of the generator.
   * If this function is not implemented, the owner and the package name will be used.
   *
   * @returns description of the generator
   *
   * @since v0.1
   */
   FUNCTION get_description RETURN VARCHAR2;
   
   /**
   * Get the list of folder names. The first entry in the list is the folder 
   * under 'All Generators', the second one is the subfolder under the 
   * first one and so on. The generator will be visible in the last folder
   * of the list.
   * If this function is not implemented, the default is 
   * oddgen_types.t_value_type('Database Server Generators'). 
   * It is possible to override the default in the oddgen preference dialog.
   *
   * @returns the list of folders under 'All Generators'
   *
   * @since v0.3
   */
   FUNCTION get_folders RETURN oddgen_types.t_value_type;

   /**
   * Get the help of the generator.
   * If this function is not implemented, no help is available.
   *
   * @returns help text as HTML
   *
   * @since v0.3
   */
   FUNCTION get_help RETURN CLOB;

   /**
   * Get the list of nodes shown to be shown in the SQL Developer navigator tree.
   * The implementation decides if nodes are returned eagerly oder lazily.
   * If this function is not implemented nodes for tables and views are returned lazily.
   *
   * @param in_parent_node_id root node to get children for
   * @returns a list of nodes in a hierarchical structure
   *
   * @since v0.3
   */
   FUNCTION get_nodes(
      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
   ) RETURN oddgen_types.t_node_type;

   /**
   * Get the list of parameter names in the order to be displayed in the generate dialog.
   * If this function is not implemented, the parameters are ordered by name.
   * Parameter names returned by this function are taking precedence.
   * Remaining parameters are ordered by name.
   *
   * @returns ordered parameter names
   *
   * @since v0.3
   */
   FUNCTION get_ordered_params RETURN oddgen_types.t_value_type;

   /**
   * Get the list of values per parameter, if such a LOV is applicable.
   * If this function is not implemented, then the parameters cannot be validated in the GUI.
   * This function is called when showing the generate dialog and after updating a parameter.
   *
   * @param in_params parameters with active values to determine parameter state
   * @param in_nodes table of selected nodes to be generated with default parameter values
   * @returns parameters with their list-of-values
   *
   * @since v0.3
   */
   FUNCTION get_lov(
      in_params IN oddgen_types.t_param_type,
      in_nodes  IN oddgen_types.t_node_type
   ) RETURN oddgen_types.t_lov_type;

  /**
   * Get the list of parameter states (enabled/disabled)
   * If this function is not implemented, then the parameters are enabled, if more than one value is valid.
   * This function is called when showing the generate dialog and after updating a parameter.
   *
   * @param in_params parameters with active values to determine parameter state
   * @param in_nodes table of selected nodes to be generated with default parameter values
   * @returns parameters with their editable state ("0"=disabled, "1"=enabled)
   *
   * @since v0.3
   */
   FUNCTION get_param_states(
      in_params IN oddgen_types.t_param_type,
      in_nodes  IN oddgen_types.t_node_type
   ) RETURN oddgen_types.t_param_type;

   /**
   * Generates the prolog
   * If this function is not implemented, no prolog will be generated.
   * Called once for all selected nodes at the very beginning of the processing.
   *
   * @param in_nodes table of selected nodes to be generated
   * @returns generator prolog
   *
   * @since v0.3
   */
   FUNCTION generate_prolog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB;

   /**
   * Generates the separator between generate calls.
   * If this function is not implemented, an empty line will be generated.
   * Called once, but applied between generator calls.
   *
   * @returns generator separator
   *
   * @since v0.3
   */
   FUNCTION generate_separator RETURN VARCHAR2;

   /**
   * Generates the epilog.
   * If this function is not implemented, no epilog will be generated.
   * Called once for all selected nodes at the very end of the processing.
   *
   * @param in_nodes table of selected nodes to be generated
   * @returns generator epilog
   *
   * @since v0.3
   */
   FUNCTION generate_epilog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB;

   /**
   * Generates the result.
   * This function must be implemented.
   * Called for every selected and relevant node, including its children.
   *
   * @param in_node node to be generated
   * @returns generator output
   *
   * @since v0.3
   */
   FUNCTION generate(
      in_node IN oddgen_types.r_node_type
   ) RETURN CLOB;
   
END dropall;
/
