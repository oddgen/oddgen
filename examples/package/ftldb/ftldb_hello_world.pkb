CREATE OR REPLACE PACKAGE BODY ftldb_hello_world IS
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

-- use ${"/"} instead of plain slash (/) to ensure that IDEs such as PL/SQL Developer do not interpret it as command terminator
$IF FALSE $THEN
--%begin generate_ftl
<#assign object_type = template_args[0]/>
<#assign object_name = template_args[1]/>
BEGIN
   sys.dbms_output.put_line('Hello ${object_type} ${object_name}!');
END;
${"/"}
--%end generate_ftl
$END

   --
   -- generate
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB IS
      l_result CLOB;
      l_args varchar2_nt;
   BEGIN
      l_args := NEW varchar2_nt(in_object_type, in_object_name);
      l_result := ftldb_api.process_to_clob(in_templ_name => $$PLSQL_UNIT || '%generate_ftl',
                                            in_templ_args => l_args);
      RETURN l_result;
   END generate;
END ftldb_hello_world;
/
