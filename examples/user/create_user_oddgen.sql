/*
* Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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

SET DEFINE OFF
SET SCAN OFF
SET ECHO OFF
SPOOL create_user_oddgen.log

PROMPT ====================================================================
PROMPT This script installs creates the user ODDGEN with all required
PROMPT privileges. 
PROMPT Run this script as SYS.
PROMPT Please change default tablespace and password.
PROMPT Please change schema name for FTLDB and tePLSQL as well.
PROMPT ====================================================================

PROMPT ====================================================================
PROMPT User
PROMPT ====================================================================
CREATE USER oddgen IDENTIFIED BY oddgen
  DEFAULT TABLESPACE system
  TEMPORARY TABLESPACE TEMP;
  
PROMPT ====================================================================
PROMPT Grants
PROMPT ====================================================================
GRANT CONNECT, RESOURCE to oddgen;
GRANT SELECT_CATALOG_ROLE, SELECT ANY DICTIONARY to oddgen;
GRANT CREATE SYNONYM TO oddgen;
GRANT SELECT ON dba_objects TO oddgen;
GRANT SELECT ON dba_constraints TO oddgen;
GRANT SELECT ON dba_tables TO oddgen;
GRANT SELECT ANY TABLE TO ftldb;

PROMPT ====================================================================
PROMPT Grants for tePLSQL (requires teplsql and Oracle 12c)
PROMPT ====================================================================
PROMPT 
PROMPT GRANT select_catalog_role TO PACKAGE teplsql.teplsql;

SPOOL OFF
