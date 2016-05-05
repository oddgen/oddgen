-- see https://livesql.oracle.com/apex/livesql/file/content_C73WCRT0FK21A78LLMZJSDW2J.html
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

