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

SET DEFINE OFF
SET SCAN OFF
SET ECHO OFF
SPOOL create_user_oddgen.log

PROMPT ====================================================================
PROMPT This script creates the user ODDGEN with all required privileges. 
PROMPT Run this script as SYS.
PROMPT Please change default tablespace and password.
PROMPT Please change schema name for FTLDB and tePLSQL.
PROMPT ====================================================================

PROMPT ====================================================================
PROMPT User
PROMPT ====================================================================
CREATE USER oddgen IDENTIFIED BY oddgen
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON users;
  
PROMPT ====================================================================
PROMPT Common grants
PROMPT ====================================================================
GRANT CONNECT, RESOURCE to oddgen;
GRANT SELECT_CATALOG_ROLE, SELECT ANY DICTIONARY to oddgen;
GRANT CREATE SYNONYM TO oddgen;
GRANT SELECT ON dba_objects TO oddgen;
GRANT SELECT ON dba_constraints TO oddgen;
GRANT SELECT ON dba_tables TO oddgen;

PROMPT ====================================================================
PROMPT Grants required for FTLDB
PROMPT   to install FLTDB run the following scripts
PROMPT      1. dba_install 
PROMPT      2. dba_switch_java_permissions (grant public)
PROMPT      3. dba_switch_plsql_privileges (grant public)
PROMPT   see https://github.com/ftldb/ftldb/blob/master/README.md
PROMPT ====================================================================
GRANT SELECT ANY TABLE TO ftldb;
GRANT EXECUTE ON ftldb.varchar2_nt TO oddgen;
GRANT EXECUTE ON ftldb.ftldb_api TO oddgen;

PROMPT ====================================================================
PROMPT Grants required for tePLSQL
PROMPT   to install tePLSQL you need to deploy the following files
PROMPT      1. TE_TEMPLATES.sql
PROMPT      2. tePLSQL.pks
PROMPT      3. tePLSQL.pkb
PROMPT   see https://github.com/osalvador/tePLSQL/blob/master/README.md
PROMPT ====================================================================
GRANT EXECUTE ON teplsql.teplsql TO oddgen;

PROMPT ====================================================================
PROMPT Grants on Oracle 12c
PROMPT   required for invoker rights database server generators only
PROMPT ====================================================================
PROMPT 
GRANT INHERIT PRIVILEGES ON USER oddgen TO PUBLIC;

SPOOL OFF
