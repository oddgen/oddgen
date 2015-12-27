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
-- Generate dbms_output.put_line('Hello <TYPE> <NAME>!');
--
WITH 
   gen AS (
      SELECT --+ no_merge 
             t.table_name,
             oddgen.plsql_hello_world.generate('TABLE', t.table_name) AS plsql,
             oddgen.teplsql_hello_world.generate('TABLE', t.table_name) AS teplsql,
             oddgen.teplsql2_hello_world.generate('TABLE', t.table_name) AS teplsql2,
             oddgen.ftldb_hello_world.generate('TABLE', t.table_name) AS ftldb
        FROM user_tables t
       WHERE iot_type IS NULL OR iot_type = 'IOT'
   )
SELECT table_name,
       plsql,
       teplsql,
       teplsql2,
       ftldb,
       dbms_lob.compare(plsql, teplsql) AS plsql_vs_teplsql,
       dbms_lob.compare(plsql, teplsql2) AS plsql_vs_teplsql2,
       dbms_lob.compare(plsql, ftldb) AS plsql_vs_ftldb
  FROM gen
 ORDER BY table_name;

--
-- Generate view and instead-of-trigger
--
WITH 
   gen AS (
      SELECT --+ no_merge 
             t.table_name,
             oddgen.plsql_view.generate('TABLE', t.table_name) AS plsql,
             oddgen.teplsql_view.generate('TABLE', t.table_name) AS teplsql,
             oddgen.teplsql2_view.generate('TABLE', t.table_name) AS teplsql2,
             oddgen.ftldb_view.generate('TABLE', t.table_name) AS ftldb
        FROM user_tables t
        JOIN user_constraints c
          ON c.table_name = t.table_name
             AND c.constraint_type = 'P'
   )
SELECT table_name,
       plsql,
       teplsql,
       teplsql2,
       ftldb,
       dbms_lob.compare(plsql, teplsql) AS plsql_vs_teplsql,
       dbms_lob.compare(plsql, teplsql2) AS plsql_vs_teplsql2,
       dbms_lob.compare(plsql, ftldb) AS plsql_vs_ftldb
  FROM gen
 ORDER BY table_name;
