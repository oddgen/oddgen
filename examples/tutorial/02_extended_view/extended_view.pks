CREATE OR REPLACE PACKAGE extended_view AUTHID CURRENT_USER AS
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

   /** 
   * oddgen PL/SQL database server generator example.
   * generating a 1:1 view using all oddgen PL/SQL interface functions.
   *
   * @headcom
   */

   --
   -- oddgen PL/SQL data types
   --
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
   TYPE t_string IS TABLE OF string_type;
   SUBTYPE param_type IS VARCHAR2(30 CHAR);
   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

   /**
   * Get the name of the generator, used in tree view, generator dialog window
   *
   * @returns name of the generator
   */
   FUNCTION get_name RETURN VARCHAR2;

   /**
   * Get the description of the generator, used in tree view (tooltip), generator dialog window
   * 
   * @returns description of the generator
   */
   FUNCTION get_description RETURN VARCHAR2;

   /**
   * Get the list of supported object types.
   *
   * @returns list of supported object types
   */
   FUNCTION get_object_types RETURN t_string;

   /**
   * Get all object names for a object type.
   *
   * @param in_object_type object type to filter objects
   * @returns list of object names
   */
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;
   
   /**
   * Get all parameters supported by the generator including default values.
   *
   * @returns list of parameters supported by the generator
   */
   FUNCTION get_params RETURN t_param;

   /**
   * Get the list of values per parameter.
   * Parameters with a list-of-value are shown as combo box
   * in the generator dialog.
   *
   * @returns parameters with their list-of-values
   */
   FUNCTION get_lov RETURN t_lov;
   
   /**
   * Updates the list of values per parameter.
   * This function is called after a parameter change in the GUI.
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name of in_object_type to process
   * @param in_params parameters to configure the behavior of the generator
   * @returns parameters with their list-of-values
   */
   FUNCTION refresh_lov(in_object_type IN VARCHAR2,
                        in_object_name IN VARCHAR2,
                        in_params      IN t_param) RETURN t_lov;

   /**
   * Generates the result.
   * Used by oddgen for SQL Developer.
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name of in_object_type to process
   * @param in_params parameters to configure the behavior of the generator
   * @returns extended 1:1 view
   */
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN t_param) RETURN CLOB;

   /**
   * Generates the result. 
   * Accessible from SQL.
   * Not used by oddgen for SQL Developer.
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name of in_object_type to process
   * @returns extended 1:1 view
   */
   FUNCTION generate(in_object_type   IN VARCHAR2,
                     in_object_name   IN VARCHAR2,
                     in_select_star   IN VARCHAR2 DEFAULT 'No',
                     in_view_suffix   IN VARCHAR2 DEFAULT '_v',
                     in_order_columns IN VARCHAR2 DEFAULT 'No') RETURN CLOB;
END extended_view;
/
