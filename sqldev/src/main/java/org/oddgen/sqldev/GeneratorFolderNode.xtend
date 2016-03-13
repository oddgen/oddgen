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

import com.jcabi.log.Logger
import java.net.URL
import javax.swing.tree.TreePath
import oracle.ide.model.DefaultContainer
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import oracle.ideimpl.explorer.ExplorerNode
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.model.GeneratorFolder
import org.oddgen.sqldev.resources.OddgenResources

class GeneratorFolderNode extends DefaultContainer {
	GeneratorFolder folder;

	new(URL url, GeneratorFolder folder) {
		super(url)
		this.folder = folder
	}

	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_FOLDER_ICON")
	}

	override getLongLabel() {
		return folder?.getDescription
	}

	override getShortLabel() {
		return folder?.name
	}

	override getToolTipText() {
		return folder?.tooltip
	}

	def getFolder() {
		return folder
	}

	def void openBackground() {
		if (this == RootNode.instance.dbServerGenerators) {
			val folder = RootNode.instance.dbServerGenerators
			folder.removeAll
			val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
			if (conn != null) {
				val dao = new DatabaseGeneratorDao(conn)
				val dbgens = dao.findAll
				Logger.debug(this, "discovered %d database generators", dbgens.size)
				for (dbgen : dbgens) {
					val node = new GeneratorNode(URLFactory.newURL(folder.URL, dbgen.name), dbgen)
					folder.add(node)
				}
			}
			UpdateMessage.fireStructureChanged(folder)
			folder.expandNode
			folder.markDirty(false)
		}
	}

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
		if (child != null) {
			val rootPath = new TreePath(root)
			Logger.debug(this, "rootPath is %s", rootPath)
			val childPath = rootPath.pathByAddingChild(child)
			Logger.debug(this, "childPath is %s", childPath)
			tree.expandPath(childPath)
			Logger.debug(this, "expanded")
		}
	}

}
