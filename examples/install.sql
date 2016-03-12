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
SPOOL install.log

PROMPT ====================================================================
PROMPT This script installs PL/SQL based oddgen example generators which
PROMPT are automatically recognized by the oddgen SQL Developer extension.
PROMPT
PROMPT Please install FTLDB and tePLSQL to ensure that all examples compile
PROMPT successfully. Otherwise just the plain PL/SQL examples will work.
PROMPT
PROMPT Connect to the target user (schema) of your choice.
PROMPT See ./user/create_user_oddgen.sql for required privileges.
PROMPT ====================================================================

PROMPT ====================================================================
PROMPT Private synonyms for FTLDB
PROMPT ====================================================================
PROMPT 
CREATE OR REPLACE SYNONYM varchar2_nt FOR ftldb.varchar2_nt;
CREATE OR REPLACE SYNONYM ftldb_api FOR ftldb.ftldb_api;

PROMPT ====================================================================
PROMPT Private synonyms for tePLSQL
PROMPT ====================================================================
PROMPT 
CREATE OR REPLACE SYNONYM teplsql FOR teplsql.teplsql;

PROMPT ====================================================================
PROMPT Package specifications
PROMPT ====================================================================
@./package/plsql/plsql_hello_world.pks
SHOW ERRORS
@./package/plsql/plsql_view.pks
SHOW ERRORS
@./package/ftldb/ftldb_hello_world.pks
SHOW ERRORS
@./package/ftldb/ftldb_view.pks
SHOW ERRORS
@./package/teplsql/teplsql_hello_world.pks
SHOW ERRORS
@./package/teplsql/teplsql_view.pks
SHOW ERRORS
@./package/teplsql2/teplsql2_hello_world.pks
SHOW ERRORS
@./package/teplsql2/teplsql2_view.pks
SHOW ERRORS

PROMPT ====================================================================
PROMPT Package bodies
PROMPT ====================================================================
@./package/plsql/plsql_hello_world.pkb
SHOW ERRORS
@./package/plsql/plsql_view.pkb
SHOW ERRORS
@./package/ftldb/ftldb_hello_world.pkb
SHOW ERRORS
@./package/ftldb/ftldb_view.pkb
SHOW ERRORS
@./package/teplsql/teplsql_hello_world.pkb
SHOW ERRORS
@./package/teplsql/teplsql_view.pkb
SHOW ERRORS
@./package/teplsql2/teplsql2_hello_world.pkb
SHOW ERRORS
@./package/teplsql2/teplsql2_view.pkb
SHOW ERRORS

PROMPT ====================================================================
PROMPT Grants
PROMPT SQL Developer extension scans instance for oddgen generators and
PROMPT knows about the owning schema. Therefore no public synonyms need to
PROMPT be created.
PROMPT ====================================================================
GRANT EXECUTE ON plsql_hello_world TO PUBLIC;
GRANT EXECUTE ON plsql_view TO PUBLIC;
GRANT EXECUTE ON ftldb_hello_world TO PUBLIC;
GRANT EXECUTE ON ftldb_view TO PUBLIC;
GRANT EXECUTE ON teplsql_hello_world TO PUBLIC;
GRANT EXECUTE ON teplsql_view TO PUBLIC;
GRANT EXECUTE ON teplsql2_hello_world TO PUBLIC;
GRANT EXECUTE ON teplsql2_view TO PUBLIC;

SPOOL OFF
