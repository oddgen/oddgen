CREATE OR REPLACE PACKAGE BODY ftldb_view IS
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
<#assign view_name = template_args[2]/>
<#assign iot_name = template_args[3]/>
<#assign gen_iot = template_args[4]/>
<#assign conn = default_connection()/>
<#assign columns_query>
   SELECT column_name
     FROM dba_tab_columns
    WHERE table_name = '${object_name}'
      AND owner = USER
    ORDER BY column_id
</#assign>
<#assign columns = conn.query(columns_query)/>
<#assign pk_columns_query>
   SELECT cols.column_name
     FROM dba_constraints pk
     JOIN dba_cons_columns cols
       ON cols.constraint_name = pk.constraint_name
          AND cols.owner = pk.owner
    WHERE pk.constraint_type = 'P'
          AND pk.table_name = '${object_name}'
          AND pk.owner = USER
    ORDER BY cols.position
</#assign>
<#assign pk_columns = conn.query(pk_columns_query)/>
<#macro get_where_clause>
   <#list pk_columns as col>
      <#if col?is_first>
       WHERE ${col.COLUMN_NAME} = :OLD.${col.COLUMN_NAME}<#if col?is_last>;</#if>
      <#else>
         AND ${col.COLUMN_NAME} = :OLD.${col.COLUMN_NAME}<#if col?is_last>;</#if>
      </#if>
   </#list>
</#macro>
-- create 1:1 view for demonstration purposes
CREATE OR REPLACE VIEW ${view_name} AS
<#list columns as col>
   <#if col?is_first>
   SELECT ${col.COLUMN_NAME}<#sep>,</#sep>
   <#else>
          ${col.COLUMN_NAME}<#sep>,</#sep>
   </#if>
</#list>
     FROM ${object_name};
<#if gen_iot = "Yes">
-- create simple instead-of-trigger for demonstration purposes
CREATE OR REPLACE TRIGGER ${iot_name}
   INSTEAD OF INSERT OR UPDATE OR DELETE ON ${view_name}
BEGIN
   IF INSERTING THEN
      INSERT INTO ${object_name} (
   <#list columns as col>
         ${col.COLUMN_NAME}<#sep>,</#sep>
   </#list>
      ) VALUES (
   <#list columns as col>
         :NEW.${col.COLUMN_NAME}<#sep>,</#sep>
   </#list>
      );
   ELSIF UPDATING THEN
      UPDATE ${object_name}
   <#list columns as col>
      <#if col?is_first>
         SET ${col.COLUMN_NAME} = :NEW.${col.COLUMN_NAME}<#sep>,</#sep>
      <#else>
             ${col.COLUMN_NAME} = :NEW.${col.COLUMN_NAME}<#sep>,</#sep>
      </#if>
   </#list>
<@get_where_clause/>
   ELSIF DELETING THEN
      DELETE FROM ${object_name}
<@get_where_clause/>
   END IF;
