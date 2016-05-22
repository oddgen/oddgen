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

-- 1:1 from https://livesql.oracle.com/apex/livesql/file/content_DBEO1MIGH5ZQOILUVV85I1UQC.html
CREATE OR REPLACE PROCEDURE gen_table_ddl ( 
   entity_in     IN VARCHAR2, 
   entities_in   IN VARCHAR2 DEFAULT NULL, 
   add_fky_in    IN BOOLEAN DEFAULT TRUE, 
   prefix_in     IN VARCHAR2 DEFAULT NULL, 
   in_apex_in    IN BOOLEAN DEFAULT FALSE) 
IS 
   c_table_name    CONSTANT VARCHAR2 (100) 
      := prefix_in || NVL (entities_in, entity_in || 's') ; 
 
   c_pkycol_name   CONSTANT VARCHAR2 (100) := entity_in || '_ID'; 
 
   c_user_code     CONSTANT VARCHAR2 (100) 
      := CASE 
            WHEN in_apex_in THEN 'NVL (v (''APP_USER''), USER)' 
            ELSE 'USER' 
         END ; 
 
   PROCEDURE pl (str_in                   IN VARCHAR2, 
                 indent_in                IN INTEGER DEFAULT 3, 
                 num_newlines_before_in   IN INTEGER DEFAULT 0) 
   IS 
   BEGIN 
      FOR indx IN 1 .. num_newlines_before_in 
      LOOP 
         DBMS_OUTPUT.put_line (''); 
      END LOOP; 
 
      DBMS_OUTPUT.put_line (LPAD (' ', indent_in) || str_in); 
   END; 
