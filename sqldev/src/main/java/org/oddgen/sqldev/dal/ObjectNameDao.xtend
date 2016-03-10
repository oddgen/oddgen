package org.oddgen.sqldev.dal

import com.jcabi.aspects.Loggable
import java.sql.Connection
import java.util.ArrayList
import java.util.List
import org.oddgen.sqldev.model.DatabaseGenerator
import org.oddgen.sqldev.model.ObjectName
import org.oddgen.sqldev.model.ObjectType
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource
import org.w3c.dom.Element

@Loggable(prepend=true)
class ObjectNameDao {
	private Connection conn
	private JdbcTemplate jdbcTemplate
	private DalTools dalTools

	new(Connection conn) {
		this.conn = conn
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		this.dalTools = new DalTools(conn)
	}

	def findUserObjectNames(ObjectType objectType) {
		// ignore generated objects, such as IOT overflow tables
		val sql = '''
			SELECT object_type AS type_name,
			       object_name AS name
			 FROM user_objects 
			WHERE object_type = ?
			  AND generated = 'N'
			ORDER BY object_name
		'''
		val params = #[objectType.name]
		val names = jdbcTemplate.query(sql, params, new BeanPropertyRowMapper<ObjectName>(ObjectName))
		for (name : names) {
			name.generator = objectType.generator
		}
		return names
	}

	def List<ObjectName> findObjectNames(ObjectType objectType) {
		val dbgen = objectType.
			generator as DatabaseGenerator
		// convert PL/SQL nested table XML
		val plsql = '''
			DECLARE
			   l_names «dbgen.generatorOwner».«dbgen.generatorName».t_string;
			   l_clob   CLOB;
			BEGIN
			   l_names := «dbgen.generatorOwner».«dbgen.generatorName».get_object_names(in_object_type => '«objectType.name»');
			   l_clob := '<values>';
			   FOR i IN 1 .. l_names.count
			   LOOP
			      l_clob := l_clob || '<value>' || l_names(i) || '</value>';
			   END LOOP;
			   l_clob := l_clob || '</values>';
			   ? := l_clob;
			END;
		'''
		val doc = dalTools.getDoc(plsql)
		if (doc != null) {
			val names = new ArrayList<ObjectName>()
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val name = value.textContent
				val objectName = new ObjectName()
				objectName.name = name
				objectName.typeName = objectType.name
				objectName.generator = objectType.generator
				names.add(objectName)
			}
			return names
		} else {
			return findUserObjectNames(objectType)
		}
	}
}
