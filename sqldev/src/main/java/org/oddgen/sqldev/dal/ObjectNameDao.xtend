package org.oddgen.sqldev.dal

import com.jcabi.aspects.Loggable
import java.sql.Connection
import java.util.ArrayList
import org.oddgen.sqldev.model.DatabaseGenerator
import org.oddgen.sqldev.model.ObjectName
import org.oddgen.sqldev.model.ObjectType
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
			 SELECT object_name
			   FROM user_objects
			  WHERE object_type = ?
			    AND generated = 'N'
			 ORDER BY object_name
		'''
		val names = jdbcTemplate.queryForList(sql, String, objectType.name)
		val objectNames = new ArrayList<ObjectName>()
		for (name : names) {
			val objectName = new ObjectName()
			objectName.name = name 
			objectName.objectType = objectType
			objectNames.add(objectName)
		}
		return objectNames
	}

	def findObjectNames(ObjectType objectType) {
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
			val objectNames = new ArrayList<ObjectName>()
			val values = doc.getElementsByTagName("value")
			for (var i = 0; i < values.length; i++) {
				val value = values.item(i) as Element
				val name = value.textContent
				val objectName = new ObjectName()
				objectName.name = name
				objectName.objectType = objectType
				objectNames.add(objectName)
			}
			return objectNames
		} else {
			return findUserObjectNames(objectType)
		}
	}
}
