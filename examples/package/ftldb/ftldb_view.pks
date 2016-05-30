CREATE OR REPLACE PACKAGE ftldb_view IS
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

   /*
   * oddgen PL/SQL data types
   */
   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
   SUBTYPE param_type IS VARCHAR2(30 CHAR);
   TYPE t_string IS TABLE OF string_type;
   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
   TYPE t_lov IS TABLE OF t_string INDEX BY param_type;

   /**
   * Get name of the generator, used in tree view
   *
   * @returns name of the generator
   */
   FUNCTION get_name RETURN VARCHAR2;

   /**
   * Get a description of the generator.
   * 
   * @returns description of the generator
   */
   FUNCTION get_description RETURN VARCHAR2;

   /**
   * Get a list of supported object types.
   *
   * @returns a list of supported object types
   */
   FUNCTION get_object_types RETURN t_string;

   /**
   * Get a list of objects for a object type.
   *
   * @param in_object_type object type to filter objects
   * @returns a list of objects
   */
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;

   /**
   * Get all parameters supported by the generator including default values.
   *
   * @returns parameters supported by the generator
   */
   FUNCTION get_params RETURN t_param;
   
  /**
   * Get all parameter names in the order to be displayed in the 
   * generate dialog.
   *
   * @returns ordered parameter names
   */
   FUNCTION get_ordered_params RETURN t_string;  

   /**
   * Get a list of values per parameter, if such a LOV is applicable.
   *
   * @returns parameters with their list-of-values
   */
   FUNCTION get_lov RETURN t_lov;

   /**
   * Enables/disables co_iot_suffix based on co_gen_iot
   *
   * @param in_object_type object type to configure the behavior of the generator
   * @param in_object_name object_name to configure the behavior of the generator
   * @param in_params parameters to configure the behavior of the generator
   * @returns parameters with their editable state ("0"=disabled, "1"=enabled)
   *
   * @since v0.2
   */
   FUNCTION refresh_param_states(in_object_type IN VARCHAR2,
                                 in_object_name IN VARCHAR2,
                                 in_params      IN t_param) RETURN t_param;

   /**
   * Generates the result.
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
   FUNCTION generate(in_object_type IN VARCHAR2, in_object_name IN VARCHAR2) RETURN CLOB;
END ftldb_view;
/
