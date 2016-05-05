CREATE OR REPLACE PACKAGE BODY teplsql_view IS
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
   -- parameter names used also as labels in the GUI
   --
   co_view_suffix  CONSTANT param_type := 'View suffix';
   co_table_suffix CONSTANT param_type := 'Table suffix to be replaced';
   co_iot_suffix   CONSTANT param_type := 'Instead-of-trigger suffix';
   co_gen_iot      CONSTANT param_type := 'Generate instead-of-trigger?';

   --
   -- other constants
   --
   co_max_obj_len  CONSTANT pls_integer := 30;
   co_oddgen_error CONSTANT pls_integer := -20501;

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN '1:1 View (tePLSQL)';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger. The tePLSQL template is defined in a CLOB variable.';
   END get_description;

   --
   -- get_object_types
   --
   FUNCTION get_object_types RETURN t_string IS
   BEGIN
      RETURN NEW t_string('TABLE');
   END get_object_types;

   --
   -- get_object_names
   --
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string IS
      l_object_names t_string;
   BEGIN
      SELECT object_name
        BULK COLLECT
        INTO l_object_names
        FROM dba_objects
       WHERE object_type = in_object_type
         AND owner = USER
         AND generated = 'N'
       ORDER BY object_name;
      RETURN l_object_names;
   END get_object_names;

   --
   -- get_params
   --
   FUNCTION get_params RETURN t_param IS
      l_params t_param;
   BEGIN
      l_params(co_view_suffix) := '_V';
      l_params(co_table_suffix) := '_T';
      l_params(co_iot_suffix) := '_TRG';
      l_params(co_gen_iot) := 'Yes';
      RETURN l_params;
   END get_params;

   --
   -- get_lov
   --
   FUNCTION get_lov RETURN t_lov IS
      l_lov t_lov;
   BEGIN
      l_lov(co_gen_iot) := NEW t_string('Yes', 'No');
      RETURN l_lov;
   END get_lov;

   --
   -- generate (1)
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN t_param) RETURN CLOB IS
      l_result CLOB;
      l_params t_param;
      l_vars   teplsql.t_assoc_array;
      --
      FUNCTION get_base_name RETURN VARCHAR2 IS
         l_base_name string_type;
      BEGIN
         IF l_params(co_table_suffix) IS NOT NULL AND
            length(l_params(co_table_suffix)) > 0 AND
            substr(in_object_name,
                   length(in_object_name) - length(l_params(co_table_suffix))) =
            l_params(co_table_suffix) THEN
            l_base_name := substr(in_object_name,
                                  1,
                                  length(in_object_name) -
                                  length(l_params(co_table_suffix)));
         ELSE
            l_base_name := in_object_name;
         END IF;
         RETURN l_base_name;
      END get_base_name;
      --
      FUNCTION get_name(suffix_in IN VARCHAR2) RETURN VARCHAR2 IS
         l_name string_type;
      BEGIN
         l_name := get_base_name;
         IF length(l_name) + length(suffix_in) > co_max_obj_len THEN
            l_name := substr(l_name, 1, co_max_obj_len - length(suffix_in));
         END IF;
         l_name := l_name || suffix_in;
         RETURN l_name;
      END get_name;
      --
      FUNCTION get_view_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(l_params(co_view_suffix));
      END get_view_name;
      --
      FUNCTION get_iot_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(l_params(co_iot_suffix));
      END get_iot_name;
      --
      PROCEDURE check_params IS
         l_found INTEGER;
      BEGIN
         SELECT COUNT(*)
           INTO l_found
           FROM dba_tables
          WHERE table_name = in_object_name
            AND owner = USER;
         IF l_found = 0 THEN
            raise_application_error(co_oddgen_error,
                                    'Table ' || in_object_name ||
                                    ' not found.');
         END IF;
         IF get_view_name = in_object_name THEN
            raise_application_error(co_oddgen_error,
                                    'Change <' || co_view_suffix ||
                                    '>. The target view must be named differently than its base table.');
         END IF;
         IF l_params(co_gen_iot) NOT IN ('Yes', 'No') THEN
            raise_application_error(co_oddgen_error,
                                    'Invalid value <' ||
                                    l_params(co_gen_iot) ||
                                    '> for parameter <' || co_gen_iot ||
                                    '>. Valid are Yes and No.');
         END IF;
         IF l_params(co_gen_iot) = 'Yes' THEN
            IF get_iot_name = get_view_name OR
               get_iot_name = in_object_name THEN
               raise_application_error(co_oddgen_error,
                                       'Change <' || co_iot_suffix ||
                                       '>. The target instead-of-trigger must be named differently than its base view and base table.');
            END IF;
            SELECT COUNT(*)
              INTO l_found
              FROM dba_constraints
             WHERE constraint_type = 'P'
                   AND table_name = in_object_name
                   AND owner = USER;
            IF l_found = 0 THEN
               raise_application_error(co_oddgen_error,
                                       'No primary key found in table ' ||
                                       in_object_name ||
                                       '. Cannot generate instead-of-trigger.');
            END IF;
         END IF;
      END check_params;
      --
      PROCEDURE init_params IS
         i string_type;
      BEGIN
         l_params := get_params;
         IF in_params.count() > 0 THEN
            i := in_params.first();
            <<input_params>>
            WHILE (i IS NOT NULL)
            LOOP
               IF l_params.exists(i) THEN
                  l_params(i) := in_params(i);
                  i := in_params.next(i);
               ELSE
                  raise_application_error(co_oddgen_error,
                                          'Parameter <' || i ||
                                          '> is not known.');
               END IF;
            END LOOP input_params;
         END IF;
         check_params;
      END init_params;
      --
      FUNCTION get_template RETURN CLOB IS
         l_template CLOB;
      BEGIN
         -- use <%='/'%> instead of plain slash (/) to ensure that IDEs such as PL/SQL Developer do not interpret it as command terminator
         l_template := q'[
