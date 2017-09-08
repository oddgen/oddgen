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
package org.oddgen.sqldev.dal.tests

import org.junit.AfterClass
import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import org.oddgen.sqldev.dal.DatabaseGeneratorDao

class BulkGenerateTest extends AbstractJdbcTest {

	@Test
	def generate() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY1"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE").filter[it.id == "TABLE.EMP" || it.id == "TABLE.DEPT"].toList.sortBy[it.id]
		val expected = '''
			TABLE.DEPT

			TABLE.EMP
		'''
		val result =  dbgen.bulkGenerate(dataSource.connection, nodes)
		Assert.assertEquals(expected, result)
	}

	@Test
	def generate_with_empty_sep() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY2"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE").filter[it.id == "TABLE.EMP" || it.id == "TABLE.DEPT"].toList.toList.sortBy[it.id]
		val expected = '''
			TABLE.DEPT
			TABLE.EMP
		'''
		val result =  dbgen.bulkGenerate(dataSource.connection, nodes)
		Assert.assertEquals(expected, result)
	}

	@Test
	def generate_with_empty_sep_prolog_epilog() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY3"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE").filter[it.id == "TABLE.EMP" || it.id == "TABLE.DEPT"].toList.toList.sortBy[it.id]
		val expected = '''
			TABLE.DEPT
			TABLE.EMP
		'''
		val result =  dbgen.bulkGenerate(dataSource.connection, nodes)
		Assert.assertEquals(expected, result)
	}

	@Test
	def generate_with_sep_prolog_epilog() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY4"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE").filter[it.id == "TABLE.EMP" || it.id == "TABLE.DEPT"].toList.toList.sortBy[it.id]
		val expected = '''
			-- 2 nodes in prolog.
			TABLE.DEPT
			
			-- (my separator)
			
			TABLE.EMP
			-- 2 nodes in epilog.
		'''
		val result =  dbgen.bulkGenerate(dataSource.connection, nodes)
		Assert.assertEquals(expected, result)
	}

	@Test
	def generate_with_params() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY5"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE").filter[it.id == "TABLE.EMP" || it.id == "TABLE.DEPT"].toList.toList.sortBy[it.id]
		val expected = '''
			-- 2 nodes in prolog.
			TABLE.DEPT - a 3
			TABLE.EMP - a 3
			-- 2 nodes in epilog.
		'''
		val result =  dbgen.bulkGenerate(dataSource.connection, nodes)
		Assert.assertEquals(expected, result)
	}

	@Test
	def generate_with_old_signature() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase && it.getMetaData.generatorName == "PLSQL_DUMMY6"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE").filter[it.id == "TABLE.EMP" || it.id == "TABLE.DEPT"].toList.toList.sortBy[it.id]
		val expected = '''
			-- 2 nodes in prolog.
			TABLE.DEPT - a 3
			TABLE.EMP - a 3
			-- 2 nodes in epilog.
		'''
		val result =  dbgen.bulkGenerate(dataSource.connection, nodes)
		Assert.assertEquals(expected, result)
	}

	@BeforeClass
	def static void setup() {
		createPlsqlDummy1
		createPlsqlDummy2
		createPlsqlDummy3
		createPlsqlDummy4
		createPlsqlDummy5
		createPlsqlDummy6
	}

	@AfterClass
	def static tearDown() {
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy1")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy2")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy3")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy4")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy5")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy6")
	}

	def static createPlsqlDummy1() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy1 IS
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;
			END plsql_dummy1;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy1 IS
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN in_node.id;
			   END;
			END plsql_dummy1;
		''')
	}

	def static createPlsqlDummy2() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy2 IS
			   FUNCTION generate_separator RETURN VARCHAR2;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;
			END plsql_dummy2;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy2 IS
			   FUNCTION generate_separator RETURN VARCHAR2 IS
			   BEGIN
			      RETURN NULL;
			   END;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN in_node.id;
			   END;
			END plsql_dummy2;
		''')
	}

	def static createPlsqlDummy3() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy3 IS
			   FUNCTION generate_separator RETURN VARCHAR2;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;
			END plsql_dummy3;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy3 IS
			   FUNCTION generate_separator RETURN VARCHAR2 IS
			   BEGIN
			      RETURN NULL;
			   END;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate_prolog;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate_epilog;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN in_node.id;
			   END;
			END plsql_dummy3;
		''')
	}

	def static createPlsqlDummy4() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy4 IS
			   FUNCTION generate_separator RETURN VARCHAR2;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;
			END plsql_dummy4;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy4 IS
			   FUNCTION generate_separator RETURN VARCHAR2 IS
			   BEGIN
			      RETURN chr(10) || '-- (my separator)' || chr(10) || chr(10);
			   END;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN '-- ' || in_nodes.count || ' nodes in prolog.' || chr(10);
			   END generate_prolog;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN '-- ' || in_nodes.count || ' nodes in epilog.' || chr(10);
			   END generate_epilog;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN in_node.id;
			   END;
			END plsql_dummy4;
		''')
	}

	def static createPlsqlDummy5() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy5 IS
			   FUNCTION get_nodes(
			   in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
			   ) RETURN oddgen_types.t_node_type;
			   FUNCTION generate_separator RETURN VARCHAR2;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;
			END plsql_dummy5;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy5 IS
			   FUNCTION get_nodes(
			      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
			   ) RETURN oddgen_types.t_node_type IS
			      t_nodes  oddgen_types.t_node_type;
			      t_params oddgen_types.t_param_type;
			      --
			      PROCEDURE add_node (
			         in_id          IN oddgen_types.key_type,
			         in_parent_id   IN oddgen_types.key_type,
			         in_leaf        IN BOOLEAN
			      ) IS
			         l_node oddgen_types.r_node_type;
			      BEGIN
			         l_node.id              := in_id;
			         l_node.parent_id       := in_parent_id;
			         l_node.params          := t_params;
			         l_node.leaf            := in_leaf;
			         l_node.generatable     := TRUE;
			         l_node.multiselectable := TRUE;
			         t_nodes.extend;
			         t_nodes(t_nodes.count) := l_node;         
			      END add_node;
			   BEGIN
			      t_nodes  := oddgen_types.t_node_type();
			      t_params('p1') := 'a';
			      t_params('p2') := 'b';
			      t_params('p3') := 'c';
			      IF in_parent_node_id IS NULL THEN
			         -- object types
			         add_node(
			            in_id        => 'TABLE',
			            in_parent_id => NULL,
			            in_leaf      => FALSE
			         );
			      ELSE
			         -- object names
			         <<nodes>>
			         FOR r IN (
			            SELECT object_name
			              FROM user_objects
			             WHERE object_type = in_parent_node_id
			               AND generated = 'N'
			         ) LOOP
			            add_node(
			               in_id        => in_parent_node_id || '.' || r.object_name,
			               in_parent_id => in_parent_node_id,
			               in_leaf      => TRUE
			            );
			         END LOOP nodes;
			      END IF;
			      RETURN t_nodes;
			   END get_nodes;
			   FUNCTION generate_separator RETURN VARCHAR2 IS
			   BEGIN
			      RETURN NULL;
			   END;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN '-- ' || in_nodes.count || ' nodes in prolog.' || chr(10);
			   END generate_prolog;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN '-- ' || in_nodes.count || ' nodes in epilog.' || chr(10);
			   END generate_epilog;
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN in_node.id || ' - ' || in_node.params('p1') || ' ' || in_node.params.count;
			   END;
			END plsql_dummy5;
		''')
	}

	def static createPlsqlDummy6() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy6 IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   SUBTYPE param_type IS VARCHAR2(60 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
			   FUNCTION get_nodes(
			   in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
			   ) RETURN oddgen_types.t_node_type;
			   FUNCTION generate_separator RETURN VARCHAR2;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB;
			   FUNCTION generate(
			      in_object_type IN VARCHAR2,
			   	  in_object_name IN VARCHAR2,
			   	  in_params      IN t_param
			   ) RETURN CLOB;
			END plsql_dummy6;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy6 IS
			   FUNCTION get_nodes(
			      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
			   ) RETURN oddgen_types.t_node_type IS
			      t_nodes  oddgen_types.t_node_type;
			      t_params oddgen_types.t_param_type;
			      --
			      PROCEDURE add_node (
			         in_id          IN oddgen_types.key_type,
			         in_parent_id   IN oddgen_types.key_type,
			         in_leaf        IN BOOLEAN
			      ) IS
			         l_node oddgen_types.r_node_type;
			      BEGIN
			         l_node.id              := in_id;
			         l_node.parent_id       := in_parent_id;
			         l_node.params          := t_params;
			         l_node.leaf            := in_leaf;
			         l_node.generatable     := TRUE;
			         l_node.multiselectable := TRUE;
			         t_nodes.extend;
			         t_nodes(t_nodes.count) := l_node;         
			      END add_node;
			   BEGIN
			      t_nodes  := oddgen_types.t_node_type();
			      t_params('p1') := 'a';
			      t_params('p2') := 'b';
			      t_params('p3') := 'c';
			      IF in_parent_node_id IS NULL THEN
			         -- object types
			         add_node(
			            in_id        => 'TABLE',
			            in_parent_id => NULL,
			            in_leaf      => FALSE
			         );
			      ELSE
			         -- object names
			         <<nodes>>
			         FOR r IN (
			            SELECT object_name
			              FROM user_objects
			             WHERE object_type = in_parent_node_id
			               AND generated = 'N'
			         ) LOOP
			            add_node(
			               in_id        => in_parent_node_id || '.' || r.object_name,
			               in_parent_id => in_parent_node_id,
			               in_leaf      => TRUE
			            );
			         END LOOP nodes;
			      END IF;
			      RETURN t_nodes;
			   END get_nodes;
			   FUNCTION generate_separator RETURN VARCHAR2 IS
			   BEGIN
			      RETURN NULL;
			   END;
			   FUNCTION generate_prolog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN '-- ' || in_nodes.count || ' nodes in prolog.' || chr(10);
			   END generate_prolog;
			   FUNCTION generate_epilog(
			      in_nodes IN oddgen_types.t_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN '-- ' || in_nodes.count || ' nodes in epilog.' || chr(10);
			   END generate_epilog;
			   FUNCTION generate(
			      in_object_type IN VARCHAR2,
			   	  in_object_name IN VARCHAR2,
			   	  in_params      IN t_param
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN in_object_type || '.' || in_object_name || ' - ' || in_params('p1') || ' ' || in_params.count;
			   END;
			END plsql_dummy6;
		''')
	}

}
