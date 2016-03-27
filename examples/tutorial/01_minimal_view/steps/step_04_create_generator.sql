CREATE OR REPLACE PACKAGE minimal_view AS
   FUNCTION generate (
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB;  
END minimal_view;
/

CREATE OR REPLACE PACKAGE BODY minimal_view AS
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