BEGIN 
   pl ('CREATE TABLE ' || c_table_name || '(', 0); 
   pl (c_pkycol_name || ' INTEGER NOT NULL,'); 
   pl ('created_by VARCHAR2 (132 BYTE) NOT NULL,'); 
   pl ('changed_by VARCHAR2 (132 BYTE) NOT NULL,'); 
   pl ('created_on DATE NOT NULL,'); 
   pl ('changed_on DATE NOT NULL'); 
   pl (');'); 
 
   pl ('CREATE SEQUENCE ' || c_table_name || '_SEQ;', 0, 1); 
   pl ( 
         'CREATE UNIQUE INDEX ' 
      || c_table_name 
      || ' ON ' 
      || c_table_name 
      || '(' 
      || c_pkycol_name 
      || ');', 
      0, 
      1); 
   pl ( 
         'CREATE OR REPLACE TRIGGER ' 
      || c_table_name 
      || '_bir  
      BEFORE INSERT ON ' 
      || c_table_name, 
      0, 
      1); 
   pl ('FOR EACH ROW DECLARE', 3); 
   pl ('BEGIN', 3); 
   pl ('IF :new.' || c_pkycol_name || ' IS NULL', 6); 
   pl ( 
         'THEN :new.' 
      || c_pkycol_name 
      || ' := ' 
      || c_table_name 
      || '_seq.NEXTVAL; END IF;', 
      6); 
 
   pl (':new.created_on := SYSDATE;', 6); 
   pl (':new.created_by := ' || c_user_code || ';', 6); 
   pl (':new.changed_on := SYSDATE;', 6); 
   pl (':new.changed_by := ' || c_user_code || ';', 6); 
   pl ('END ' || c_table_name || '_bir;', 3); 
 
   pl ('CREATE OR REPLACE TRIGGER ' || c_table_name || '_bur', 0, 1); 
   pl ('BEFORE UPDATE ON ' || c_table_name || ' FOR EACH ROW', 3); 
   pl ('DECLARE', 3); 
   pl ('BEGIN', 3); 
   pl (':new.changed_on := SYSDATE;', 6); 
   pl (':new.changed_by := ' || c_user_code || ';', 6); 
   pl ('END ' || c_table_name || '_bur;', 3); 
 
   pl ('ALTER TABLE ' || c_table_name || ' ADD  
      (CONSTRAINT ' || c_table_name, 
       0, 
       1); 
   pl ( 
         'PRIMARY KEY (' 
      || c_pkycol_name 
      || ')  
       USING INDEX ' 
      || c_table_name 
      || ' ENABLE VALIDATE);', 
      3); 
 
   IF add_fky_in 
   THEN 
      pl ( 
            'ALTER TABLE ' 
         || c_table_name 
         || ' ADD (CONSTRAINT fk_' 
         || c_table_name, 
         0, 
         1); 
      pl ('FOREIGN KEY (REPLACE_id)  
     REFERENCES qdb_REPLACE (REPLACE_id)', 3); 
      pl ('ON DELETE CASCADE ENABLE VALIDATE);', 3); 
   END IF; 
END;
/

CREATE OR REPLACE PACKAGE gen_table_ddl_oddgen_wrapper IS
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
   SUBTYPE param_type IS VARCHAR2(60 CHAR);
   TYPE t_string IS TABLE OF string_type;
   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

   FUNCTION get_name RETURN VARCHAR2;

   FUNCTION get_description RETURN VARCHAR2;

   FUNCTION get_object_types RETURN t_string;

   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;

   FUNCTION get_params RETURN t_param;

   FUNCTION get_ordered_params RETURN t_string;

   FUNCTION get_lov RETURN t_lov;

   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN t_param) RETURN CLOB;
END gen_table_ddl_oddgen_wrapper;
/

CREATE OR REPLACE PACKAGE BODY gen_table_ddl_oddgen_wrapper IS
   co_entity   CONSTANT param_type := 'Entity name (singular, for PK column)';
   co_entities CONSTANT param_type := 'Entity name (plural, for object names)';
   co_add_fky  CONSTANT param_type := 'Add foreign key?';
   co_prefix   CONSTANT param_type := 'Object prefix';
   co_in_apex  CONSTANT param_type := 'Data populated through APEX?';

   FUNCTION get_name RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Table DDL snippet';
   END get_name;

   FUNCTION get_description RETURN VARCHAR2 IS
   BEGIN
      RETURN 'Steven Feuerstein''s starting point, from which he adds entity-specific columns, additional foreign keys, etc.';
   END get_description;

   FUNCTION get_object_types RETURN t_string IS
   BEGIN
      RETURN NEW t_string('TABLE');
   END get_object_types;

   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string IS
   BEGIN
      RETURN NEW t_string('Snippet');
   END get_object_names;

   FUNCTION get_params RETURN t_param IS
      l_params t_param;
   BEGIN
      l_params(co_entity) := 'employee';
      l_params(co_entities) := NULL;
      l_params(co_add_fky) := 'Yes';
      l_params(co_prefix) := NULL;
      l_params(co_in_apex) := 'No';
      RETURN l_params;
   END get_params;

   FUNCTION get_ordered_params RETURN t_string IS
   BEGIN
      RETURN NEW t_string(co_entity, co_entities, co_add_fky, co_prefix);
   END get_ordered_params;

   FUNCTION get_lov RETURN t_lov IS
      l_lov t_lov;
   BEGIN
      l_lov(co_add_fky) := NEW t_string('Yes', 'No');
      l_lov(co_in_apex) := NEW t_string('Yes', 'No');
      RETURN l_lov;
   END get_lov;

   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN t_param) RETURN CLOB IS
      l_lines    sys.dbms_output.chararr;
      l_numlines INTEGER := 10; -- buffer size
      l_result   CLOB;
   
      PROCEDURE enable_output IS
      BEGIN
         sys.dbms_output.enable(buffer_size => NULL); -- unlimited size
      END enable_output;
   
      PROCEDURE disable_output IS
      BEGIN
         sys.dbms_output.disable;
      END disable_output;
   
      PROCEDURE call_generator IS
      BEGIN
         gen_table_ddl(entity_in   => in_params(co_entity),
                       entities_in => in_params(co_entities),
                       add_fky_in  => CASE
                                         WHEN in_params(co_add_fky) = 'Yes' THEN
                                          TRUE
                                         ELSE
                                          FALSE
                                      END,
                       prefix_in   => in_params(co_prefix),
                       in_apex_in  => CASE
                                         WHEN in_params(co_in_apex) = 'Yes' THEN
                                          TRUE
                                         ELSE
                                          FALSE
                                      END);
      END call_generator;
   
      PROCEDURE copy_dbms_output_to_result IS
      BEGIN
         sys.dbms_lob.createtemporary(l_result, TRUE);
         <<read_dbms_output_into_buffer>>
         WHILE l_numlines > 0
         LOOP
            sys.dbms_output.get_lines(l_lines, l_numlines);
            <<copy_buffer_to_clob>>
            FOR i IN 1 .. l_numlines
            LOOP
               sys.dbms_lob.append(l_result, l_lines(i) || chr(10));
            END LOOP copy_buffer_to_clob;
         END LOOP read_dbms_output_into_buffer;
      END copy_dbms_output_to_result;
   BEGIN
      enable_output;
      call_generator;
      copy_dbms_output_to_result;
      disable_output;
      RETURN l_result;
   END generate;
END gen_table_ddl_oddgen_wrapper;
/

GRANT EXECUTE ON gen_table_ddl_oddgen_wrapper TO PUBLIC;
