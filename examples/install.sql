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
PROMPT EMP/DEPT example tables used by emp_hier generator
PROMPT ====================================================================
CREATE TABLE dept (
   deptno   NUMBER(2)     CONSTRAINT pk_dept PRIMARY KEY,
   dname    VARCHAR2(14),
   loc      VARCHAR2(13) 
);
CREATE TABLE emp (
   empno    NUMBER(4)     CONSTRAINT pk_emp PRIMARY KEY,
   ename    VARCHAR2(10),
   job      VARCHAR2(9),
   mgr      NUMBER(4),
   hiredate DATE,
  sal      NUMBER(7,2),
   comm     NUMBER(7,2),
   deptno   NUMBER(2)     CONSTRAINT fk_deptno REFERENCES dept
);
INSERT INTO dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO dept VALUES (20, 'RESEARCH', 'DALLAS');
INSERT INTO dept VALUES (30, 'SALES', 'CHICAGO');
INSERT INTO dept VALUES (40, 'OPERATIONS', 'BOSTON');
INSERT INTO emp VALUES (7369, 'SMITH', 'CLERK', 7902, DATE '1980-12-17', 800, NULL, 20);
INSERT INTO emp VALUES (7499, 'ALLEN', 'SALESMAN', 7698, DATE '1981-02-20', 1600, 300, 30);
INSERT INTO emp VALUES (7521, 'WARD', 'SALESMAN', 7698, DATE '1981-02-22', 1250, 500, 30);
INSERT INTO emp VALUES (7566, 'JONES', 'MANAGER', 7839, DATE '1981-04-02', 2975, NULL, 20);
INSERT INTO emp VALUES (7654, 'MARTIN', 'SALESMAN', 7698, DATE '1981-09-28', 1250, 1400, 30);
INSERT INTO emp VALUES (7698, 'BLAKE', 'MANAGER', 7839, DATE '1981-05-01', 2850, NULL, 30);
INSERT INTO emp VALUES (7782, 'CLARK', 'MANAGER', 7839, DATE '1981-06-09', 2450, NULL, 10);
INSERT INTO emp VALUES (7788, 'SCOTT', 'ANALYST', 7566, DATE '1987-04-19', 3000, NULL, 20);
INSERT INTO emp VALUES (7839, 'KING', 'PRESIDENT', NULL, DATE '1981-11-17', 5000, NULL, 10);
INSERT INTO emp VALUES (7844, 'TURNER', 'SALESMAN', 7698, DATE '1981-09-08', 1500, 0, 30);
INSERT INTO emp VALUES (7876, 'ADAMS', 'CLERK', 7788, DATE '1987-05-23', 1100, NULL, 20);
INSERT INTO emp VALUES (7900, 'JAMES', 'CLERK', 7698, DATE '1981-12-03', 950, NULL, 30);
INSERT INTO emp VALUES (7902, 'FORD', 'ANALYST', 7566, DATE '1981-12-03', 3000, NULL, 20);
INSERT INTO emp VALUES (7934, 'MILLER', 'CLERK', 7782, DATE '1982-01-23', 1300, NULL, 10);
COMMIT;

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
@./package/oddgen_types.pks
SHOW ERRORS
@./package/plsql/plsql_hello_world.pks
SHOW ERRORS
@./package/plsql/plsql_view.pks
SHOW ERRORS
@./package/plsql/dropall.pks
SHOW ERRORS
@./package/plsql/emp_hier.pks
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
@./package/plsql/dropall.pkb
SHOW ERRORS
@./package/plsql/emp_hier.pkb
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
GRANT EXECUTE ON oddgen_types TO PUBLIC;
GRANT EXECUTE ON plsql_hello_world TO PUBLIC;
GRANT EXECUTE ON plsql_view TO PUBLIC;
GRANT EXECUTE ON dropall to PUBLIC;
GRANT EXECUTE ON ftldb_hello_world TO PUBLIC;
GRANT EXECUTE ON ftldb_view TO PUBLIC;
GRANT EXECUTE ON teplsql_hello_world TO PUBLIC;
GRANT EXECUTE ON teplsql_view TO PUBLIC;
GRANT EXECUTE ON teplsql2_hello_world TO PUBLIC;
GRANT EXECUTE ON teplsql2_view TO PUBLIC;

SPOOL OFF
