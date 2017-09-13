CREATE OR REPLACE PACKAGE oddgen_types AUTHID CURRENT_USER IS
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

   /**
   * oddgen data types for PL/SQL database server generator.
   * This package must be installed in the same schema as the generators.
   * The user executing the generator must have execute privileges for this package.
   *
   * @headcom
   */

   /**
   * Keys, generic string values
   *
   * @since v0.3
   */
   SUBTYPE key_type    IS VARCHAR2(4000 BYTE);

   /**
   * Values, typically short strings, but may contain larger values, 
   * e.g. for JSON content or similar.
   *
   * @since v0.3
   */
   SUBTYPE value_type  IS VARCHAR2(32767 BYTE);

   /**
   * Value array.
   *
   * @since v0.3
   */
   TYPE t_value_type   IS TABLE OF value_type;

   /**
   * Associative array of parameters (key-value pairs).
   *
   * @since v0.3
   */
   TYPE t_param_type   IS TABLE OF value_type INDEX BY key_type;

   /**
   * Associative array of list-of-values (key-value pairs, but a value is a value array).
   *
   * @since v0.3
   */
   TYPE t_lov_type     IS TABLE OF t_value_type INDEX BY key_type;

   /**
   * Record type to represent a node in the SQL Developer navigator tree.
   * Icon is evaluated as follows:
   *    a) by icon_name, if defined
   *    b) by icon_base64, if defined
   *    c) by parent_id, if leaf node and parent_id is a known object type (normal icon)
   *    d) by id, if non-leaf node and id is a known object type (folder icon)
   *    e) UNKNOWN_ICON, if leaf node
   *    f) UNKNOWN_FOLDER_ICON, if non-leaf node
   *
   * @since v0.3
   */
   TYPE r_node_type    IS RECORD (
      id               key_type,     -- node identifier, case-sensitive, e.g. EMP
      parent_id        key_type,     -- parent node identifier, NULL for root nodes, e.g. TABLE
      name             value_type,   -- name of the node, e.g. Emp
      description      value_type,   -- description of the node, e.g. Table Emp
      icon_name        key_type,     -- existing icon name, e.g. TABLE_ICON, VIEW_ICON
      icon_base64      value_type,   -- Base64 encoded icon, size 16x16 pixels
      params           t_param_type, -- array of parameters, e.g. View suffix=_V, Instead-of-trigger suffix=_TRG
      leaf             BOOLEAN,      -- Is this a leaf node? true|false, default false
      generatable      BOOLEAN,      -- Is the node with all its children generatable? true|false, default leaf
      multiselectable  BOOLEAN,      -- May this node be part of a multiselection? true|false, default leaf
      relevant         BOOLEAN       -- Pass node to the generator? true|false, default leaf
   );

   /**
   * Array of nodes, typically containing relevant nodes only.
   *
   * @since v0.3
   */
   TYPE t_node_type    IS TABLE OF r_node_type;

END oddgen_types;
/

CREATE OR REPLACE PACKAGE extended_view AUTHID CURRENT_USER IS
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
   * oddgen PL/SQL database server generator.
   * complete interface.
   * PL/SQL package specification only.
   * PL/SQL package body is not part of the interface definition.
   * Requires the ODDGEN_TYPES package specification to be installed in 
   * the same schema. 
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
   * If this function is not implemented, the default will be determined
   * based on the generator type. For generators stored in the database 
   * this will be oddgen_types.t_value_type('Database Server Generators').
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
   * Called for every selected node.
   * Children of nodes are not resolved by oddgen.
   *
   * @param in_node node to be generated
   * @returns generator output
   *
   * @since v0.3
   */
   FUNCTION generate(
      in_node IN oddgen_types.r_node_type
   ) RETURN CLOB;

END extended_view;
/

CREATE OR REPLACE PACKAGE BODY extended_view IS
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
      RETURN 'Extended_view';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Extended_view';
   END get_description;

   --
   -- get_folders
   --
   FUNCTION get_folders RETURN oddgen_types.t_value_type IS
   BEGIN
      RETURN NEW oddgen_types.t_value_type('Database Server Generators');
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

END extended_view;
/
