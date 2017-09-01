CREATE OR REPLACE PACKAGE oddgen_types AUTHID CURRENT_USER IS
   /*
   * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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
   * oddgen data types for PL/SQL database server generator.
   * This package must be installed in the same schema as the generators.
   * The user executing the generator must have execute privileges for this package.
   *
   * @headcom
   */

   /**
   * Keys, generic string values
   *
   * @since v0.3
   */
   SUBTYPE key_type    IS VARCHAR2(32767 BYTE);

   /**
   * Values, typically short strings, but may contain larger values, e.g. for JSON content or similar.
   *
   * @since v0.3
   */
   SUBTYPE value_type  IS CLOB;

   /**
   * Value array.
   *
   * @since v0.3
   */
   TYPE t_value_type   IS TABLE OF value_type;

   /**
   * Associative array of parameters (key-value pairs).
   *
   * @since v0.3
   */
   TYPE t_param_type   IS TABLE OF value_type INDEX BY key_type;

   /**
   * Associative array of list-of-values (key-value pairs, but a value is a value array).
   *
   * @since v0.3
   */
   TYPE t_lov_type     IS TABLE OF t_value_type INDEX BY key_type;

   /**
   * Record type to represent a node in the SQL Developer navigator tree.
   * Icon is evaluated as follows:
   *    a) by icon_name, if defined
   *    b) by icon_base64, if defined
   *    c) by parent_id, if leaf node and parent_id is a known object type (normal icon)
   *    d) by id, if non-leaf node and id is a known object type (folder icon)
   *    e) UNKNOWN_ICON, if leaf node
   *    f) UNKNOWN_FOLDER_ICON, if non-leaf node
   *
   * @since v0.3
   */
   TYPE r_node_type    IS RECORD (
      id               key_type,     -- node identifier, case-sensitive, e.g. EMP
      parent_id        key_type,     -- parent node identifier, NULL for root nodes, e.g. TABLE
      name             key_type,     -- name of the node, e.g. Emp
      description      key_type,     -- description of the node, e.g. Table Emp
      icon_name        key_type,     -- existing icon name, e.g. TABLE_ICON, VIEW_ICON
      icon_base64      key_type,     -- Base64 encoded icon, size 16x16 pixels
      params           t_param_type, -- array of parameters, e.g. View suffix=_V, Instead-of-trigger suffix=_TRG
      leaf             BOOLEAN,      -- Is this a leaf node? true|false, default false
      generatable      BOOLEAN,      -- Is the node with all its children generatable? true|false, default leaf
      multiselectable  BOOLEAN,      -- May this node be part of a multiselection? true|false, default leaf
      relevant         BOOLEAN       -- Pass node to the generator? true|false, default leaf
   );

   /**
   * Array of nodes, typically containing relevant nodes only.
   *
   * @since v0.3
   */
   TYPE t_node_type    IS TABLE OF r_node_type;

END oddgen_types;
/
