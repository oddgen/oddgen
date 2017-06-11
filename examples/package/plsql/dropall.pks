CREATE OR REPLACE PACKAGE dropall AUTHID CURRENT_USER IS
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

   /**
   * oddgen PL/SQL example to generates Drop statements for selected objects in the current schema.
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
   * Get the help of the generator.
   * If this function is not implemented, no help is available.
   *
   * @returns help text as HTML
   *
   * @since v0.3
   */
   FUNCTION get_help RETURN CLOB;
   
   /**
   * Get the group of an object type. 
   * Function to be used in SQL, it is not part of the oddgen iterface.
   *
   * @param in_object_type object_type according user_objects
   * @returns the group of object type, either CODE or DATA
   */
   FUNCTION get_object_group(
      in_object_type IN VARCHAR2
   ) RETURN VARCHAR2;

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
   * @param in_params input parameters
   * @returns ordered parameter names
   *
   * @since v0.3
   */
   FUNCTION get_ordered_params(
      in_params IN oddgen_types.t_param_type
   ) RETURN oddgen_types.t_value_type;

   /**
   * Get the list of values per parameter, if such a LOV is applicable.
   * If this function is not implemented, then the parameters cannot be validated in the GUI.
   * This function is called when showing the generate dialog and after updating a parameter.
   *
   * @param in_params input parameters
   * @returns parameters with their list-of-values
   *
   * @since v0.3
   */
   FUNCTION get_lov(
      in_params IN oddgen_types.t_param_type
   ) RETURN oddgen_types.t_lov_type;

  /**
   * Get the list of parameter states (enabled/disabled)
   * If this function is not implemented, then the parameters are enabled, if more than one value is valid.
   * This function is called when showing the generate dialog and after updating a parameter.
   *
   * @param in_params input parameters
   * @returns parameters with their editable state ("0"=disabled, "1"=enabled)
   *
   * @since v0.3
   */
   FUNCTION get_param_states(
      in_params IN oddgen_types.t_param_type
   ) RETURN oddgen_types.t_param_type;

   /**
   * Generates the prolog
   * If this function is not implemented, no prolog will be generated.
   * Called once for all selected nodes at the very beginning of the processing.
   *
   * @param in_nodes table of selected nodes to be generated.
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
   * Called once, but used between generator calls.
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
   * @param in_nodes table of selected nodes to be generated.
   * @returns generator epilog
   *
   * @since v0.3
   */
   FUNCTION generate_epilog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB;

   /**
   * Generates the result.
   * The generate signature to be used when implementing the get_nodes function.
   * All parameters are part of in_params.
   *
   * @param in_params input parameters
   * @returns generator output
   *
   * @since v0.3
   */
   FUNCTION generate(
      in_params IN oddgen_types.t_param_type
   ) RETURN CLOB;
   
   /**
   * Wrapper to test the generator from SQL.
   * Not part of the oddgen interface.
   *
   * @param in_object_group e.g. CODE, DATA
   * @param in_object_type e.g. TABLE
   * @param in_object_name e.g. EMP
   */
   FUNCTION test_generate(
      in_object_group IN VARCHAR2,
      in_object_type  IN VARCHAR2 DEFAULT NULL,
      in_object_name  IN VARCHAR2 DEFAULT NULL,
      in_purge        IN VARCHAR2 DEFAULT 'No'
   ) RETURN CLOB;
   
END dropall;
/
