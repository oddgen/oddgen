CREATE OR REPLACE PACKAGE minimal_view AS
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
   * generating a 1:1 view using just the mandatory generate function
   * see full tutorial on https://www.oddgen.org/tutorial-1/
   *
   * @headcom
   */

   /**
   * Generates the result (minimal 1:1 view)
   *
   * @param in_object_type object type to process
   * @param in_object_name object_name to process
   * @returns generator output
   */   
   FUNCTION generate (
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2
   ) RETURN CLOB;  
END minimal_view;
/
