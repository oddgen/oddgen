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

import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class DatabaseGeneratorDto extends Generator{
	/** list of valid object types */
	List<String> objectTypes

	/** parameters and their default values */
	LinkedHashMap<String, String> params

	/** list-of-values for params */
	HashMap<String, List<String>> lovs
	
	/** parameter states (enable/disable parameters) */
	HashMap<String, String> paramStates

	/** indicates if the list-of-values are dependent on current params settings and a refresh is supported */
	Boolean isRefreshable

	/** PL/SQL package owner */
	String generatorOwner
	
	/** name of the PL/SQL package*/
	String generatorName
}
