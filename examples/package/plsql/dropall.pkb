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
         -- group names (root nodes)
         add_node(
            in_id        => 'CODE',
            in_parent_id => NULL,
            in_leaf      => FALSE
         );
         add_node(
            in_id        => 'DATA',
            in_parent_id => NULL,
            in_leaf      => FALSE
         );
      ELSIF in_parent_node_id NOT LIKE '%.%' THEN
         -- object types (parent nodes are group names) 
         <<nodes>>
         FOR r IN (
            WITH 
               base AS (
                  SELECT CASE 
                            WHEN object_type IN ('FUNCTION', 'PACKAGE', 'PACKAGE BODY',
                               'PROCEDURE', 'SYNONYM', 'TRIGGER', 'TYPE', 'TYPE BODY')
                            THEN
                               'CODE'
                            ELSE
                               'DATA'
                         END AS group_name,
                         object_type
                    FROM user_objects
                   WHERE generated = 'N'
                     AND object_type NOT IN ('INDEX PARTITION', 'LOB', 'TABLE PARTITION')
                   GROUP BY object_type
               )
            SELECT object_type
              FROM base
             WHERE group_name = in_parent_node_id
         ) LOOP
            add_node(
               in_id        => in_parent_node_id || '.' || r.object_type,
               in_parent_id => in_parent_node_id,
               in_leaf      => FALSE
            );
         END LOOP nodes;
      ELSE
         -- object names (parent nodes are object types)
         <<nodes>>
         FOR r IN (
            SELECT object_name
              FROM user_objects
             WHERE object_type = regexp_substr(in_parent_node_id, '[^\.]+', 1, 2)
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
      l_ids    CLOB;
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
      --
      PROCEDURE populate_ids IS
      BEGIN
         sys.dbms_lob.createtemporary(l_ids, TRUE);
         sys.dbms_lob.append(l_ids, '<ids>');
         <<nodes>>
         FOR i in 1 .. in_nodes.count LOOP
            sys.dbms_lob.append(l_ids, '<id>' || in_nodes(i).id || '</id>');
         END LOOP nodes;
         sys.dbms_lob.append(l_ids, '</ids>');
      END populate_ids;
      --
      PROCEDURE populate_result IS
      BEGIN
         sys.dbms_lob.createtemporary(l_result, TRUE);
         <<nodes>>
         FOR r in (
            WITH
               nodes AS (
                  SELECT regexp_substr(id, '[^\.]+', 1, 1) object_group,
                         regexp_substr(id, '[^\.]+', 1, 2) object_type,
                         regexp_substr(id, '[^\.]+', 1, 3) object_name
                    FROM XMLTABLE(
                            '/ids/id'
                            PASSING XMLTYPE(l_ids)
                            COLUMNS id VARCHAR2(4000) PATH '.'
                         )
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
         END LOOP nodes;
      END populate_result;
   BEGIN
      populate_ids;
      populate_result;
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
