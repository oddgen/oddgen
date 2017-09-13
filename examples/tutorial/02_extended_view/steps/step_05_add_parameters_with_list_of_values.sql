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
   co_select_star   CONSTANT oddgen_types.key_type := 'Select * ?';
   co_view_suffix   CONSTANT oddgen_types.key_type := 'View suffix';
   co_order_columns CONSTANT oddgen_types.key_type := 'Order columns?';

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Extended 1:1 View Generator';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates a 1:1 view based on an existing ' || 
         'table and various generator parameters.';
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
         l_node.id                       := in_id;
         l_node.parent_id                := in_parent_id;
         l_node.leaf                     := in_leaf;
         l_node.generatable              := TRUE;
         l_node.multiselectable          := TRUE;
         l_node.params(co_select_star)   := 'No';
         l_node.params(co_view_suffix)   := '_v';
         l_node.params(co_order_columns) := 'No';
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
      RETURN NEW oddgen_types.t_value_type(
                    co_select_star, 
                    co_view_suffix, 
                    co_order_columns
                 );
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
      IF in_params(co_select_star) = 'Yes' THEN
         l_lov(co_order_columns) := NEW oddgen_types.t_value_type('No');
      ELSE
         l_lov(co_order_columns) := NEW oddgen_types.t_value_type('Yes', 'No');
      END IF;
      IF in_params(co_order_columns) = 'Yes' THEN
         l_lov(co_select_star) := NEW oddgen_types.t_value_type('No');
      ELSE
         l_lov(co_select_star) := NEW oddgen_types.t_value_type('Yes', 'No');
      END IF;
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
      l_templ        CLOB := 
'CREATE OR REPLACE VIEW ${view_name} AS
   SELECT ${column_names}
     FROM ${table_name};';
      l_clob         CLOB;
      l_view_name    oddgen_types.key_type;
      l_column_names oddgen_types.key_type;
      l_table_name   oddgen_types.key_type;
   BEGIN
      -- prepare placeholders
      l_column_names := '*';
      l_table_name := lower(regexp_substr(in_node.id, '[^\.]+', 1, 2));
      l_view_name := l_table_name || '_v';
      -- produce final clob, replace placeholder in template
      l_clob := REPLACE(l_templ, '${column_names}', l_column_names);
      l_clob := REPLACE(l_clob, '${view_name}', l_view_name);
      l_clob := REPLACE(l_clob, '${table_name}', l_table_name);
      RETURN l_clob;
   END generate;

END extended_view;
/
