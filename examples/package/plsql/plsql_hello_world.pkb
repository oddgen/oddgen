CREATE OR REPLACE PACKAGE BODY plsql_hello_world IS
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
   -- generate
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB IS
      l_result CLOB;
   BEGIN
      l_result := 'BEGIN' || chr(10) ||
                  '   sys.dbms_output.put_line(''Hello ' || in_object_type || ' ' ||
                  in_object_name || '!'');' || chr(10) || 'END;' || chr(10) || '/' ||
                  chr(10);
      RETURN l_result;
   END generate;
END plsql_hello_world;
/
