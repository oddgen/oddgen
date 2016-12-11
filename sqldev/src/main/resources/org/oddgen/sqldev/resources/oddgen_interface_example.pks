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
   -- Values, max. string value allowed within PL/SQL.
   SUBTYPE value_type IS VARCHAR2(32767 BYTE);
   -- Keys, restricted to a reasonable size.
   SUBTYPE key_type    IS VARCHAR2(100 CHAR);
   -- Array of strings
   TYPE t_value_type  IS TABLE OF value_type;
   -- Associative array of parameters (key-value pairs). 
   TYPE t_param_type   IS TABLE OF value_type INDEX BY key_type;
   -- Associative array of list-of-values (key-value pairs, but a value is an array of strings).
   TYPE t_lov_type     IS TABLE OF t_value_type INDEX BY key_type;
   -- Record type to represent a folder or a leaf node in the SQL Developer navigator tree.
   TYPE r_node_type    IS RECORD (
      node_id           key_type,     -- e.g. EMP
      parent_node_id    key_type,     -- e.g. TABLE
      node_name         value_type,   -- e.g. Emp
      node_description  value_type,   -- e.g. Table Emp
      node_icon_name    value_type,   -- either icon name or icon_base64, e.g. TABLE_ICON, VIEW_ICON
      node_icon_baset64 value_type,   -- e.g. ...
      node_params       t_param_type, -- e.g. 
      generatable       value_type,   -- e.g. Yes|No
      multiselectable   value_type    -- e.g. Yes|No
   );
   -- Array of nodes representing a part of the full navigator tree within SQL Developer.
   TYPE t_node_type    IS TABLE OF r_node_type;
   -- Array of associative array. Each entry represents the set of parameters for a node to be generator.
   TYPE t_tparam_type  IS TABLE OF t_param_type;

   /**
   * Get name of the generator, used in tree view
   * If this function is not implemented, the package name will be used.
   *
   * @returns name of the generator
   *
   * @since v0.1
   */
   FUNCTION get_name RETURN value_type;

   /**
   * Get the description of the generator.
   * If this function is not implemented, the owner and the package name will be used.
   * 
   * @returns description of the generator
   *
   * @since v0.1
   */
   FUNCTION get_description RETURN value_type;
   
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
   * The implementation decides if nodes are returned eagerly oder lazyly.
   *
   * @param in_parent_node_id root node to get children for
   * @returns a list of all nodes in the tree in a hierarchical structure
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
   * @param in_object_type object type to determine parameter order
   * @param in_object_name object name to determine parameter order
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
   * @param in_object_type object type to determine list of values
   * @param in_object_name object_name to determine list of values
   * @param in_params parameters to configure the behavior of the generator
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
   * @param in_object_type object type to determine parameter state
   * @param in_object_name object_name to determine parameter state
   * @param in_params parameters to configure the behavior of the generator
   * @returns parameters with their editable state ("0"=disabled, "1"=enabled)
   *
   * @since v0.3
   */
   FUNCTION get_param_states(in_params IN t_param_type) RETURN t_value_type;

   /**
   * Generates the result.
   * The generate signature to be used when implmenting the get_nodes function.
   * All parameters are part of in_params. There is no default behaviour for 
   * parameters such as object_type and object_name.
   *
   * @param in_params parameters to customize the code generation
   * @returns generator output
   *
   * @since v0.3
   */
   FUNCTION generate(in_params IN t_param_type) RETURN CLOB;
   
   /**
   * Generates the prolog
   * If this function is not implemented, no prolog will be generated.
   * Called once for all selected nodes at the very begining of the procesing.
   *
   * @param in_tparams table of paramters to summarize processing.
   * @returns generator prolog
   *
   * @since v0.3
   */
   FUNCTION generate_prolog(in_tparams IN t_tparam_type) RETURN CLOB;

   /**
   * Generates the separator between generate calls.
   * If this function is not implemented, an empty line will be generated.
   * Called after every generate call except the last one.
   *
   * @param in_tparams table of paramters to summarize processing.
   * @returns genertor separator
   *
   * @since v0.3
   */
   FUNCTION generate_separator RETURN CLOB;

   /**
   * Generates the epilog.
   * If this function is not implemented, no epilog will be generated.
   * Called once for all selected nodes at the very end of the processing.
   *
   * @param in_tparams table of paramters to summarize processing.
   * @returns generator prolog
   *
   * @since v0.3
   */
   FUNCTION generate_epilog(in_tparams IN t_tparam_type) RETURN CLOB;

END oddgen_interface_example;
/
