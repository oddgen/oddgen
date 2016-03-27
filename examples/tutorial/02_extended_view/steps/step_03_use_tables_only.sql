CREATE OR REPLACE PACKAGE extended_view AUTHID CURRENT_USER AS
   -- oddgen PL/SQL data types
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
   TYPE t_string IS TABLE OF string_type;

   FUNCTION get_name RETURN VARCHAR2;

   FUNCTION get_description RETURN VARCHAR2;

   FUNCTION get_object_types RETURN t_string;

   FUNCTION generate (
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB;
END extended_view;
/

CREATE OR REPLACE PACKAGE BODY extended_view AS
   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Extended 1:1 View Generator';
   END get_name;

   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Generates a 1:1 view based on an existing ' || 
         'table and various generator parameters.';
   END get_description;

   FUNCTION get_object_types RETURN t_string IS
   BEGIN
      RETURN NEW t_string('TABLE');
   END get_object_types;

   FUNCTION generate (
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB IS
      l_templ        CLOB := 
'CREATE OR REPLACE VIEW ${view_name} AS
   SELECT ${column_names}
     FROM ${table_name};';
      l_clob         CLOB;
      l_view_name    string_type;
      l_column_names string_type;
      l_table_name   string_type;
   BEGIN
      -- prepare placeholders
      l_column_names := '*';
      l_table_name := lower(in_object_name);
      l_view_name := l_table_name || '_v';
      -- produce final clob, replace placeholder in template
      l_clob := REPLACE(l_templ, '${column_names}', l_column_names);
      l_clob := REPLACE(l_clob, '${view_name}', l_view_name);
      l_clob := REPLACE(l_clob, '${table_name}', l_table_name);
      RETURN l_clob;
   END generate;
END extended_view;
/