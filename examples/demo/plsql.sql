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
      l_result := oddgen.plsql_hello_world.generate_prolog(t_nodes);
      dbms_lob.append(l_result, chr(10));
      dbms_lob.append(l_result, oddgen.plsql_hello_world.generate(r_node));
      dbms_lob.append(l_result, chr(10));
      dbms_lob.append(l_result, oddgen.plsql_hello_world.generate_epilog(t_nodes));
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
                oddgen.plsql_view.generate(
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

--
-- Generate drop statement
--
WITH
   PROCEDURE add_nodes (
      io_nodes        IN OUT oddgen.oddgen_types.t_node_type,
      in_parent_node  IN     oddgen.oddgen_types.r_node_type
   ) IS
      t_nodes oddgen.oddgen_types.t_node_type;
   BEGIN
      t_nodes := oddgen.dropall.get_nodes(in_parent_node.id);
      FOR i IN 1 .. t_nodes.count LOOP
         IF    t_nodes(i).parent_id = in_parent_node.id
            OR t_nodes(i).parent_id IS NULL AND in_parent_node.id IS NULL
         THEN
            IF NVL(t_nodes(i).relevant, t_nodes(i).leaf) THEN
               io_nodes.extend;
               io_nodes(io_nodes.count) := t_nodes(i);
            END IF;
            IF NOT t_nodes(i).leaf THEN
               add_nodes(io_nodes, t_nodes(i));
            END IF;
         END IF;
      END LOOP;
   END;
   --
   FUNCTION gen(in_parent_node_id IN VARCHAR2) RETURN CLOB IS
      t_all_nodes      oddgen.oddgen_types.t_node_type;
      t_relevant_nodes oddgen.oddgen_types.t_node_type;
   BEGIN
      t_all_nodes := oddgen.dropall.get_nodes(in_parent_node_id);
      t_relevant_nodes := NEW oddgen.oddgen_types.t_node_type();
      FOR i IN 1 .. t_all_nodes.count LOOP
         add_nodes(t_relevant_nodes, t_all_nodes(i));
      END LOOP;
      RETURN oddgen.dropall.generate_prolog(t_relevant_nodes);
   END;
SELECT 'CODE' AS parent_id,
       gen('CODE') AS script
  FROM dual
UNION ALL
SELECT 'DATA' AS parent_id,
       gen('DATA') AS script
  FROM dual
UNION ALL
SELECT 'DATA.TABLE' AS parent_id,
       gen('DATA.TABLE') AS script
  FROM dual
/

--
-- Generate employee hierarchy report
--
WITH
   PROCEDURE add_nodes (
      io_nodes        IN OUT oddgen.oddgen_types.t_node_type,
      in_parent_node  IN     oddgen.oddgen_types.r_node_type
   ) IS
      t_nodes oddgen.oddgen_types.t_node_type;
   BEGIN
      t_nodes := oddgen.emp_hier.get_nodes(in_parent_node.id);
      FOR i IN 1 .. t_nodes.count LOOP
         IF    t_nodes(i).parent_id = in_parent_node.id
            OR t_nodes(i).parent_id IS NULL AND in_parent_node.id IS NULL
         THEN
            IF NVL(t_nodes(i).relevant, t_nodes(i).leaf) THEN
               io_nodes.extend;
               io_nodes(io_nodes.count) := t_nodes(i);
            END IF;
            IF NOT t_nodes(i).leaf THEN
               add_nodes(io_nodes, t_nodes(i));
            END IF;
         END IF;
      END LOOP;
   END;
   --
   FUNCTION gen(in_root_node_id IN VARCHAR2) RETURN CLOB IS
      l_result         CLOB;
      t_all_nodes      oddgen.oddgen_types.t_node_type;
      t_relevant_nodes oddgen.oddgen_types.t_node_type;
   BEGIN
      t_all_nodes := oddgen.emp_hier.get_nodes(NULL);
      t_relevant_nodes := NEW oddgen.oddgen_types.t_node_type();
      FOR i in 1 .. t_all_nodes.count LOOP
         IF t_all_nodes(i).id = in_root_node_id THEN
            t_relevant_nodes.extend;
            t_relevant_nodes(t_relevant_nodes.count) := t_all_nodes(i);
            add_nodes(t_relevant_nodes, t_all_nodes(i));
         END IF;
      END LOOP;
      l_result := oddgen.emp_hier.generate_prolog(t_relevant_nodes);
      dbms_lob.append(l_result, chr(10));
      FOR i IN 1 .. t_relevant_nodes.count LOOP
         dbms_lob.append(l_result, oddgen.emp_hier.generate(t_relevant_nodes(i)));
         dbms_lob.append(l_result, chr(10));
      END LOOP;
      dbms_lob.append(l_result, oddgen.emp_hier.generate_epilog(t_relevant_nodes));
      RETURN l_result;
   END;
SELECT empno AS root_id,
       ename AS root_name,
       gen(empno) AS report
  FROM emp
CONNECT BY PRIOR empno = mgr
START WITH mgr IS NULL
ORDER BY sys_connect_by_path(ename, '/')
/

