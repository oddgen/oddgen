CREATE OR REPLACE PACKAGE BODY teplsql2_view IS
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

-- use <%='/'%> instead of plain slash (/) to ensure that IDEs such as PL/SQL Developer do not interpret it as command terminator
-- conditional compilation statements must be defined in lower case
-- grant select_catalog_role to package teplsql.teplsql required (12c feature)
$if false $then
<%@ template name=where_clause %>
<% FOR l_rec IN c_pk_columns LOOP %>
<% IF l_rec.is_first = 1 THEN %>
       WHERE <%= l_rec.column_name %> = :OLD.<%= l_rec.column_name %>
<% ELSE %>
<%= chr(10) %>
         AND <%= l_rec.column_name %> = :OLD.<%= l_rec.column_name %>
<% END IF; %>
<% END LOOP; %>
<%= ';' %>
$end
$if false $then
<%@ template name=generate %>
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
<%@ include(where_clause, TEPLSQL2_VIEW, PACKAGE_BODY, ODDGEN) %>
   ELSIF DELETING THEN
      DELETE FROM ${object_name}
<%@ include(where_clause, TEPLSQL2_VIEW, PACKAGE_BODY, ODDGEN) %>
   END IF;
END;
<%='/'%>\\n
$end
   --
   -- private types
   --
   SUBTYPE object_name_type IS VARCHAR2(30 CHAR);
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);

   --
   -- private constants
   --
   c_max_obj_len  CONSTANT simple_integer := 30;
   c_oddgen_error CONSTANT simple_integer := -20501;

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN '1:1 View (PL/SQL)';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger.';
   END get_description;

   --
   -- get_object_types
   --
   FUNCTION get_object_types RETURN vc2_array IS
   BEGIN
      RETURN NEW vc2_array('TABLES');
   END get_object_types;

   --
   -- get_object_names
   --
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN vc2_array IS
      l_object_names vc2_array;
   BEGIN
      SELECT object_name
        BULK COLLECT
        INTO l_object_names
        FROM dba_objects
       WHERE object_type = in_object_type
         AND owner = USER
       ORDER BY object_name;
      RETURN l_object_names;
   END get_object_names;

   --
   -- get_params
   --
   FUNCTION get_params RETURN vc2_indexed_array IS
      l_params vc2_indexed_array;
   BEGIN
      l_params(c_view_suffix) := '_V';
      l_params(c_table_suffix) := '_T';
      l_params(c_iot_suffix) := '_TRG';
      l_params(c_gen_iot) := 'Yes';
      RETURN l_params;
   END get_params;

   --
   -- get_lovs
   --
   FUNCTION get_lovs RETURN vc2_array_indexed_array IS
      l_params vc2_array_indexed_array;
   BEGIN
      l_params(c_gen_iot) := NEW vc2_array('Yes', 'No');
      RETURN l_params;
   END get_lovs;

   --
   -- generate (1)
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN vc2_indexed_array) RETURN CLOB IS
      l_result CLOB;
      l_params vc2_indexed_array;
      l_vars   teplsql.t_assoc_array;
      --
      FUNCTION get_base_name RETURN VARCHAR2 IS
         l_base_name object_name_type;
      BEGIN
         IF l_params(c_table_suffix) IS NOT NULL AND
            length(l_params(c_table_suffix)) > 0 AND
            substr(in_object_name,
                   length(in_object_name) - length(l_params(c_table_suffix))) =
            l_params(c_table_suffix) THEN
            l_base_name := substr(in_object_name,
                                  1,
                                  length(in_object_name) -
                                  length(l_params(c_table_suffix)));
         ELSE
            l_base_name := in_object_name;
         END IF;
         RETURN l_base_name;
      END get_base_name;
      --
      FUNCTION get_name(suffix_in IN VARCHAR2) RETURN VARCHAR2 IS
         l_name object_name_type;
      BEGIN
         l_name := get_base_name;
         IF length(l_name) + length(suffix_in) > c_max_obj_len THEN
            l_name := substr(l_name, 1, c_max_obj_len - length(suffix_in));
         END IF;
         l_name := l_name || suffix_in;
         RETURN l_name;
      END get_name;
      --
      FUNCTION get_view_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(l_params(c_view_suffix));
      END get_view_name;
      --
      FUNCTION get_iot_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(l_params(c_iot_suffix));
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
            raise_application_error(c_oddgen_error,
                                    'Table ' || in_object_name ||
                                    ' not found.');
         END IF;
         IF get_view_name = in_object_name THEN
            raise_application_error(c_oddgen_error,
                                    'Change <' || c_view_suffix ||
                                    '>. The target view must be named differently than its base table.');
         END IF;
         IF l_params(c_gen_iot) NOT IN ('Yes', 'No') THEN
            raise_application_error(c_oddgen_error,
                                    'Invalid value <' ||
                                    l_params(c_gen_iot) ||
                                    '> for parameter <' || c_gen_iot ||
                                    '>. Valid are Yes and No.');
         END IF;
         IF l_params(c_gen_iot) = 'Yes' THEN
            IF get_iot_name = get_view_name OR
               get_iot_name = in_object_name THEN
               raise_application_error(c_oddgen_error,
                                       'Change <' || c_iot_suffix ||
                                       '>. The target instead-of-trigger must be named differently than its base view and base table.');
            END IF;
            SELECT COUNT(*)
              INTO l_found
              FROM dba_constraints
             WHERE constraint_type = 'P'
                   AND table_name = in_object_name
                   AND owner = USER;
            IF l_found = 0 THEN
               raise_application_error(c_oddgen_error,
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
                  raise_application_error(c_oddgen_error,
                                          'Parameter <' || i ||
                                          '> is not known.');
               END IF;
            END LOOP input_params;
         END IF;
         check_params;
      END init_params;
   BEGIN
      IF in_object_type = 'TABLE' THEN
         init_params;
         l_vars('object_type') := in_object_type;
         l_vars('object_name') := in_object_name;
         l_vars('view_name') := get_view_name;
         l_vars('iot_name') := get_iot_name;
         l_vars('gen_iot') := l_params(c_gen_iot);
         l_vars('schema_name') := SYS_CONTEXT ('USERENV', 'CURRENT_USER');
         l_result := teplsql.process(p_vars          => l_vars,
                                     p_template_name => 'generate',
                                     p_object_name   => $$PLSQL_UNIT,
                                     p_object_type   => 'PACKAGE_BODY',
                                     p_schema        => $$PLSQL_UNIT_OWNER);
      ELSE
         raise_application_error(c_oddgen_error,
                                 '<' || in_object_type ||
                                 '> is not a supported object type. Please use TABLE.');
      END IF;
      RETURN regexp_replace(TRIM(l_result), '[ ]+' || chr(10), chr(10)); -- remove tailing spaces generated by tePLSQL for each template
   END generate;

   --
   -- generate (2)
   --
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB IS
      l_params vc2_indexed_array;
   BEGIN
      RETURN generate(in_object_type => in_object_type,
                      in_object_name => in_object_name,
                      in_params      => l_params);
   END generate;
END teplsql2_view;
/
