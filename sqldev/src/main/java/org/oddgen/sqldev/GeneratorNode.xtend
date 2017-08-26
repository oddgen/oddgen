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
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.NodeTools
import org.oddgen.sqldev.model.GeneratorSelection
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class GeneratorNode extends DefaultContainer {
	val OddgenGenerator2 generator
	val extension NodeTools nodeTools = new NodeTools

	new(URL url, OddgenGenerator2 generator) {
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

	def openBackground() {
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		val gen = generator
		val nodes = gen.getNodes(conn, null)
		for (node : nodes.filter[it.parentId === null || it.parentId.empty]) {
			val GeneratorSelection gensel = new GeneratorSelection
			gensel.generator = gen
			gensel.node = node
			val nodeNode = new NodeNode(URLFactory.newURL(this.URL, gensel.node.id), gensel)
			this.add(nodeNode)
			if (!gensel.node.isLeaf) {
				nodeNode.openEagerlyLoadedChildren(nodes)
			}
		}
		UpdateMessage.fireStructureChanged(this)
		this.markDirty(false)
	}

	override openImpl() {
		val Runnable runnable = [|openBackground]
		val thread = new Thread(runnable)
		thread.name = "oddgen generator node"
		thread.start
	}

}
