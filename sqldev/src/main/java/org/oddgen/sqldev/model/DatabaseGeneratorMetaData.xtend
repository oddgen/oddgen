/*
 * Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
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

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class DatabaseGeneratorMetaData extends AbstractModel {
	/** PL/SQL package owner */
	String generatorOwner
	
	/** PL/SQL package name*/
	String generatorName

	/** PL/SQL oddgen_types package owner */
	String typesOwner
	
	/** name of the generator */
	String name

	/** description of the generator */
	String description
	
	/** indicates if the generator package has a get_name function */
	Boolean hasGetName
	
	/** indicates if the generator package has a get_description function */
	Boolean hasGetDescription
	
	/** indicates if the generator package has a get_folders function */
	Boolean hasGetFolders

	/** indicates if the generator package has a get_help function */
	Boolean hasGetHelp
	
	/** indicates if the generator package has a get_nodes function */
	Boolean hasGetNodes

	/** indicates if the generator package has a get_objectTypes function */
	@Deprecated
	Boolean hasGetObjectTypes

	/** indicates if the generator package has a get_objectNames function */
	@Deprecated
	Boolean hasGetObjectNames

	/** indicates if the generator package has a get_params function without input parameters */
	@Deprecated
	Boolean hasGetParams1

	/** indicates if the generator package has a get_params function with 2 input parameters */
	@Deprecated
	Boolean hasGetParams2

	/** indicates if the generator package has a get_ordered_params function without parameters */
	Boolean hasGetOrderedParams1

	/** indicates if the generator package has a get_ordered_params function with 2 input parameters */
	@Deprecated
	Boolean hasGetOrderedParams2

	/** indicates if the generator package has a get_lov function without parameters */
	@Deprecated
	Boolean hasGetLov1

	/** indicates if the generator package has a get_lov function with 3 input parameters */
	@Deprecated
	Boolean hasGetLov2

	/** indicates if the generator package has a get_lov function with 1 input parameter */
	Boolean hasGetLov3

	/** indicates if the generator package has a refresh_lov function */
	@Deprecated
	Boolean hasRefreshLov
	
	/** indicates if the generator package has a refresh_param_states function */
	@Deprecated
	Boolean hasRefreshParamStates
	
	/** indicates if the generator package has a get_param_states function with a v0.2.0 signature */
	@Deprecated
	Boolean hasGetParamStates1
	
	/** indicates if the generator package has a get_param_states function with a v0.3.0 signature */
	Boolean hasGetParamStates2

	/** indicates if the generator package has a generate_prolog function */
	Boolean hasGenerateProlog

	/** indicates if the generator package has a generate_separator function */
	Boolean hasGenerateSeparator

	/** indicates if the generator package has a generate_epilog function */
	Boolean hasGenerateEpilog

	/** indicates if the generator package has a generate function with all 3 input parameters */
	@Deprecated
	Boolean hasGenerate1

	/** indicates if the generator package has a generate function with all 2 input parameters */
	@Deprecated
	Boolean hasGenerate2

	/** indicates if the generator package has a generate function with all 1 input parameter */
	Boolean hasGenerate3
}
