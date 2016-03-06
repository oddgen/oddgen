package org.oddgen.sqldev.dal.model

import java.util.HashMap
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

@Accessors
class DatabaseGenerator {
	/** PL/SQL package owner */
	String generatorOwner
	
	/** name of the PL/SQL package*/
	String generatorName
	
	/** 1st parameter of the generate function */
	String objectType
	
	/** 2nd parameter of the generate function */
	String objectName
	
	/** indicates if the generate function expects a 3rd parameter named in_params */
	Boolean hasParams

	/** name of the generator */
	String name

	/** description of the generator */
	String description

	/** list of valid object types (1st parameter) */
	List<String> objectTypes

	/** 3rd parameter of the generate function (optional) */
	HashMap<String, String> params

	/** list-of-values for params */
	HashMap<String, List<String>> lovs

	/** indicates if the list-of-values are dependent on current params settings and a refresh is supported */
	Boolean isRefreshable
	
	override toString() {
		new ToStringBuilder(this).addAllFields.toString
	}
}