END;
${"/"}
</#if>
--%end generate_ftl
$END

   --
   -- parameter names used also as labels in the GUI
   --
   co_view_suffix  CONSTANT oddgen_types.value_type := 'View suffix';
   co_table_suffix CONSTANT oddgen_types.value_type := 'Table suffix to be replaced';
   co_iot_suffix   CONSTANT oddgen_types.value_type := 'Instead-of-trigger suffix';
   co_gen_iot      CONSTANT oddgen_types.value_type := 'Generate instead-of-trigger?';

   --
   -- other constants
   --
   co_newline      CONSTANT oddgen_types.key_type := chr(10);
   co_max_obj_len  CONSTANT PLS_INTEGER           := 30;
   co_oddgen_error CONSTANT PLS_INTEGER           := -20501;
   
   --
   -- get_default_params (private)
   --
   FUNCTION get_default_params RETURN oddgen_types.t_param_type IS
      l_params oddgen_types.t_param_type;
   BEGIN
      l_params(co_view_suffix)  := '_V';
      l_params(co_table_suffix) := '_T';
      l_params(co_iot_suffix)   := '_TRG';
      l_params(co_gen_iot)      := 'Yes';
      RETURN l_params;
   END get_default_params;

   --
   -- get_name
   --
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN '1:1 View';
   END get_name;

   --
   -- get_description
   --
   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates a 1:1 view based on an existing table. Optionally generates a simple instead of trigger. The generator is based on plain PL/SQL without a third party template engine.';
   END get_description;

   --
   -- get_folders
   --
   FUNCTION get_folders RETURN oddgen_types.t_value_type IS
   BEGIN
      RETURN NEW oddgen_types.t_value_type('Examples', 'PL/SQL (FTLDB)');
   END get_folders;

   --
   -- get_help
   --
   FUNCTION get_help RETURN CLOB IS
   BEGIN
      RETURN 'Not yet available.';
   END get_help;

   --
   -- get_nodes
   --
   FUNCTION get_nodes(
      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
   ) RETURN oddgen_types.t_node_type IS
      t_nodes oddgen_types.t_node_type;
      --
      PROCEDURE add_node (
         in_id          IN oddgen_types.key_type,
         in_parent_id   IN oddgen_types.key_type,
         in_leaf        IN BOOLEAN
      ) IS
         l_node oddgen_types.r_node_type;
      BEGIN
         l_node.id              := in_id;
         l_node.parent_id       := in_parent_id;
         l_node.params          := get_default_params;
         l_node.leaf            := in_leaf;
         l_node.generatable     := TRUE;
         l_node.multiselectable := TRUE;
         t_nodes.extend;
         t_nodes(t_nodes.count) := l_node;         
      END add_node;
   BEGIN
      t_nodes := oddgen_types.t_node_type();
      IF in_parent_node_id IS NULL THEN
         -- object types
         add_node(
            in_id        => 'TABLE',
            in_parent_id => NULL,
            in_leaf      => FALSE
         );
      ELSE
         -- object names
         <<nodes>>
         FOR r IN (
            SELECT object_name
              FROM dba_objects
             WHERE owner = USER 
               AND object_type = in_parent_node_id
               AND generated = 'N'
         ) LOOP
            add_node(
               in_id        => in_parent_node_id || '.' || r.object_name,
               in_parent_id => in_parent_node_id,
               in_leaf      => TRUE
            );
         END LOOP nodes;
      END IF;
      RETURN t_nodes;
   END get_nodes;

   --
   -- get_ordered_params
   --
   FUNCTION get_ordered_params RETURN oddgen_types.t_value_type IS
   BEGIN
      RETURN NEW oddgen_types.t_value_type(co_view_suffix, co_table_suffix, co_gen_iot);
   END get_ordered_params;

   --
   -- get_lov
   --
   FUNCTION get_lov(
      in_params IN oddgen_types.t_param_type,
      in_nodes  IN oddgen_types.t_node_type
   ) RETURN oddgen_types.t_lov_type IS
      l_lov oddgen_types.t_lov_type;
   BEGIN
      l_lov(co_gen_iot) := NEW oddgen_types.t_value_type('Yes', 'No');
      RETURN l_lov;
   END get_lov;

   --
   -- get_param_states
   --
   FUNCTION get_param_states(
      in_params IN oddgen_types.t_param_type,
      in_nodes  IN oddgen_types.t_node_type
   ) RETURN oddgen_types.t_param_type IS
      l_param_states oddgen_types.t_param_type;
   BEGIN
      IF in_params(co_gen_iot) = 'Yes' THEN
         l_param_states(co_iot_suffix) := '1'; -- enable
      ELSE
         l_param_states(co_iot_suffix) := '0'; -- disable
      END IF;
      RETURN l_param_states;
   END get_param_states;

   --
   -- generate_prolog
   --
   FUNCTION generate_prolog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB IS
   BEGIN
      RETURN NULL;
   END generate_prolog;

   --
   -- generate_separator
   --
   FUNCTION generate_separator RETURN VARCHAR2 IS
   BEGIN
      RETURN co_newline;
   END generate_separator;

   --
   -- generate_epilog
   --
   FUNCTION generate_epilog(
      in_nodes IN oddgen_types.t_node_type
   ) RETURN CLOB IS
   BEGIN
      RETURN NULL;
   END generate_epilog;

   --
   -- generate
   --
   FUNCTION generate(
      in_node IN oddgen_types.r_node_type
   ) RETURN CLOB IS
      l_object_type oddgen_types.key_type;
      l_object_name oddgen_types.key_type;
      t_params      oddgen_types.t_param_type;
      l_args varchar2_nt;
      l_result      CLOB;
      --
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
                  WHERE owner = USER
                    AND table_name = l_object_name)
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
                     ON cols.owner = pk.owner
                        AND cols.constraint_name = pk.constraint_name
                  WHERE pk.owner = USER
                    AND pk.constraint_type = 'P'
                    AND pk.table_name = l_object_name)
          ORDER BY position;
      --
      FUNCTION get_base_name RETURN VARCHAR2 IS
         l_base_name oddgen_types.key_type;
      BEGIN
         IF t_params(co_table_suffix) IS NOT NULL AND
            length(t_params(co_table_suffix)) > 0 AND
            substr(in_node.id,
                   length(l_object_name) - length(t_params(co_table_suffix))) =
            t_params(co_table_suffix) THEN
            l_base_name := substr(l_object_name,
                                  1,
                                  length(l_object_name) -
                                  length(t_params(co_table_suffix)));
         ELSE
            l_base_name := l_object_name;
         END IF;
         RETURN l_base_name;
      END get_base_name;
      --
      FUNCTION get_name(in_suffix IN VARCHAR2) RETURN VARCHAR2 IS
         l_name oddgen_types.key_type;
      BEGIN
         l_name := get_base_name;
         IF length(l_name) + length(in_suffix) > co_max_obj_len THEN
            l_name := substr(l_name, 1, co_max_obj_len - length(in_suffix));
         END IF;
         l_name := l_name || in_suffix;
         RETURN l_name;
      END get_name;
      --
      FUNCTION get_view_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(t_params(co_view_suffix));
      END get_view_name;
      --
      FUNCTION get_iot_name RETURN VARCHAR2 IS
      BEGIN
         RETURN get_name(t_params(co_iot_suffix));
      END get_iot_name;
      --
      PROCEDURE check_params IS
         l_found  BOOLEAN;
         r_col    c_columns%ROWTYPE;
         r_pk_col c_pk_columns%ROWTYPE;
      BEGIN
         OPEN c_columns;
         FETCH c_columns
            INTO r_col;
         l_found := c_columns%FOUND;
         CLOSE c_columns;
         IF NOT l_found THEN
            raise_application_error(co_oddgen_error,
                                    'Table ' || l_object_name || ' not found.');
         END IF;
         IF get_view_name = l_object_name THEN
            raise_application_error(co_oddgen_error,
                                    'Change <' || co_view_suffix ||
                                    '>. The target view must be named differently than its base table.');
         END IF;
         IF t_params(co_gen_iot) NOT IN ('Yes', 'No') THEN
            raise_application_error(co_oddgen_error,
                                    'Invalid value <' || t_params(co_gen_iot) ||
                                    '> for parameter <' || co_gen_iot ||
                                    '>. Valid are Yes and No.');
         END IF;
         IF t_params(co_gen_iot) = 'Yes' THEN
            IF get_iot_name = get_view_name OR get_iot_name = l_object_name THEN
               raise_application_error(co_oddgen_error,
                                       'Change <' || co_iot_suffix ||
                                       '>. The target instead-of-trigger must be named differently than its base view and base table.');
            END IF;
            OPEN c_pk_columns;
            FETCH c_pk_columns
               INTO r_pk_col;
            l_found := c_pk_columns%FOUND;
            CLOSE c_pk_columns;
            IF NOT l_found THEN
               raise_application_error(co_oddgen_error,
                                       'No primary key found in table ' || l_object_name ||
                                       '. Cannot generate instead-of-trigger.');
            END IF;
         END IF;
      END check_params;
      --
      PROCEDURE init_params IS
         i oddgen_types.key_type;
      BEGIN
         t_params := get_default_params;
         IF in_node.params.count() > 0 THEN
            i := in_node.params.first();
            <<input_params>>
            WHILE (i IS NOT NULL)
            LOOP
               IF t_params.exists(i) THEN
                  t_params(i) := in_node.params(i);
                  i := in_node.params.next(i);
               ELSE
                  raise_application_error(co_oddgen_error,
                                          'Parameter <' || i || '> is not known.');
               END IF;
            END LOOP input_params;
         END IF;
         check_params;
      END init_params;
   BEGIN
      l_object_type := in_node.parent_id;
      l_object_name := regexp_substr(in_node.id, '[^\.]+', 1, 2);
      IF l_object_type = 'TABLE' THEN
         init_params;
         l_args   := NEW varchar2_nt(
                            l_object_type,
                            l_object_name,
                            get_view_name,
                            get_iot_name,
                            t_params(co_gen_iot)
                     );
         l_result := ftldb_api.process_to_clob(
                        in_templ_name => $$PLSQL_UNIT || '%generate_ftl',
                        in_templ_args => l_args
                     );
      ELSE
         raise_application_error(
            co_oddgen_error,
            '<' || l_object_type || '> is not a supported object type. Please use TABLE.'
         );
      END IF;
      RETURN l_result;
   END generate;

END ftldb_view;
/
