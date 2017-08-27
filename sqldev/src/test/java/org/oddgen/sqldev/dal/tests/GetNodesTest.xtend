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
import org.oddgen.sqldev.generators.model.NodeTools

class GetNodesTest extends AbstractJdbcTest {
	val extension NodeTools nodeTools = new NodeTools

	@Test
	def getNodes1() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY1"
		]
		val nodes = dbgen.getNodes(dataSource.connection, null)
		Assert.assertEquals(2, nodes.size)
		val code = nodes.get(0)
		Assert.assertEquals("", code.parentId)
		Assert.assertEquals("CODE", code.id)
		Assert.assertEquals("Code", code.name)
		Assert.assertEquals("", code.description)
		Assert.assertEquals("", code.iconName)
		Assert.assertTrue(code.iconBase64.length > 100)
		Assert.assertEquals(2, code.params.size)
		Assert.assertEquals(#["Object group", "Purge?"], code.params.keySet.toList)
		Assert.assertEquals(#["CODE", "No"], code.params.values.toList)
		Assert.assertEquals(false, code.leaf)
		Assert.assertEquals(false, code.isGeneratable)
		Assert.assertEquals(false, code.isMultiselectable)
		val data = nodes.get(1)
		Assert.assertEquals("", data.parentId)
		Assert.assertEquals("DATA", data.id)
		Assert.assertEquals("Data", data.name)
		Assert.assertEquals("", data.description)
		Assert.assertEquals("DATA_FOLDER_ICON", data.iconName)
		Assert.assertEquals("", data.iconBase64)
		Assert.assertEquals(2, data.params.size)
		Assert.assertEquals(#["Object group", "Purge?"], data.params.keySet.toList)
		Assert.assertEquals(#["DATA", "No"], data.params.values.toList)
		Assert.assertEquals(false, data.leaf)
		Assert.assertEquals(false, data.isGeneratable)
		Assert.assertEquals(false, data.isMultiselectable)
	}

	@Test
	def getNodes2() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY1"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "DATA.TABLE")
		Assert.assertEquals(4, nodes.size)
		val bonus = nodes.get(0)
		Assert.assertEquals("DATA.TABLE", bonus.parentId)
		Assert.assertEquals("DATA.TABLE.BONUS", bonus.id)
		Assert.assertEquals("Bonus", bonus.name)
		Assert.assertEquals("", bonus.description)
		Assert.assertEquals("", bonus.iconName)
		Assert.assertEquals("", bonus.iconBase64)
		Assert.assertEquals(4, bonus.params.size)
		Assert.assertEquals(#["Object group", "Object name", "Object type", "Purge?"], bonus.params.keySet.toList)
		Assert.assertEquals(#["DATA", "BONUS", "TABLE", "No"], bonus.params.values.toList)
		Assert.assertEquals(true, bonus.leaf)
		Assert.assertEquals(true, bonus.isGeneratable)
		Assert.assertEquals(true, bonus.isMultiselectable)
	}

	@Test
	def getNodes3() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY2"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "")
		Assert.assertEquals(2, nodes.size)
		val table = nodes.get(0)
		Assert.assertEquals("TABLE", table.id)
		Assert.assertEquals("", table.parentId)
		Assert.assertEquals(null, table.name)
		Assert.assertEquals(null, table.description)
		Assert.assertEquals(null, table.iconName)
		Assert.assertEquals(null, table.iconBase64)
		Assert.assertEquals(0, table.params.size)
		Assert.assertEquals(false, table.leaf)
		Assert.assertEquals(false, table.isGeneratable)
		Assert.assertEquals(false, table.isMultiselectable)
		Assert.assertEquals(false, table.isRelevant)
		val view = nodes.get(1)
		Assert.assertEquals("VIEW", view.id)
		Assert.assertEquals("", view.parentId)
		Assert.assertEquals(null, view.name)
		Assert.assertEquals(null, view.description)
		Assert.assertEquals(null, view.iconName)
		Assert.assertEquals(null, view.iconBase64)
		Assert.assertEquals(0, view.params.size)
		Assert.assertEquals(false, view.leaf)
		Assert.assertEquals(false, view.isGeneratable)
		Assert.assertEquals(false, view.isMultiselectable)
		Assert.assertEquals(false, view.isGeneratable)
		Assert.assertEquals(false, view.isRelevant)
	}

	@Test
	def getNodes4() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY2"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE")
		Assert.assertEquals(4, nodes.size)
		val bonus = nodes.get(0)
		Assert.assertEquals("TABLE", bonus.parentId)
		Assert.assertEquals("TABLE.BONUS", bonus.id)
		Assert.assertEquals(null, bonus.name)
		Assert.assertEquals(null, bonus.description)
		Assert.assertEquals(null, bonus.iconName)
		Assert.assertEquals(null, bonus.iconBase64)
		Assert.assertEquals(0, bonus.params.size)
		Assert.assertEquals(true, bonus.leaf)
		Assert.assertEquals(true, bonus.isGeneratable)
		Assert.assertEquals(true, bonus.isMultiselectable)
		Assert.assertEquals(true, bonus.isRelevant)
	}

	@Test
	def getNodes5() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY3"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "")
		Assert.assertEquals(1, nodes.size)
		val table = nodes.get(0)
		Assert.assertEquals("TABLE", table.id)
		Assert.assertEquals("", table.parentId)
		Assert.assertEquals(null, table.name)
		Assert.assertEquals(null, table.description)
		Assert.assertEquals(null, table.iconName)
		Assert.assertEquals(null, table.iconBase64)
		Assert.assertEquals(0, table.params.size)
		Assert.assertEquals(false, table.leaf)
		Assert.assertEquals(false, table.isGeneratable)
		Assert.assertEquals(false, table.isMultiselectable)
		Assert.assertEquals(false, table.isRelevant)
	}

	@Test
	def getNodes6() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY3"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE")
		Assert.assertEquals(4, nodes.size)
		val bonus = nodes.get(0)
		Assert.assertEquals("TABLE", bonus.parentId)
		Assert.assertEquals("TABLE.BONUS", bonus.id)
		Assert.assertEquals(null, bonus.name)
		Assert.assertEquals(null, bonus.description)
		Assert.assertEquals(null, bonus.iconName)
		Assert.assertEquals(null, bonus.iconBase64)
		Assert.assertEquals(0, bonus.params.size)
		Assert.assertEquals(true, bonus.leaf)
		Assert.assertEquals(true, bonus.isGeneratable)
		Assert.assertEquals(true, bonus.isMultiselectable)
		Assert.assertEquals(true, bonus.isRelevant)
	}

	@Test
	def getNodes7() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY4"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "")
		Assert.assertEquals(1, nodes.size)
		val table = nodes.get(0)
		Assert.assertEquals("TABLE", table.id)
		Assert.assertEquals("", table.parentId)
		Assert.assertEquals(null, table.name)
		Assert.assertEquals(null, table.description)
		Assert.assertEquals(null, table.iconName)
		Assert.assertEquals(null, table.iconBase64)
		Assert.assertEquals(0, table.params.size)
		Assert.assertEquals(false, table.leaf)
		Assert.assertEquals(false, table.isGeneratable)
		Assert.assertEquals(false, table.isMultiselectable)
		Assert.assertEquals(false, table.isRelevant)
	}

	@Test
	def getNodes8() {
		val dao = new DatabaseGeneratorDao(dataSource.connection)
		val dbgen = dao.findAll.findFirst [
			it.getMetaData.generatorOwner == dataSource.username.toUpperCase &&
				it.getMetaData.generatorName == "PLSQL_DUMMY4"
		]
		val nodes = dbgen.getNodes(dataSource.connection, "TABLE")
		Assert.assertEquals(4, nodes.size)
		val bonus = nodes.get(0)
		Assert.assertEquals("TABLE", bonus.parentId)
		Assert.assertEquals("TABLE.Bonus", bonus.id)
		Assert.assertEquals(null, bonus.name)
		Assert.assertEquals(null, bonus.description)
		Assert.assertEquals(null, bonus.iconName)
		Assert.assertEquals(null, bonus.iconBase64)
		Assert.assertEquals(0, bonus.params.size)
		Assert.assertEquals(true, bonus.leaf)
		Assert.assertEquals(true, bonus.isGeneratable)
		Assert.assertEquals(true, bonus.isMultiselectable)
		Assert.assertEquals(true, bonus.isRelevant)
	}

	@BeforeClass
	def static void setup() {
		createPlsqlDummy1
		createPlsqlDummy2
		createPlsqlDummy3
		createPlsqlDummy4
	}

	@AfterClass
	def static tearDown() {
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy1")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy2")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy3")
		jdbcTemplate.execute("DROP PACKAGE plsql_dummy4")
	}

	def static createPlsqlDummy1() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy1 AUTHID CURRENT_USER IS
			   FUNCTION get_object_group(
			      in_object_type IN VARCHAR2
			   ) RETURN VARCHAR2;
			
			   FUNCTION get_nodes(
			   in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
			   ) RETURN oddgen_types.t_node_type;
			
			   FUNCTION generate(
			   in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;
			   
			END plsql_dummy1;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy1 IS
			   --
			   -- private constants
			   --
			   co_new_line     CONSTANT oddgen_types.key_type := chr(10);
			   co_object_group CONSTANT oddgen_types.key_type := 'Object group';
			   co_object_type  CONSTANT oddgen_types.key_type := 'Object type';
			   co_object_name  CONSTANT oddgen_types.key_type := 'Object name';
			   co_purge        CONSTANT oddgen_types.key_type := 'Purge?'; -- for tables only
			
			   --
			   -- get_object_group
			   --
			   FUNCTION get_object_group(
			   in_object_type IN VARCHAR2
			   ) RETURN VARCHAR2 IS
			      l_object_group oddgen_types.key_type;
			   BEGIN
			      IF in_object_type IN ('FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'TRIGGER', 'TYPE', 'TYPE BODY') 
			      THEN
			         l_object_group := 'CODE';
			      ELSE
			         l_object_group := 'DATA';
			      END IF;
			      RETURN l_object_group;
			   END get_object_group;
			
			   --
			   -- get_nodes
			   --
			   FUNCTION get_nodes(
			      in_parent_node_id IN oddgen_types.key_type DEFAULT NULL
			   ) RETURN oddgen_types.t_node_type IS
			      t_nodes oddgen_types.t_node_type;
			      -- 
			      PROCEDURE add_node(
			         in_id           IN oddgen_types.key_type,
			         in_object_group IN oddgen_types.key_type,
			         in_object_type  IN oddgen_types.key_type DEFAULT NULL,
			         in_object_name  IN oddgen_types.key_type DEFAULT NULL
			      ) IS
			         l_node  oddgen_types.r_node_type;
			      BEGIN
			         l_node.parent_id := in_parent_node_id;
			         IF in_parent_node_id IS NOT NULL THEN
			            l_node.id := in_parent_node_id || '.' || in_id; -- make it unique
			         ELSE
			            l_node.id := in_id;
			         END IF;
			         l_node.name := initcap(in_id);
			         l_node.params.delete;
			         l_node.params(co_object_group) := in_object_group;
			         IF in_object_type IS NOT NULL THEN
			            l_node.params(co_object_type) := in_object_type;
			         END IF;
			         IF in_object_name IS NOT NULL THEN
			            l_node.params(co_object_name) := in_object_name;
			            l_node.leaf := TRUE;
			         END IF;
			         l_node.params(co_purge) := 'No';
			         IF in_parent_node_id IS NULL THEN
			            -- set 16x16 icon for root nodes
			            IF in_id = 'CODE' THEN
			               -- PNG encoded as Base64, encoded via https://www.base64-image.de/
			               l_node.icon_base64 := 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAKT2lDQ1BQaG90b3Nob3AgSUNDIHByb2ZpbGUAAHjanVNnVFPpFj333vRCS4iAlEt' ||
			                  'vUhUIIFJCi4AUkSYqIQkQSoghodkVUcERRUUEG8igiAOOjoCMFVEsDIoK2AfkIaKOg6OIisr74Xuja9a89+bN/rXXPues852zzwfACAyWSDNRNYAMqUIeEeCDx8TG4eQuQIEKJHAAEAizZCFz/SMBAPh+PDwrI' ||
			                  'sAHvgABeNMLCADATZvAMByH/w/qQplcAYCEAcB0kThLCIAUAEB6jkKmAEBGAYCdmCZTAKAEAGDLY2LjAFAtAGAnf+bTAICd+Jl7AQBblCEVAaCRACATZYhEAGg7AKzPVopFAFgwABRmS8Q5ANgtADBJV2ZIALC' ||
			                  '3AMDOEAuyAAgMADBRiIUpAAR7AGDIIyN4AISZABRG8lc88SuuEOcqAAB4mbI8uSQ5RYFbCC1xB1dXLh4ozkkXKxQ2YQJhmkAuwnmZGTKBNA/g88wAAKCRFRHgg/P9eM4Ors7ONo62Dl8t6r8G/yJiYuP+5c+rc' ||
			                  'EAAAOF0ftH+LC+zGoA7BoBt/qIl7gRoXgugdfeLZrIPQLUAoOnaV/Nw+H48PEWhkLnZ2eXk5NhKxEJbYcpXff5nwl/AV/1s+X48/Pf14L7iJIEyXYFHBPjgwsz0TKUcz5IJhGLc5o9H/LcL//wd0yLESWK5WCo' ||
			                  'U41EScY5EmozzMqUiiUKSKcUl0v9k4t8s+wM+3zUAsGo+AXuRLahdYwP2SycQWHTA4vcAAPK7b8HUKAgDgGiD4c93/+8//UegJQCAZkmScQAAXkQkLlTKsz/HCAAARKCBKrBBG/TBGCzABhzBBdzBC/xgNoRCJ' ||
			                  'MTCQhBCCmSAHHJgKayCQiiGzbAdKmAv1EAdNMBRaIaTcA4uwlW4Dj1wD/phCJ7BKLyBCQRByAgTYSHaiAFiilgjjggXmYX4IcFIBBKLJCDJiBRRIkuRNUgxUopUIFVIHfI9cgI5h1xGupE7yAAygvyGvEcxlIG' ||
			                  'yUT3UDLVDuag3GoRGogvQZHQxmo8WoJvQcrQaPYw2oefQq2gP2o8+Q8cwwOgYBzPEbDAuxsNCsTgsCZNjy7EirAyrxhqwVqwDu4n1Y8+xdwQSgUXACTYEd0IgYR5BSFhMWE7YSKggHCQ0EdoJNwkDhFHCJyKTq' ||
			                  'Eu0JroR+cQYYjIxh1hILCPWEo8TLxB7iEPENyQSiUMyJ7mQAkmxpFTSEtJG0m5SI+ksqZs0SBojk8naZGuyBzmULCAryIXkneTD5DPkG+Qh8lsKnWJAcaT4U+IoUspqShnlEOU05QZlmDJBVaOaUt2ooVQRNY9' ||
			                  'aQq2htlKvUYeoEzR1mjnNgxZJS6WtopXTGmgXaPdpr+h0uhHdlR5Ol9BX0svpR+iX6AP0dwwNhhWDx4hnKBmbGAcYZxl3GK+YTKYZ04sZx1QwNzHrmOeZD5lvVVgqtip8FZHKCpVKlSaVGyovVKmqpqreqgtV8' ||
			                  '1XLVI+pXlN9rkZVM1PjqQnUlqtVqp1Q61MbU2epO6iHqmeob1Q/pH5Z/YkGWcNMw09DpFGgsV/jvMYgC2MZs3gsIWsNq4Z1gTXEJrHN2Xx2KruY/R27iz2qqaE5QzNKM1ezUvOUZj8H45hx+Jx0TgnnKKeX836' ||
			                  'K3hTvKeIpG6Y0TLkxZVxrqpaXllirSKtRq0frvTau7aedpr1Fu1n7gQ5Bx0onXCdHZ4/OBZ3nU9lT3acKpxZNPTr1ri6qa6UbobtEd79up+6Ynr5egJ5Mb6feeb3n+hx9L/1U/W36p/VHDFgGswwkBtsMzhg8x' ||
			                  'TVxbzwdL8fb8VFDXcNAQ6VhlWGX4YSRudE8o9VGjUYPjGnGXOMk423GbcajJgYmISZLTepN7ppSTbmmKaY7TDtMx83MzaLN1pk1mz0x1zLnm+eb15vft2BaeFostqi2uGVJsuRaplnutrxuhVo5WaVYVVpds0a' ||
			                  'tna0l1rutu6cRp7lOk06rntZnw7Dxtsm2qbcZsOXYBtuutm22fWFnYhdnt8Wuw+6TvZN9un2N/T0HDYfZDqsdWh1+c7RyFDpWOt6azpzuP33F9JbpL2dYzxDP2DPjthPLKcRpnVOb00dnF2e5c4PziIuJS4LLL' ||
			                  'pc+Lpsbxt3IveRKdPVxXeF60vWdm7Obwu2o26/uNu5p7ofcn8w0nymeWTNz0MPIQ+BR5dE/C5+VMGvfrH5PQ0+BZ7XnIy9jL5FXrdewt6V3qvdh7xc+9j5yn+M+4zw33jLeWV/MN8C3yLfLT8Nvnl+F30N/I/9' ||
			                  'k/3r/0QCngCUBZwOJgUGBWwL7+Hp8Ib+OPzrbZfay2e1BjKC5QRVBj4KtguXBrSFoyOyQrSH355jOkc5pDoVQfujW0Adh5mGLw34MJ4WHhVeGP45wiFga0TGXNXfR3ENz30T6RJZE3ptnMU85ry1KNSo+qi5qP' ||
			                  'No3ujS6P8YuZlnM1VidWElsSxw5LiquNm5svt/87fOH4p3iC+N7F5gvyF1weaHOwvSFpxapLhIsOpZATIhOOJTwQRAqqBaMJfITdyWOCnnCHcJnIi/RNtGI2ENcKh5O8kgqTXqS7JG8NXkkxTOlLOW5hCepkLx' ||
			                  'MDUzdmzqeFpp2IG0yPTq9MYOSkZBxQqohTZO2Z+pn5mZ2y6xlhbL+xW6Lty8elQfJa7OQrAVZLQq2QqboVFoo1yoHsmdlV2a/zYnKOZarnivN7cyzytuQN5zvn//tEsIS4ZK2pYZLVy0dWOa9rGo5sjxxedsK4' ||
			                  'xUFK4ZWBqw8uIq2Km3VT6vtV5eufr0mek1rgV7ByoLBtQFr6wtVCuWFfevc1+1dT1gvWd+1YfqGnRs+FYmKrhTbF5cVf9go3HjlG4dvyr+Z3JS0qavEuWTPZtJm6ebeLZ5bDpaql+aXDm4N2dq0Dd9WtO319kX' ||
			                  'bL5fNKNu7g7ZDuaO/PLi8ZafJzs07P1SkVPRU+lQ27tLdtWHX+G7R7ht7vPY07NXbW7z3/T7JvttVAVVN1WbVZftJ+7P3P66Jqun4lvttXa1ObXHtxwPSA/0HIw6217nU1R3SPVRSj9Yr60cOxx++/p3vdy0NN' ||
			                  'g1VjZzG4iNwRHnk6fcJ3/ceDTradox7rOEH0x92HWcdL2pCmvKaRptTmvtbYlu6T8w+0dbq3nr8R9sfD5w0PFl5SvNUyWna6YLTk2fyz4ydlZ19fi753GDborZ752PO32oPb++6EHTh0kX/i+c7vDvOXPK4dPK' ||
			                  'y2+UTV7hXmq86X23qdOo8/pPTT8e7nLuarrlca7nuer21e2b36RueN87d9L158Rb/1tWeOT3dvfN6b/fF9/XfFt1+cif9zsu72Xcn7q28T7xf9EDtQdlD3YfVP1v+3Njv3H9qwHeg89HcR/cGhYPP/pH1jw9DB' ||
			                  'Y+Zj8uGDYbrnjg+OTniP3L96fynQ89kzyaeF/6i/suuFxYvfvjV69fO0ZjRoZfyl5O/bXyl/erA6xmv28bCxh6+yXgzMV70VvvtwXfcdx3vo98PT+R8IH8o/2j5sfVT0Kf7kxmTk/8EA5jz/GMzLdsAAAAgY0h' ||
			                  'STQAAeiUAAICDAAD5/wAAgOkAAHUwAADqYAAAOpgAABdvkl/FRgAABCBJREFUeAEAEATv+wH///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB' ||
			                  'KGQIID+/gB///7/AP3+/wD+/QAA/v4AAP7+AIFrfeKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnowf//v70f/7+9H/+/vR//r60P/5+c//kX8c/3xsGJP///8A////AP///wD///8A////AP/' ||
			                  '//wD///8A////AAGcih7/X3GzAPv70QD+/v8A/v79AP79/gDp5dMAs6asAP78AAD8/f8A/v3/AAAAAAD+/gAA/f0AAP39/4GDl+eABP7+/wDQw3kA////AAAAAAD+//4A//8AAAcKEgBnea4A////AP7+/gD+/' ||
			                  'v4AAAAAAP/+/wD+//4Aj3tXfwEBAacE/v8AAC88hgD///8A////AP7+/gD///8A/v7+APHwxwALjbYA81AxAPcZDgAAAAAA/f39AP39/QD9/gAAAAAAJgT9/QAA////APf3zgD+/v0A/9PiAAWjwwD6QSoA/Ts' ||
			                  'kAATN4AADLRsAFZ3BAPFUMwD0IhQA/f39AP38/gAAAAAABP79/wD///8AAbzSAAaoxwD///8A+kcsAPY8JQAC4OoA+jAdAPI6IgD/8fQAEJrCABD//wDvSiwA/f3/AAAAAAAE/f3/AP/q7QAFXJkA+ZRbAPZJL' ||
			                  'gD9/f0A/Pz8AArS4gD4IxQA/f39AO1DKADtQygAELnUABh0sAAVSwsAAAAAAAT+/QAA/xQRAPihYwAFqckADbXPAPdEKgD5RisABNjnAPNMLgD9/f0AELnUAA2/2gAA//8A5YlLAOjJwwAAAAAABAAAAAAAAAA' ||
			                  'A+kAqAPc9JwAC1OIACabHAAsKBQAG0OMA+Wg/AA/E2gALzuMA6185APIjEwD9/f0AAMnDAAAAAAAE/f0AAP7+/gD+/f0A/vz9APslGAD0e0wAA+HrAAUuGwD8/v0A7TcgAOo0HQAAAAAA/v39AP7//wD9/v8AA' ||
			                  'AAAAAT9/P4A////AP38/QD8/PwA/f79AP3+/gD6GQ8A82g/AP79/QD+/P0A///+AAAAAAD+/v4A/v7+AP/9/wAAAAAABP3+AYGQfVB//f0AAP38/wD9/QAA////AP39AAD9/f8A/v4AAP7+/wD//gEAAAAAAP3' ||
			                  '+/wD///8A5uv7pwAAAAAB////AAEBAScAAAAmAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2gH///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' ||
			                  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA///ooKLEB2LSkAAAAABJRU5ErkJggg==';
			            ELSIF in_id = 'DATA' THEN
			               -- reference an icon by name in oddgen resource bundle
			               l_node.icon_name := 'DATA_FOLDER_ICON';
			            END IF;
			         END IF;
			         t_nodes.extend;
			         t_nodes(t_nodes.count) := l_node;
			      END add_node;
			   BEGIN
			      t_nodes := oddgen_types.t_node_type();
			      IF in_parent_node_id IS NULL THEN
			         -- generator root nodes
			         <<object_groups>>
			         FOR r IN (
			            SELECT DISTINCT plsql_dummy1.get_object_group(in_object_type => object_type) AS object_group
			              FROM user_objects
			             WHERE generated = 'N'
			             ORDER BY object_group
			         ) LOOP
			            add_node(
			               in_id           => r.object_group,
			               in_object_group => r.object_group
			            );
			         END LOOP object_groups;
			      ELSIF in_parent_node_id NOT LIKE '%.%' THEN
			         -- object type nodes
			         <<object_types>>
			         FOR r IN (
			            SELECT object_type
			              FROM user_objects
			             WHERE generated = 'N'
			               AND plsql_dummy1.get_object_group(in_object_type => object_type) = in_parent_node_id
			             GROUP BY object_type
			             ORDER BY object_type
			         ) LOOP
			            add_node(
			               in_id           => r.object_type,
			               in_object_group => in_parent_node_id,
			               in_object_type  => r.object_type
			            );
			         END LOOP object_types;
			      ELSE
			         -- object name nodes
			         <<object_names>>
			         FOR r IN (
			            SELECT object_type,
			                   object_name
			              FROM user_objects
			             WHERE object_type = substr(in_parent_node_id, INSTR(in_parent_node_id, '.') + 1)
			               AND generated = 'N'
			              ORDER BY object_name
			         ) LOOP
			            add_node(
			               in_id           => r.object_name, 
			               in_object_group => substr(in_parent_node_id, 1, INSTR(in_parent_node_id, '.') - 1),
			               in_object_type  => r.object_type,
			               in_object_name  => r.object_name
			            );
			         END LOOP object_names;
			      END IF;
			      RETURN t_nodes;       
			   END get_nodes;
			
			   --
			   -- generate
			   --
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			
			END plsql_dummy1;
		''')
	}

	def static createPlsqlDummy2() {

		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy2 AUTHID CURRENT_USER IS
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB;			   
			END plsql_dummy2;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy2 IS
			   --
			   -- generate
			   --
			   FUNCTION generate(
			      in_node IN oddgen_types.r_node_type
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy2;
		''')
	}

	def static createPlsqlDummy3() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy3 AUTHID CURRENT_USER IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   FUNCTION get_object_types RETURN t_string;
			   FUNCTION generate (
			      in_object_type IN VARCHAR2,
			      in_object_name IN VARCHAR2
			   ) RETURN CLOB;			   
			END plsql_dummy3;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy3 IS
			   --
			   -- get_object_types
			   --
			   FUNCTION get_object_types RETURN t_string IS
			   BEGIN
			      RETURN NEW t_string('TABLE');
			   END get_object_types;
			   --
			   -- generate
			   --
			   FUNCTION generate (
			      in_object_type IN VARCHAR2,
			      in_object_name IN VARCHAR2
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy3;
		''')
	}

	def static createPlsqlDummy4() {
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE plsql_dummy4 AUTHID CURRENT_USER IS
			   SUBTYPE string_type IS VARCHAR2(1000 CHAR);
			   TYPE t_string IS TABLE OF string_type;
			   FUNCTION get_object_types RETURN t_string;
			   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;
			   FUNCTION generate (
			      in_object_type IN VARCHAR2,
			      in_object_name IN VARCHAR2
			   ) RETURN CLOB;			   
			END plsql_dummy4;
		''')
		jdbcTemplate.execute('''
			CREATE OR REPLACE PACKAGE BODY plsql_dummy4 IS
			   --
			   -- get_object_types
			   --
			   FUNCTION get_object_types RETURN t_string IS
			   BEGIN
			      RETURN NEW t_string('TABLE');
			   END get_object_types;
			   --
			   -- get_object_names
			   --
			   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string IS
			      l_object_names t_string;
			   BEGIN
			      SELECT initcap(object_name) AS object_name
			        BULK COLLECT
			        INTO l_object_names
			        FROM user_objects
			       WHERE object_type = in_object_type
			         AND generated = 'N'
			       ORDER BY object_name;
			      RETURN l_object_names;
			   END get_object_names;
			   --
			   -- generate
			   --
			   FUNCTION generate (
			      in_object_type IN VARCHAR2,
			      in_object_name IN VARCHAR2
			   ) RETURN CLOB IS
			   BEGIN
			      RETURN NULL;
			   END generate;
			END plsql_dummy4;
		''')
	}

}
