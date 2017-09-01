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
-- Generate dbms_output.put_line('Hello ${object_type} ${object_name}!');
--
WITH
   FUNCTION to_node(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN oddgen.oddgen_types.r_node_type IS
      r_node oddgen.oddgen_types.r_node_type;
   BEGIN
      r_node.id        := in_object_type || '.' || in_object_name;
      r_node.parent_id := in_object_type;
      RETURN r_node;
   END;
   --
   FUNCTION gen(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
      r_node   oddgen.oddgen_types.r_node_type;
      t_nodes  oddgen.oddgen_types.t_node_type;
      l_result CLOB;
   BEGIN
      r_node  := to_node(in_object_type, in_object_name);
      t_nodes := oddgen.oddgen_types.t_node_type(r_node);
      l_result := oddgen.ftldb_hello_world.generate_prolog(t_nodes);
      dbms_lob.append(l_result, oddgen.ftldb_hello_world.generate(r_node));
      dbms_lob.append(l_result, oddgen.ftldb_hello_world.generate_epilog(t_nodes));
      RETURN l_result;
   END;
SELECT object_name AS table_name,
       gen(object_type, object_name) AS plsql_hello_world
  FROM user_objects
 WHERE object_type = 'TABLE'
   AND generated = 'N'
 ORDER BY object_name
/

--
-- Generate view and instead-of-trigger
--
WITH 
   FUNCTION to_node(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN oddgen.oddgen_types.r_node_type IS
      r_node oddgen.oddgen_types.r_node_type;
   BEGIN
      r_node.id        := in_object_type || '.' || in_object_name;
      r_node.parent_id := in_object_type;
      RETURN r_node;
   END;
   --
   FUNCTION remove_tailing_newline(in_text CLOB) RETURN CLOB IS
   BEGIN
      RETURN regexp_replace(in_text, chr(10) || '$', NULL);
   END;
   --
   FUNCTION gen(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
   BEGIN
      RETURN remove_tailing_newline(
                oddgen.ftldb_view.generate(
                   to_node(in_object_type, in_object_name)
                )
             );
   END;
SELECT t.table_name,
      gen('TABLE', t.table_name) AS plsql_view
 FROM user_tables t
 JOIN user_constraints c
   ON c.table_name = t.table_name
      AND c.constraint_type = 'P'
ORDER BY table_name
/
