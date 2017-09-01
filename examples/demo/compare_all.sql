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
   FUNCTION remove_tailing_newlines(in_text CLOB) RETURN CLOB IS
   BEGIN
      RETURN regexp_replace(in_text, chr(10) || '$', NULL);
   END;
   --
   FUNCTION gen_plsql(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
      r_node   oddgen.oddgen_types.r_node_type;
      t_nodes  oddgen.oddgen_types.t_node_type;
      l_result CLOB;
   BEGIN
      r_node  := to_node(in_object_type, in_object_name);
      t_nodes := oddgen.oddgen_types.t_node_type(r_node);
      l_result := oddgen.plsql_hello_world.generate_prolog(t_nodes);
      dbms_lob.append(l_result, chr(10));
      dbms_lob.append(l_result, oddgen.plsql_hello_world.generate(r_node));
      dbms_lob.append(l_result, chr(10));
      dbms_lob.append(l_result, oddgen.plsql_hello_world.generate_epilog(t_nodes));
      RETURN remove_tailing_newlines(l_result);
   END;
   --
   FUNCTION gen_teplsql(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
      r_node   oddgen.oddgen_types.r_node_type;
      t_nodes  oddgen.oddgen_types.t_node_type;
      l_result CLOB;
   BEGIN
      r_node  := to_node(in_object_type, in_object_name);
      t_nodes := oddgen.oddgen_types.t_node_type(r_node);
      l_result := oddgen.teplsql_hello_world.generate_prolog(t_nodes);
      dbms_lob.append(l_result, oddgen.teplsql_hello_world.generate(r_node));
      dbms_lob.append(l_result, chr(10));
      dbms_lob.append(l_result, oddgen.teplsql_hello_world.generate_epilog(t_nodes));
      RETURN remove_tailing_newlines(l_result);
   END;
   --
   FUNCTION gen_ftldb(
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
      RETURN remove_tailing_newlines(l_result);
   END;
   --
   FUNCTION replace_runtime(in_text CLOB) RETURN CLOB IS
   BEGIN
      RETURN regexp_replace(in_text, '[0-9]+\.[0-9]{3}', '1.234');
   END;
   --
   FUNCTION get_runtime(in_text CLOB) RETURN NUMBER IS
   BEGIN
      RETURN to_number(regexp_substr(in_text, '[0-9]+\.[0-9]{3}', 1));
   END;
   --
   gen AS (
      SELECT --+ no_merge 
             object_name AS table_name,
             gen_plsql(object_type, object_name) AS plsql,
             gen_teplsql(object_type, object_name) AS teplsql,
             gen_ftldb(object_type, object_name) AS ftldb
        FROM user_objects
       WHERE object_type = 'TABLE'
         AND generated = 'N'
   )
SELECT table_name,
       plsql,
       teplsql,
       ftldb,
       get_runtime(plsql) AS plsql_runtime,
       get_runtime(teplsql) AS teplsql_runtime,
       get_runtime(ftldb) AS ftldb_runtime,
       dbms_lob.compare(
          replace_runtime(plsql),
          replace_runtime(teplsql)
       ) AS plsql_vs_teplsql,
       dbms_lob.compare(
          replace_runtime(plsql), 
          replace_runtime(ftldb)
       ) AS plsql_vs_ftldb
  FROM gen
 ORDER BY table_name
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
   FUNCTION gen_plsql(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
   BEGIN
      RETURN remove_tailing_newline(
                oddgen.plsql_view.generate(
                   to_node(in_object_type, in_object_name)
                )
             );
   END;
   --
   FUNCTION gen_teplsql(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
   BEGIN
      RETURN remove_tailing_newline(
                oddgen.teplsql_view.generate(
                   to_node(in_object_type, in_object_name)
                )
             );
   END;
   --
   FUNCTION gen_ftldb(
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
   --
   gen AS (
      SELECT --+ no_merge 
             t.table_name,
             gen_plsql('TABLE', t.table_name) AS plsql,
             gen_teplsql('TABLE', t.table_name) AS teplsql,
             gen_ftldb('TABLE', t.table_name) AS ftldb
        FROM user_tables t
        JOIN user_constraints c
          ON c.table_name = t.table_name
             AND c.constraint_type = 'P'
   )
SELECT table_name,
       plsql,
       teplsql,
       ftldb,
       dbms_lob.compare(plsql, teplsql) AS plsql_vs_teplsql,
       dbms_lob.compare(plsql, ftldb) AS plsql_vs_ftldb
  FROM gen
 ORDER BY table_name
/