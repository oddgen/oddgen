CREATE OR REPLACE PACKAGE oddgen_interface_example AUTHID CURRENT_USER IS
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

   /** 
   * oddgen PL/SQL database server generator.
   * complete interface example. 
   * PL/SQL package specification only. 
   * PL/SQL package body is not part of the interface definition.
   *
   * @headcom
   */

   /**
   * oddgen PL/SQL data types
   */
   -- Keys, restricted to a reasonable size.
   SUBTYPE key_type    IS VARCHAR2(100 CHAR);
   -- Values, typically short strings, but may contain larger values, e.g. for JSON content or similar.
   SUBTYPE value_type IS CLOB;
   -- Value array
   TYPE t_value_type  IS TABLE OF value_type;
   -- Associative array of parameters (key-value pairs). 
   TYPE t_param_type   IS TABLE OF value_type INDEX BY key_type;
   -- Associative array of list-of-values (key-value pairs, but a value is a value array).
   TYPE t_lov_type     IS TABLE OF t_value_type INDEX BY key_type;
   -- Record type to represent a node in the SQL Developer navigator tree.
   -- Every node contains a co_path (constant) parameter, the value is provided by oddgen.
   -- Icon is evaluated as follows:
   --    a) by icon_base64, if defined and valid
   --    b) by icon_name, if defined and valid
   --    c) UNKNOWN_ICON, if leaf node
   --    d) UNKNOWN_FOLDER_ICON
   TYPE r_node_type    IS RECORD (
      id               key_type,             -- node identifier, case-sensitive, e.g. EMP
      parent_id        key_type,             -- parent node identifier, NULL for root nodes, e.g. TABLE
      name             VARCHAR2(100 CHAR),   -- name of the node, e.g. Emp
      description      VARCHAR2(4000 CHAR),  -- description of the node, e.g. Table Emp
      icon_name        key_type,             -- existing icon name, e.g. TABLE_ICON, VIEW_ICON
      icon_base64      VARCHAR2(32767 BYTE), -- Base64 encoded icon, size 16x16 pixels
      params           t_param_type,         -- array of parameters for a leaf node, co_path on every level
      leaf             VARCHAR2(5 CHAR),     -- Is this a leaf node? true|false, default false
      generatable      VARCHAR2(5 CHAR),     -- Is the node with all its children generatable? true|false, default true
      multiselectable  VARCHAR2(5 CHAR)      -- May this node be part of a multiselection? true|false, default true
   );
   -- Array of nodes representing a part of the full navigator tree within SQL Developer.
   TYPE t_node_type    IS TABLE OF r_node_type;
   
   /**
   * oddgen constants
   */
   -- list of node identifier delimited by '/' representing the selected tree
   co_path CONSTANT VARCHAR2(100 CHAR) := 'Path';

   /**
   * Get name of the generator, used in tree view
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
   * Get the list of all nodes shown to be shown in the SQL Developer navigator tree.
   * The implementation decides if nodes are returned eagerly oder lazily.
   * If this function is not implemented nodes for tables and views are returned lazily.
   *
   * @param in_parent_node_id root node to get children for
   * @returns a list of nodes in a hierarchical structure
   *
   * @since v0.3
   */
   FUNCTION get_nodes(in_parent_node_id IN key_type DEFAULT NULL) RETURN t_node_type;

   /**
   * Get all parameter names in the order to be displayed in the 
   * generate dialog.
   * If this function is not implemented, the parameters are ordered 
   * implicitly by name. Parameter names returned by this function 
   * are taking precedence. Remaining parameters are ordered by name.
   *
   * @param in_params input parameters
   * @returns ordered parameter names
   *
   * @since v0.3
   */
   FUNCTION get_ordered_params(in_params IN t_param_type)
      RETURN t_value_type;

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
   FUNCTION get_lov(in_params IN t_param_type) RETURN t_lov_type;
                    
  /**
   * Get parameter states (enabled/disabled)
   * If this function is not implemented, then the parameters are enabled, if more than one value is valid.
   * This function is called when showing the generate dialog and after updating a parameter.
   *
   * @param in_params input parameters
   * @returns parameters with their editable state ("0"=disabled, "1"=enabled)
   *
   * @since v0.3
   */
   FUNCTION get_param_states(in_params IN t_param_type) RETURN t_param_type;

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
   FUNCTION generate_prolog(in_nodes IN t_node_type) RETURN CLOB;
   
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
   FUNCTION generate_epilog(in_nodes IN t_node_type) RETURN CLOB;

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
   FUNCTION generate(in_params IN t_param_type) RETURN CLOB;

END oddgen_interface_example;
/
