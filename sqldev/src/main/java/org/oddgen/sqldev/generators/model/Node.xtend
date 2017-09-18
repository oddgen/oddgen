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
package org.oddgen.sqldev.generators.model

import java.util.LinkedHashMap
import org.eclipse.xtend.lib.annotations.Accessors
import org.oddgen.sqldev.model.AbstractModel

@Accessors
class Node extends AbstractModel {
	
	/** node identifier, case-sensitive, e.g. EMP */
	String id
	
	/** parent node identifier, NULL for root nodes, e.g. TABLE */
	String parentId
	
	/** name of the node, e.g. Emp */
	String name
	
	/** description of the node, e.g. Table Emp */
	String description
	
	/** existing icon name, e.g. TABLE_ICON, VIEW_ICON */
	String iconName
	
	/** Base64 encoded icon, size: 16x16 pixels, format: PNG, GIF or JPEG */
	String iconBase64
	
	/** array of parameters, e.g. View suffix=_V, Instead-of-trigger suffix=_TRG */
	LinkedHashMap<String, String> params
	
	/** Is this a leaf node? true|false, default false */
	Boolean leaf
	
	/** Is the node with all its children generatable? true|false, default leaf */
	Boolean generatable
	
	/** May this node be part of a multiselection? true|false, default leaf */
	Boolean multiselectable
	
	/** Pass node to the generator? true|false, default leaf */
	Boolean relevant
}