CREATE OR REPLACE PACKAGE BODY dropall IS
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
   -- private constants
   --
   co_new_line CONSTANT string_type := chr(10);
   co_purge    CONSTANT param_type := 'Purge?'; -- for tables only

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Dropall';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates Drop statements for selected objects or object types in the current schema. Dependencies are not considered to order the drop statements.';
   END get_description;

   --
   -- get_object_types
   --
   FUNCTION get_object_types RETURN t_string IS
      l_object_types t_string;
   BEGIN
      SELECT object_type
        BULK COLLECT
        INTO l_object_types
        FROM (SELECT 'ALL' AS object_type
                FROM dual
              UNION ALL
              SELECT object_type
                FROM user_objects
               WHERE generated = 'N'
               GROUP BY object_type
               ORDER BY object_type);
      RETURN l_object_types;
   END get_object_types;

   --
   -- get_object_names
   --
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string IS
      l_object_names t_string;
   BEGIN
      IF in_object_type = 'ALL' THEN
         SELECT DISTINCT object_type
           BULK COLLECT
           INTO l_object_names
           FROM user_objects
          WHERE generated = 'N';
      ELSE
         SELECT object_name
           BULK COLLECT
           INTO l_object_names
           FROM user_objects
          WHERE object_type = in_object_type
                AND generated = 'N'
          ORDER BY object_name;
      END IF;
      RETURN l_object_names;
   END get_object_names;

   --
   -- get_params
   --
   FUNCTION get_params RETURN t_param IS
      l_params t_param;
   BEGIN
      l_params(co_purge) := 'No';
      RETURN l_params;
   END get_params;

   --
   -- get_lov
   --
   FUNCTION get_lov RETURN t_lov IS
      l_lov t_lov;
   BEGIN
      l_lov(co_purge) := NEW t_string('Yes', 'No');
      RETURN l_lov;
   END get_lov;

   --
   -- generate (1)
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN t_param) RETURN CLOB IS
      l_result CLOB;
      --
      PROCEDURE gen_drop(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) IS
         l_templ   CLOB := 'DROP ${object_type} "${object_name}"${options};';
         l_options string_type;
      BEGIN
         CASE in_object_type
            WHEN 'TABLE' THEN
               l_options := ' CASCADE CONSTRAINTS' || CASE
                               WHEN in_params(co_purge) = 'Yes' THEN
                                ' PURGE'
                            END;
            WHEN 'TYPE' THEN
               l_options := ' VALIDATE';
            ELSE
               l_options := NULL;
         END CASE;
         sys.dbms_lob.append(l_result,
                             REPLACE(REPLACE(REPLACE(l_templ,
                                                     '${object_type}',
                                                     in_object_type),
                                             '${object_name}',
                                             in_object_name),
                                     '${options}',
                                     l_options));
      END gen_drop;
      --
      PROCEDURE gen_drop_all IS
      BEGIN
         <<objects>>
         FOR l_rec IN (SELECT object_name
                         FROM user_objects
                        WHERE object_type = in_object_name
                              AND generated = 'N'
                        ORDER BY object_name)
         LOOP
            IF (sys.dbms_lob.getlength(l_result) > 0) THEN
               sys.dbms_lob.append(l_result, co_new_line || co_new_line);
            END IF;
            gen_drop(in_object_type => in_object_name,
                     in_object_name => l_rec.object_name);
         END LOOP objects;
      END gen_drop_all;
   BEGIN
      sys.dbms_lob.createtemporary(l_result, TRUE);
      IF in_object_type = 'ALL' THEN
         gen_drop_all;
      ELSE
         gen_drop(in_object_type => in_object_type, in_object_name => in_object_name);
      END IF;
      RETURN l_result;
   END generate;

   --
   -- generate (2)
   --
   FUNCTION generate(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) RETURN CLOB IS
   BEGIN
      RETURN generate(in_object_type => in_object_type,
                      in_object_name => in_object_name,
                      in_params      => get_params);
   END generate;
END dropall;
/
