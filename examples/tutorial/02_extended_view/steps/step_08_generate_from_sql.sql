SET LONG 500
WITH 
   FUNCTION gen(
      in_object_type   IN VARCHAR2,
      in_object_name   IN VARCHAR2,
      in_select_star   IN VARCHAR2,
      in_view_suffix   IN VARCHAR2,
      in_order_columns IN VARCHAR2
   ) RETURN CLOB IS
      r_node oddgen_types.r_node_type;
   BEGIN
      r_node.id                       := in_object_type || '.' || in_object_name;
      r_node.parent_id                := in_object_type;
      r_node.params('Select * ?')     := in_select_star; 
      r_node.params('View suffix')    := in_view_suffix;
      r_node.params('Order columns?') := in_order_columns;
      RETURN extended_view.generate(in_node => r_node);
   END;
SELECT gen(object_type, object_name, 'No', '_view', 'Yes') AS result
  FROM user_objects
 WHERE object_type = 'TABLE'
   AND generated = 'N'
 ORDER BY object_name
/