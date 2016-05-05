CREATE OR REPLACE PACKAGE plsql_view AUTHID CURRENT_USER IS
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
   * oddgen PL/SQL example to generate a 1:1 view based on an existing table.
   *
   * @headcom
   */

   --
   -- oddgen PL/SQL data types
   --
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
   SUBTYPE param_type IS VARCHAR2(30 CHAR);
   TYPE t_string IS TABLE OF string_type;
   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

   /**
   * Get name of the generator, used in tree view
   * If this function is not implemented, the package name will be used.
   *
   * @returns name of the generator
   */
   FUNCTION get_name RETURN VARCHAR2;

   /**
   * Get a description of the generator.
   * If this function is not implemented, the owner and the package name will be used.
   * 
   * @returns description of the generator
   */
   FUNCTION get_description RETURN VARCHAR2;

   /**
   * Get a list of supported object types.
   * If this function is not implemented, [TABLE, VIEW] will be used. 
   *
   * @returns a list of supported object types
   */
   FUNCTION get_object_types RETURN t_string;

   /**
   * Get a list of objects for a object type.
   * If this function is not implemented, the result of the following query will be used:
   * "SELECT object_name FROM user_objects WHERE object_type = in_object_type"
   *
   * @param in_object_type object type to filter objects
   * @returns a list of objects
   */
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;

   /**
   * Get all parameters supported by the generator including default values.
   * If this function is not implemented, no parameters will be used.
   *
   * @returns parameters supported by the generator
   */
   FUNCTION get_params RETURN t_param;

   /**
   * Get a list of values per parameter, if such a LOV is applicable.
   * If this function is not implemented, then the parameters cannot be validated in the GUI.
   *
   * @returns parameters with their list-of-values
   */
   FUNCTION get_lov RETURN t_lov;
 
   /**
   * Generates the result.
   * This function cannot be omitted. 
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name of in_object_type to process
   * @param in_params parameters to configure the behavior of the generator
   * @returns generator output
   * @throws ORA-20501 when parameter validation fails
   */
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2,
                     in_params      IN t_param) RETURN CLOB;

   /**
   * Alternative, simplified version of the generator, which is applicable in SQL.
   * Default values according get_params are used for in_params.
   * This function is implemented for convenience purposes only.
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name of in_object_type to process
   * @returns generator output
   * @throws ORA-20501 when parameter validation fails
   */
   FUNCTION generate(in_object_type IN VARCHAR2,
                     in_object_name IN VARCHAR2) RETURN CLOB;
END plsql_view;
/
