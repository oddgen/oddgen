CREATE OR REPLACE PACKAGE BODY dropall IS
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

   --
   -- private constants
   --
   co_newline   CONSTANT oddgen_types.key_type := chr(10);
   co_purge     CONSTANT oddgen_types.key_type := 'Purge?'; -- for tables only
   co_error_no  CONSTANT INTEGER               := -20501;

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Dropall';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates Drop statements for selected objects in the current schema. Dependencies are not considered to order the drop statements.';
   END get_description;

   --
   -- get_folders
   --
   FUNCTION get_folders RETURN oddgen_types.t_value_type IS
   BEGIN
      RETURN NEW oddgen_types.t_value_type('Examples', 'PL/SQL');
   END get_folders;

   --
   -- get_help
   --
   FUNCTION get_help RETURN CLOB IS
   BEGIN
      RETURN 'Not yet available.';
   END get_help;

   --
   -- get_object_group
   --
   FUNCTION get_object_group(
      in_object_type IN VARCHAR2
   ) RETURN VARCHAR2 IS
      l_object_group oddgen_types.key_type;
   BEGIN
      IF in_object_type IN ('FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'TRIGGER', 'TYPE', 'TYPE BODY')
      THEN
         l_object_group := 'CODE';
      ELSE
         l_object_group := 'DATA';
      END IF;
      RETURN l_object_group;
   END get_object_group;

   --
   -- get_nodes
   --
   FUNCTION get_nodes(
      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
   ) RETURN oddgen_types.t_node_type IS
      t_nodes oddgen_types.t_node_type;
      --
      PROCEDURE add_node (
         in_id          IN oddgen_types.key_type,
         in_parent_id   IN oddgen_types.key_type,
         in_leaf        IN BOOLEAN
      ) IS
         l_node oddgen_types.r_node_type;
      BEGIN
         l_node.id               := in_id;
         l_node.parent_id        := in_parent_id;
         IF in_id = 'CODE' THEN
            l_node.icon_name := 'CODE_FOLDER_ICON';
         ELSIF in_id = 'DATA' THEN
            l_node.icon_name := 'DATA_FOLDER_ICON';
         END IF;
         l_node.params(co_purge) := 'YES';
         l_node.leaf             := in_leaf;
         l_node.generatable      := TRUE;
         l_node.multiselectable  := TRUE;
         t_nodes.extend;
         t_nodes(t_nodes.count)  := l_node;         
      END add_node;
   BEGIN
      t_nodes := oddgen_types.t_node_type();
      IF in_parent_node_id IS NULL THEN
         -- generator root nodes
         <<object_groups>>
         FOR r IN (
            SELECT DISTINCT dropall.get_object_group(in_object_type => object_type) AS object_group
              FROM user_objects
             WHERE generated = 'N'
             ORDER BY object_group
         ) LOOP
            add_node(
               in_id        => r.object_group,
               in_parent_id => NULL,
               in_leaf      => false
            );
         END LOOP object_groups;
      ELSIF in_parent_node_id NOT LIKE '%.%' THEN
         -- object type nodes
         <<object_types>>
         FOR r IN (
            SELECT object_type
              FROM user_objects
             WHERE generated = 'N'
               AND dropall.get_object_group(in_object_type => object_type) = in_parent_node_id
             GROUP BY object_type
             ORDER BY object_type
         ) LOOP
            add_node(
               in_id        => in_parent_node_id || '.' || r.object_type,
               in_parent_id => in_parent_node_id,
               in_leaf      => false
            );
         END LOOP object_types;
      ELSE
         -- object name nodes
         <<object_names>>
         FOR r IN (
            SELECT object_type,
                   object_name
              FROM user_objects
             WHERE object_type = substr(in_parent_node_id, INSTR(in_parent_node_id, '.') + 1)
               AND generated = 'N'
              ORDER BY object_name
         ) LOOP
            add_node(
               in_id        => in_parent_node_id || '.' || r.object_name,
               in_parent_id => in_parent_node_id,
               in_leaf      => true
            );
         END LOOP object_names;
      END IF;
      RETURN t_nodes;
   END get_nodes;

   --
   -- get_ordered_params
   --
   FUNCTION get_ordered_params RETURN oddgen_types.t_value_type IS
   BEGIN
      RETURN oddgen_types.t_value_type(co_purge);
   END get_ordered_params;

   --
   -- get_lov
   --
   FUNCTION get_lov(
       in_params IN oddgen_types.t_param_type, -- NOSONAR G-7150: parameter is required by interface
       in_nodes  IN oddgen_types.t_node_type   -- NOSONAR G-7150: parameter is required by interface
   ) RETURN oddgen_types.t_lov_type IS
      l_lov oddgen_types.t_lov_type;
   BEGIN
      l_lov(co_purge) := NEW oddgen_types.t_value_type('YES', 'NO');
      RETURN l_lov;
   END get_lov;

   --
   -- get_param_states
   --
   FUNCTION get_param_states(
      in_params IN oddgen_types.t_param_type, -- NOSONAR G-7150: parameter is required by interface
      in_nodes  IN oddgen_types.t_node_type   -- NOSONAR G-7150: parameter is required by interface
   ) RETURN oddgen_types.t_param_type IS
      t_param_states oddgen_types.t_param_type;
   BEGIN
      t_param_states(co_purge) := '1';
      return t_param_states;
   END get_param_states;

   --
   -- generate_prolog
   --
   FUNCTION generate_prolog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB IS
      t_vc dropall.t_vc_type := dropall.t_vc_type();
      l_result CLOB;
      --
      FUNCTION get_param(
         in_name IN oddgen_types.key_type
      ) RETURN CLOB IS
      BEGIN
         RETURN in_nodes(1).params(in_name);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN NULL;
      END get_param;
      --
      PROCEDURE gen_drop_object_name (
         in_object_type IN oddgen_types.key_type,
         in_object_name in oddgen_types.key_type
      ) IS
         l_templ   CLOB := 'DROP ${object_type} "${object_name}"${options};' || co_newline;
         l_options oddgen_types.value_type;
      BEGIN
         CASE in_object_type
            WHEN 'TABLE' THEN
               l_options := ' CASCADE CONSTRAINTS' ||
                            CASE
                               WHEN get_param(co_purge) = 'YES' THEN
                                  ' PURGE'
                            END;
            WHEN 'TYPE' THEN
               l_options := ' VALIDATE';
            ELSE
               l_options := NULL;
         END CASE;
         sys.dbms_lob.append(
            l_result,
            REPLACE(
               REPLACE(
                  REPLACE(
                     l_templ,
                     '${object_type}',
                     in_object_type
                  ),
                  '${object_name}',
                  in_object_name
               ),
               '${options}',
               l_options
            )
         );
      END gen_drop_object_name;
   BEGIN
      sys.dbms_lob.createtemporary(l_result, TRUE);
      <<populate_nodes>>
      FOR i in 1 .. in_nodes.count LOOP
         t_vc.extend;
         t_vc(t_vc.count) := in_nodes(i).id;
      END LOOP populate_nodes;
      <<process_nodes>>
      FOR r in (
         WITH
            nodes AS (
               SELECT regexp_substr(column_value, '[A-Z_$# ]+', 1, 1) object_group,
                      regexp_substr(column_value, '[A-Z_$# ]+', 1, 2) object_type,
                      regexp_substr(column_value, '[A-Z_$# ]+', 1, 3) object_name
                 FROM TABLE(t_vc)
            )
         SELECT object_type, object_name
           FROM nodes
          ORDER by object_group,
                   CASE object_type
                      WHEN 'VIEW'              THEN 101
                      WHEN 'PROCEDURE'         THEN 102
                      WHEN 'FUNCTION'          THEN 103
                      WHEN 'PACKAGE BODY'      THEN 104
                      WHEN 'PACKAGE'           THEN 105
                      WHEN 'JAVA SOURCE'       THEN 106
                      WHEN 'TYPE BODY'         THEN 107
                      WHEN 'TYPE'              THEN 108
                      WHEN 'INDEX'             THEN 210
                      WHEN 'MATERIALIZED VIEW' THEN 211
                      WHEN 'TABLE'             THEN 212
                      WHEN 'SEQUENCE'          THEN 213
                      ELSE                          300
                   END,
                   object_name
      ) LOOP
         gen_drop_object_name (
           in_object_type => r.object_type,
           in_object_name => r.object_name
         );
      END LOOP process_nodes;
      RETURN l_result;
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
      RETURN NULL;
   END generate;

END dropall;
/
