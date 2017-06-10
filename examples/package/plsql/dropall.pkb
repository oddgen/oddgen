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
   co_new_line     CONSTANT key_type := chr(10);
   co_object_group CONSTANT key_type := 'Object group';
   co_object_type  CONSTANT key_type := 'Object type';
   co_object_name  CONSTANT key_type := 'Object name';
   co_purge        CONSTANT key_type := 'Purge?'; -- for tables only

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
   -- get_help
   --
   FUNCTION get_help RETURN CLOB IS
   BEGIN
      RETURN 'Not yet available.';
   END get_help;
   
   --
   -- get_object_group
   --
   FUNCTION get_object_group(in_object_type IN VARCHAR2) RETURN VARCHAR2 IS
      l_object_group key_type;
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
   FUNCTION get_nodes(in_parent_node_id IN key_type DEFAULT NULL) RETURN t_node_type IS
      t_nodes  t_node_type;
      l_node   r_node_type;
      -- 
      PROCEDURE add_node(
         in_id           IN key_type,
         in_object_group IN key_type,
         in_object_type  IN key_type DEFAULT NULL,
         in_object_name  IN key_type DEFAULT NULL
      ) IS
      BEGIN
        l_node.parent_id := in_parent_node_id;
        IF in_parent_node_id IS NOT NULL THEN
           l_node.id := in_parent_node_id || '.' || in_id; -- make it unique
        ELSE
           l_node.id := in_id;
        END IF;
        l_node.name := initcap(in_id);
        l_node.params.delete;
        l_node.params(co_object_group) := in_object_group;
        IF in_object_type IS NOT NULL THEN
           l_node.params(co_object_type) := in_object_type;
        END IF;
        IF in_object_name IS NOT NULL THEN
           l_node.params(co_object_name) := in_object_name;
           l_node.leaf := 'Yes';
        END IF;
        l_node.params(co_purge) := 'No';
        t_nodes.extend;
        t_nodes(t_nodes.count) := l_node;
      END add_node;
   BEGIN
      t_nodes := t_node_type();
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
               in_id           => r.object_group,
               in_object_group => r.object_group
            );
         END LOOP object_groups;
      ELSIF in_parent_node_id IN ('CODE', 'DATA') THEN
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
               in_id           => r.object_type,
               in_object_group => in_parent_node_id,
               in_object_type  => r.object_type
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
               in_id           => r.object_name, 
               in_object_group => substr(in_parent_node_id, 1, INSTR(in_parent_node_id, '.') - 1),
               in_object_type  => r.object_type,
               in_object_name  => r.object_name
            );
         END LOOP object_names;
      END IF;
      RETURN t_nodes;       
   END get_nodes;

   --
   -- get_ordered_params
   --
   FUNCTION get_ordered_params(in_params IN t_param_type) RETURN t_value_type IS
   BEGIN
      RETURN t_value_type(co_object_group, co_object_type, co_object_name, co_purge);
   END get_ordered_params;

   --
   -- get_lov
   --
   FUNCTION get_lov(in_params IN t_param_type) RETURN t_lov_type IS
      l_lov t_lov_type;
   BEGIN
      l_lov(co_purge) := NEW t_value_type('Yes', 'No');
      RETURN l_lov;
   END get_lov;
   
   --
   -- get_param_states
   --
   FUNCTION get_param_states(in_params IN t_param_type) RETURN t_param_type IS
      t_param_states t_param_type;
   BEGIN
      t_param_states(co_object_group) := '0';
      t_param_states(co_object_type)  := '0';
      t_param_states(co_object_name)  := '0';
      t_param_states(co_purge)        := '1';
      return t_param_states;
   END get_param_states;
   
   --
   -- generate_prolog
   --
   FUNCTION generate_prolog(in_nodes IN t_node_type) RETURN CLOB IS
      l_prolog CLOB;
   BEGIN
      l_prolog := '-- Selected the following nodes IDs to be dropped:' || co_new_line;
      <<nodes>>
      FOR i IN 1..in_nodes.COUNT LOOP
         l_prolog := l_prolog || '-- - ' || in_nodes(i).id || co_new_line;
      END LOOP nodes;
      l_prolog := l_prolog || co_new_line;
   END generate_prolog;
   
   -- 
   -- generate_separator
   --
   FUNCTION generate_separator RETURN VARCHAR2 IS
   BEGIN
      RETURN co_new_line;
   END generate_separator;
   
   --
   -- generate_epilog
   --
   FUNCTION generate_epilog(in_nodes IN t_node_type) RETURN CLOB IS
   BEGIN
      RETURN NULL;
   END;
   
   --
   -- generate
   --
   FUNCTION generate(in_params IN t_param_type) RETURN CLOB IS
      l_result CLOB;
      --
      FUNCTION get_param(in_name IN key_type) RETURN CLOB IS
      BEGIN
         RETURN in_params(in_name);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN NULL;
      END get_param;
      --
      PROCEDURE gen_drop_object_name(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) IS
         l_templ   CLOB := 'DROP ${object_type} "${object_name}"${options};';
         l_options value_type;
      BEGIN
         CASE in_object_type
            WHEN 'TABLE' THEN
               l_options := ' CASCADE CONSTRAINTS' || CASE
                               WHEN get_param(co_purge) = 'Yes' THEN
                                ' PURGE'
                            END;
            WHEN 'TYPE' THEN
               l_options := ' VALIDATE';
            ELSE
               l_options := NULL;
         END CASE;
         sys.dbms_lob.append(l_result,
                             REPLACE(REPLACE(REPLACE(l_templ,
                                                     '${object_type}',
                                                     in_object_type),
                                             '${object_name}',
                                             in_object_name),
                                     '${options}',
                                     l_options));
      END gen_drop_object_name;
      --
      PROCEDURE gen_drop_object_type(in_object_type IN VARCHAR2) IS
      BEGIN
         <<object_names>>
         FOR r IN (
            SELECT object_name
              FROM user_objects
             WHERE object_type = in_object_type
               AND generated = 'N'
             ORDER BY object_name
         ) LOOP
            IF (sys.dbms_lob.getlength(l_result) > 0) THEN
               sys.dbms_lob.append(l_result, generate_separator);
            END IF;
            gen_drop_object_name(
               in_object_type => in_object_type,
               in_object_name => r.object_name
            );
         END LOOP object_names;
      END gen_drop_object_type;
      --
      PROCEDURE gen_drop_object_group(in_object_group IN VARCHAR2) IS
      BEGIN
         <<object_types>>
         FOR r IN (
            SELECT object_type
              FROM user_objects
             WHERE generated = 'N'
               AND dropall.get_object_group(in_object_type => object_type) = in_object_group
             GROUP BY object_type
             ORDER BY object_type
         ) LOOP
            gen_drop_object_type(in_object_type => r.object_type);
         END LOOP object_types;
      END gen_drop_object_group;
   BEGIN
      sys.dbms_lob.createtemporary(l_result, TRUE);
      IF get_param(co_object_name) IS NOT NULL THEN
         IF get_param(co_object_type) IS NULL THEN
            raise_application_error(-20501, 'Parameter "' || co_object_type || '" is null. Cannot generate code.');
         END IF;
         gen_drop_object_name(in_object_type => in_params(co_object_type), in_object_name => in_params(co_object_name));
      ELSIF get_param(co_object_type) IS NOT NULL THEN
         gen_drop_object_type(in_object_type => in_params(co_object_type));
      ELSE
         IF get_param(co_object_group) IS NULL THEN
            raise_application_error(-20501, 'Parameter "' || co_object_group || '" is null. Cannot generate code.');
         END IF;
         gen_drop_object_group(in_object_group => in_params(co_object_group));
      END IF;
      RETURN l_result;
   END generate;
   
   --
   -- test_generate
   -- 
   FUNCTION test_generate(
      in_object_group IN VARCHAR2,
      in_object_type  IN VARCHAR2 DEFAULT NULL,
      in_object_name  IN VARCHAR2 DEFAULT NULL,
      in_purge        IN VARCHAR2 DEFAULT 'No'
   ) RETURN CLOB IS
      t_params t_param_type;
   BEGIN
      t_params(co_object_group) := in_object_group;
      t_params(co_purge) := in_purge;
      IF in_object_type IS NOT NULL THEN
         t_params(co_object_type) := in_object_type;
      END IF;
      IF in_object_name IS NOT NULL THEN
         t_params(co_object_name) := in_object_name;
      END IF;
      RETURN generate(in_params => t_params);     
   END test_generate;

END dropall;
/
