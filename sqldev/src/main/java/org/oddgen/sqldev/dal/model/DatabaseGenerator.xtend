package org.oddgen.sqldev.dal.model

import java.util.HashMap
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

@Accessors
class DatabaseGenerator {
	String owner
	String objectName
	Boolean hasParams
	String name
	String description
	List<String> objectTypes
	HashMap<String, String> params
	HashMap<String, List<String>> lovs
	Boolean isRefreshable
	
	override toString() {
		new ToStringBuilder(this).addAllFields.toString
	}
}
