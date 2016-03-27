CREATE OR REPLACE PACKAGE BODY minimal_view AS
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
   FUNCTION generate (
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
      l_clob CLOB;
   BEGIN
      l_clob := 'CREATE OR REPLACE VIEW ' || 
                   LOWER(in_object_name) || '_v AS ' || CHR(10) ||
                   '   SELECT * FROM ' || LOWER(in_object_name) || ';';
       RETURN l_clob;
   END generate;
END minimal_view;
/