<%!
CURSOR c_columns IS
   SELECT column_name,
          CASE
              WHEN column_id = min_column_id THEN
               1
              ELSE
               0
           END AS is_first,
          CASE
              WHEN column_id = max_column_id THEN
               1
              ELSE
               0
           END AS is_last
     FROM (SELECT column_name,
                  column_id,
                  MIN(column_id) over() AS min_column_id,
                  MAX(column_id) over() AS max_column_id
             FROM dba_tab_columns
            WHERE table_name = '${object_name}'
              AND owner = USER)
    ORDER BY column_id;
--
CURSOR c_pk_columns IS
   SELECT column_name,
          CASE
              WHEN position = min_position THEN
               1
              ELSE
               0
           END AS is_first
     FROM (SELECT cols.column_name,
                  cols.position,
                  MIN(cols.position) over() AS min_position
             FROM dba_constraints pk
             JOIN dba_cons_columns cols
               ON cols.constraint_name = pk.constraint_name
                  AND cols.owner = pk.owner
            WHERE pk.constraint_type = 'P'
                  AND pk.table_name = '${object_name}'
                  AND pk.owner = USER)
    ORDER BY position;
--
PROCEDURE add_comma_if(in_condition IN BOOLEAN) IS
BEGIN
   IF in_condition THEN
      teplsql.p(',');
   END IF;
END add_comma_if;
--
PROCEDURE print_where_clause IS
BEGIN
   FOR l_rec IN c_pk_columns
   LOOP
      IF l_rec.is_first = 1 THEN
         teplsql.p('       WHERE ');
      ELSE
         teplsql.p(chr(10));
         teplsql.p('         AND ');
      END IF;
      teplsql.p(l_rec.column_name);
      teplsql.p(' = :OLD.');
      teplsql.p(l_rec.column_name);
   END LOOP;
END print_where_clause;
%>
-- create 1:1 view for demonstration purposes
CREATE OR REPLACE VIEW ${view_name} AS
<% FOR l_rec IN c_columns LOOP %>
<% IF l_rec.is_first = 1 THEN %> 
   SELECT <%= l_rec.column_name %><% add_comma_if(l_rec.is_last = 0); %>\\n
<% ELSE %>
          <%= l_rec.column_name %><% add_comma_if(l_rec.is_last = 0); %>\\n
<% END IF; %>
<% END LOOP; %>
     FROM ${object_name};
<% IF '${gen_iot}' = 'Yes' THEN %>
-- create simple instead-of-trigger for demonstration purposes
CREATE OR REPLACE TRIGGER ${iot_name}
   INSTEAD OF INSERT OR UPDATE OR DELETE ON ${view_name}
BEGIN
   IF INSERTING THEN
      INSERT INTO ${object_name} (
<% FOR l_rec IN c_columns LOOP %>
         <%= l_rec.column_name %><% add_comma_if(l_rec.is_last = 0); %>\\n
<% END LOOP; %>
      ) VALUES (
<% FOR l_rec IN c_columns LOOP %>
         :NEW.<%= l_rec.column_name %><% add_comma_if(l_rec.is_last = 0); %>\\n
<% END LOOP; %>
      );
   ELSIF UPDATING THEN
      UPDATE ${object_name}
<% FOR l_rec IN c_columns LOOP %>
<% IF l_rec.is_first = 1 THEN %>
         SET <%= l_rec.column_name %> = :NEW.<%= l_rec.column_name %><% add_comma_if(l_rec.is_last = 0); %>\\n
<% ELSE %>
             <%= l_rec.column_name %> = :NEW.<%= l_rec.column_name %><% add_comma_if(l_rec.is_last = 0); %>\\n
<% END IF; %>
<% END LOOP; %>
<% print_where_clause; %>;
   ELSIF DELETING THEN
      DELETE FROM ${object_name}
<% print_where_clause; %>;
   END IF;
END;
<%='/'%>\\n
<% END IF; %>
]';
         RETURN substr(l_template, 2); -- remove initial newline
      END get_template;
   BEGIN
      IF in_object_type = 'TABLE' THEN
         init_params;
         l_vars('object_type') := in_object_type;
         l_vars('object_name') := in_object_name;
         l_vars('view_name') := get_view_name;
         l_vars('iot_name') := get_iot_name;
         l_vars('gen_iot') := l_params(co_gen_iot);
         l_result := teplsql.render(p_vars     => l_vars,
                                    p_template => get_template);
      ELSE
         raise_application_error(co_oddgen_error,
                                 '<' || in_object_type ||
                                 '> is not a supported object type. Please use TABLE.');
      END IF;
      RETURN l_result;
   END generate;

   --
   -- generate (2)
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB IS
      l_params t_param;
   BEGIN
      RETURN generate(in_object_type => in_object_type,
                      in_object_name => in_object_name,
                      in_params      => l_params);
   END generate;
END teplsql_view;
/
