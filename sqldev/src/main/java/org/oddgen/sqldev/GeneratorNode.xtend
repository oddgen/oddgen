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
package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.net.URL
import oracle.ide.model.DefaultContainer
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import org.oddgen.sqldev.generators.OddgenGenerator
import org.oddgen.sqldev.model.ObjectType
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class GeneratorNode extends DefaultContainer {
	private OddgenGenerator generator

	new(URL url, OddgenGenerator generator) {
		super(url)
		this.generator = generator
	}

	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_ICON")
	}

	override getLongLabel() {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		return generator?.getDescription(conn)
	}

	override getShortLabel() {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		return generator?.getName(conn)
	}

	override getToolTipText() {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		return generator?.getDescription(conn)
	}

	override openImpl() {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		val gen = generator
		for (name : gen.getObjectTypes(conn)) {
			val objectType = new ObjectType()
			objectType.generator = generator
			objectType.name = name
			val node = new ObjectTypeNode(URLFactory.newURL(this.URL, objectType.name), objectType)
			this.add(node)
		}
		UpdateMessage.fireStructureChanged(this)
		this.markDirty(false)
	}

}
