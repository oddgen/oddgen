create or replace PACKAGE BODY emp_hier AS
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
   -- private constants
   --
   co_include_commission  CONSTANT oddgen_types.value_type := 'Include commission?';
   co_similing_face_emoji CONSTANT VARCHAR2(32767 BYTE)    := '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';

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Emp hierarchy';
   END get_name;
   
   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates salary report of selected employees in the hierarchy.';
   END get_description;
   
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
         in_name        IN oddgen_types.key_type,
         in_description IN oddgen_types.key_type,
         in_is_leaf     IN INTEGER
      ) IS
         l_node oddgen_types.r_node_type;
      BEGIN
         l_node.id                            := in_id;
         l_node.parent_id                     := in_parent_id;
         l_node.name                          := in_name;
         l_node.description                   := in_description;
         l_node.icon_base64                   := co_similing_face_emoji;
         l_node.params(co_include_commission) := 'YES';
         l_node.leaf                          := in_is_leaf = 1;
         l_node.generatable                   := TRUE;
         l_node.multiselectable               := TRUE;
         l_node.relevant                      := TRUE;
         t_nodes.extend;
         t_nodes(t_nodes.count) := l_node;         
      END add_node;
   BEGIN
      -- load all employees eagerly
      <<emps>>
      FOR r IN (
          SELECT empno,
                 mgr,
                 ename,
                 job,
                 sal,
                 comm,
                 connect_by_isleaf AS is_leaf
            FROM emp
         CONNECT BY PRIOR empno = mgr
           START WITH mgr IS NULL
           ORDER BY sys_connect_by_path(ename, '/')
      ) LOOP 
         add_node(
            in_id          => r.empno,
            in_parent_id   => r.mgr,
            in_name        => initcap(r.ename),
            in_description => initcap(r.ename) 
                              || ' (' || initcap(r.job) 
                              || ', salary: ' || r.sal 
                              || ', commission: ' || NVL(r.comm, 0) 
                              || ')',
            in_is_leaf     => r.is_leaf
         );
      END LOOP emps;
      RETURN t_nodes;
   END get_nodes;
   
   --
   -- get_lov
   --
   FUNCTION get_lov(
      in_params IN oddgen_types.t_param_type,
      in_nodes  IN oddgen_types.t_node_type
   ) RETURN oddgen_types.t_lov_type IS
      t_lov oddgen_types.t_lov_type;
   BEGIN
      t_lov(co_include_commission) := NEW oddgen_types.t_value_type ('YES', 'NO');
      RETURN t_lov;
   END get_lov;
   
   --
   -- generate_prolog
   --
   FUNCTION generate_prolog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB IS
   BEGIN
      RETURN 
'Name           Salary
-------------- ------';
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
      l_epilog CLOB;
      l_total  NUMBER := 0;
   BEGIN
      <<nodes>>
      FOR i in 1 .. in_nodes.count LOOP
         <<emps>>
         FOR r_emp IN (
            SELECT sal, comm
              FROM emp
             WHERE empno = in_nodes(i).id
         ) LOOP
            l_total := l_total + r_emp.sal;
            IF in_nodes(i).params(co_include_commission) = 'YES' THEN
               l_total := l_total + NVL(r_emp.comm, 0);
            END IF;
         END LOOP emps;
      END LOOP nodes;
l_epilog := 
'               ------
Total of ' || rpad(in_nodes.count, 5) || to_char(l_total, '999990') || '
               ======';
      RETURN l_epilog;
   END generate_epilog;

   --
   -- generate
   --
   FUNCTION generate(
      in_node IN oddgen_types.r_node_type
   ) RETURN CLOB IS
      l_result CLOB;
   BEGIN
      <<emp>>
      FOR r_emp IN (
         SELECT sal + 
                CASE 
                   WHEN to_char(in_node.params(co_include_commission)) = 'YES' THEN
                      NVL(comm, 0)
                   ELSE
                      0
                END AS salary
           FROM emp
          WHERE empno = in_node.id
      ) LOOP
         l_result := rpad(in_node.name, 14) || to_char(r_emp.salary, '999990');
      END LOOP emp;
      RETURN l_result;
   END generate;

end emp_hier;
/
