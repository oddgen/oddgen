/*
* Copyright 2016 Steven Feuerstein <steven.feuerstein@oracle.com>
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

-- original function on https://livesql.oracle.com/apex/livesql/file/content_C7VKBA85Q9PUS2XRAL1U8J3LG.html
-- 1:1 from https://livesql.oracle.com/apex/livesql/file/content_C73WCRT0FK21A78LLMZJSDW2J.html
CREATE OR REPLACE PACKAGE genwhen AUTHID CURRENT_USER IS
   FUNCTION generate(in_object_type IN VARCHAR2 DEFAULT 'TABLE',
                     in_object_name IN VARCHAR2) RETURN CLOB;
END genwhen;
/

CREATE OR REPLACE PACKAGE BODY genwhen IS
   FUNCTION generate(in_object_type IN VARCHAR2 DEFAULT 'TABLE',
                     in_object_name IN VARCHAR2) RETURN CLOB IS
      l_result CLOB;
      PROCEDURE pl(in_str IN VARCHAR2) IS
      BEGIN
         sys.dbms_lob.append(l_result, in_str);
         sys.dbms_lob.append(l_result, chr(10));
      END pl;
   BEGIN
      sys.dbms_lob.createtemporary(l_result, TRUE);
      <<cols>>
      FOR l_col_rec IN (SELECT column_name
                          FROM user_tab_columns
                         WHERE table_name = upper(in_object_name))
      LOOP
         IF sys.dbms_lob.getlength(l_result) > 0 THEN
            pl('OR');
         END IF;
         pl('(   OLD.' || l_col_rec.column_name || ' != NEW.' || l_col_rec.column_name);
         pl('OR (OLD.' || l_col_rec.column_name || ' IS NULL AND NEW.' ||
            l_col_rec.column_name || ' IS NOT NULL))');
         pl('OR (OLD.' || l_col_rec.column_name || ' IS NOT NULL AND NEW.' ||
            l_col_rec.column_name || ' IS NULL))');
      END LOOP cols;
      RETURN l_result;
   END generate;
END genwhen;
/

GRANT EXECUTE ON genwhen TO PUBLIC;

