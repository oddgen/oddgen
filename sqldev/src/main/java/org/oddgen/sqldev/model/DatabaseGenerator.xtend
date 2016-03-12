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
package org.oddgen.sqldev.model

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class DatabaseGenerator extends Generator implements Cloneable{
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

	/** list of valid object types (1st parameter) */
	List<String> objectTypes

	/** 3rd parameter of the generate function (optional) */
	HashMap<String, String> params

	/** list-of-values for params */
	HashMap<String, List<String>> lovs

	/** indicates if the list-of-values are dependent on current params settings and a refresh is supported */
	Boolean isRefreshable
	
	override clone() {
		val clone = new DatabaseGenerator
		clone.name = new String(this.name)
		clone.description = new String(this.description)
		clone.generatorOwner = new String(this.generatorOwner)
		clone.generatorName = new String(this.generatorName)
		clone.objectType = if (this.objectType != null) {new String(this.objectType)}
		clone.objectName = if (this.objectName != null) {new String(this.objectName)}
		clone.hasParams = new Boolean(this.hasParams)
		clone.objectTypes = new ArrayList<String>()
		for (type : this.objectTypes) {
			clone.objectTypes.add(new String(type))
		}
		clone.params = this.params.clone() as HashMap<String, String>
		clone.lovs = this.lovs.clone() as HashMap<String, List<String>>
		clone.isRefreshable = new Boolean(this.isRefreshable)
 		return clone
	}
	
	def copy() {
		return clone() as DatabaseGenerator
	}
}
