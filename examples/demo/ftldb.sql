/*
* Copyright 2015-2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
SELECT table_name,
       oddgen.ftldb_hello_world.generate('TABLE', table_name) AS ftldb_hello_world
  FROM user_tables t
 WHERE iot_type IS NULL OR iot_type = 'IOT'
 ORDER BY table_name;

--
-- Generate view and instead-of-trigger
--
SELECT t.table_name,
       oddgen.ftldb_view.generate('TABLE', t.table_name) AS ftldb_view
  FROM user_tables t
  JOIN user_constraints c
    ON c.table_name = t.table_name
       AND c.constraint_type = 'P'
 ORDER BY table_name;
