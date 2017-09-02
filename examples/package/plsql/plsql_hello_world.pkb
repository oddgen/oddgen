CREATE OR REPLACE PACKAGE BODY plsql_hello_world IS
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
   
   --
   -- private declarations
   --
   g_start_time TIMESTAMP(6)                     := SYSTIMESTAMP;
   co_newline   CONSTANT oddgen_types.value_type := chr(10);
   
   --
   -- get_runtime
   --
   FUNCTION get_runtime RETURN NUMBER IS
      l_stmt    CLOB;
      l_runtime INTERVAL DAY TO SECOND(6);
      l_millis  NUMBER;
   BEGIN
      l_runtime := systimestamp - g_start_time;
      l_millis := (extract(second from l_runtime)
                   + extract(minute from l_runtime) * 60
                   + extract(hour from l_runtime) * 60 * 60
                   + extract(day from l_runtime) * 24 * 60 * 60) * 1000;
      RETURN l_millis;
   END get_runtime;

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Hello World';
   END get_name;
   
   --
   -- get_folders
   --
   FUNCTION get_folders RETURN oddgen_types.t_value_type IS
   BEGIN
      RETURN NEW oddgen_types.t_value_type('Examples', 'PL/SQL');
   END get_folders;

   --
   -- get_nodes
   --
   FUNCTION get_nodes(
      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
   ) RETURN oddgen_types.t_node_type IS
      t_nodes oddgen_types.t_node_type := oddgen_types.t_node_type();
      --
      PROCEDURE add_node (
         in_id          IN oddgen_types.key_type,
         in_parent_id   IN oddgen_types.key_type,
         in_leaf     IN INTEGER
      ) IS
         l_node oddgen_types.r_node_type;
      BEGIN
         l_node.id                            := in_id;
         l_node.parent_id                     := in_parent_id;
         l_node.leaf                          := in_leaf = 1;
         l_node.generatable                   := TRUE;
         l_node.multiselectable               := TRUE;
         t_nodes.extend;
         t_nodes(t_nodes.count) := l_node;         
      END add_node;
   BEGIN
      -- load all objects eagerly
      <<objects>>
      FOR r IN (
			SELECT 'TABLE' AS id,
			       NULL AS parent_id,
			       0 AS leaf
			  FROM dual
			UNION ALL
			SELECT 'VIEW' AS id,
			       NULL AS parent_id,
			       0 AS leaf
			  FROM dual
			UNION ALL
			SELECT object_type || '.' || object_name AS id,
			       object_type AS parent_id,
			       1 AS leaf
			  FROM user_objects
			 WHERE object_type IN ('TABLE', 'VIEW')
			   AND generated = 'N'
      ) LOOP
         add_node(
            in_id        => r.id,
            in_parent_id => r.parent_id,
            in_leaf      => r.leaf
         );
      END LOOP objects;
      RETURN t_nodes;
   END get_nodes;

   --
   -- generate_prolog
   --
   FUNCTION generate_prolog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB is
      l_prolog CLOB;
   BEGIN
      g_start_time := SYSTIMESTAMP;
      sys.dbms_lob.createtemporary(l_prolog, TRUE);
      sys.dbms_lob.append(l_prolog, 'BEGIN' || co_newline);
      sys.dbms_lob.append(l_prolog, '   -- ' || in_nodes.count || ' nodes selected.');
      IF in_nodes.count = 0 THEN
         sys.dbms_lob.append(l_prolog, co_newline || '   NULL;');
      END IF;
      return l_prolog;
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
      RETURN '   -- ' 
             || in_nodes.count || ' nodes generated in ' || to_char(get_runtime,'FM999990.000') || ' ms.' 
             || co_newline || 'END;'
             || co_newline || '/';
   END generate_epilog;

   --
   -- generate
   --
   FUNCTION generate(
      in_node IN oddgen_types.r_node_type
   ) RETURN CLOB IS
      l_object_type oddgen_types.key_type;
      l_object_name oddgen_types.key_type;
   BEGIN
      l_object_type := in_node.parent_id;
      l_object_name := regexp_substr(in_node.id, '[^\.]+', 1, 2);
      RETURN '   sys.dbms_output.put_line(''Hello ' || l_object_type || ' ' || l_object_name || '!'');';
   END generate;

END plsql_hello_world;
/
