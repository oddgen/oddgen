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
import com.jcabi.log.Logger
import java.net.URL
import javax.swing.tree.TreePath
import oracle.ide.model.DefaultContainer
import oracle.ide.model.UpdateMessage
import oracle.ideimpl.explorer.ExplorerNode
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class FolderNode extends DefaultContainer {
	String name;

	new(URL url, String name) {
		super(url)
		this.name = name
	}

	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_FOLDER_ICON")
	}

	override getLongLabel() {
		return this.name;
	}

	override getShortLabel() {
		return this.name;
	}

	override getToolTipText() {
		return this.name;
	}

	@Loggable
	def void openBackground() {
		val folder = this
		UpdateMessage.fireStructureChanged(folder)
		folder.expandNode
		folder.markDirty(false)
	}

	@Loggable(LoggableConstants.DEBUG)
	override openImpl() {
		val Runnable runnable = [|openBackground]
		val thread = new Thread(runnable)
		thread.name = "oddgen Open Generator Folder"
		thread.start
	}

	def expandNode() {
		val tree = TreeUtils.findTree(OddgenNavigatorManager.instance.navigatorWindow.GUI)
		Logger.debug(this, "tree is %s", tree)
		val root = tree.model.root as ExplorerNode;
		Logger.debug(this, "root is %1$s, class is %2$s", root, root.class.name)
		val nodes = root.childTNodes
		var ExplorerNode child
		while (nodes.hasMoreElements) {
			val node = nodes.nextElement as ExplorerNode
			if (node.data == this) {
				child = node
			}
		}
		if (child !== null) {
			val rootPath = new TreePath(root)
			Logger.debug(this, "rootPath is %s", rootPath)
			val childPath = rootPath.pathByAddingChild(child)
			Logger.debug(this, "childPath is %s", childPath)
			tree.expandPath(childPath)
			Logger.debug(this, "expanded")
		}
	}

}
