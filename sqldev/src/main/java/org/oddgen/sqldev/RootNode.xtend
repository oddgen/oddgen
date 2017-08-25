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
import java.util.HashMap
import javax.swing.JTree
import javax.swing.tree.TreeNode
import javax.swing.tree.TreePath
import oracle.ide.model.DefaultContainer
import oracle.ide.model.Subject
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import oracle.ideimpl.explorer.ExplorerNode
import org.oddgen.sqldev.generators.OddgenGeneratorUtils
import org.oddgen.sqldev.model.GeneratorFolder
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class RootNode extends DefaultContainer {
	private static String ROOT_NODE_NAME = OddgenResources.getString("ROOT_NODE_LONG_LABEL")
	private static RootNode INSTANCE
	private boolean initialized = false

	def static synchronized getInstance() {
		if (INSTANCE === null) {
			INSTANCE = new RootNode
			Logger.info(RootNode, "RootNode created.")
		}
		return INSTANCE
	}

	private new() {
		val url = URLFactory.newURL("oddgen.generators", ROOT_NODE_NAME)
		if (url === null) {
			Logger.error(this, "root node URL is null")
		}
		setURL(url)
	}

	override getShortLabel() {
		return ROOT_NODE_NAME
	}

	override getLongLabel() {
		return ROOT_NODE_NAME
	}

	override getToolTipText() {
		return ROOT_NODE_NAME
	}

	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_FOLDER_ICON")
	}

	@Loggable
	def void openBackground() {
		var DefaultContainer folder = this
		val allFolders = new HashMap<URL, FolderNode>
		folder.removeAll
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		if (conn !== null) {
			val gens = OddgenGeneratorUtils.findAll(conn)
			Logger.info(this, "discovered %d generators", gens.size)
			for (gen : gens) {
				folder = this
				val folderNames = gen.getFolders(conn)
				var FolderNode generatorFolderNode
				for (folderName : folderNames) {
					val generatorFolder = new GeneratorFolder
					generatorFolder.name = folderName
					val url = URLFactory.newURL(folder.URL, folderName)
					generatorFolderNode = allFolders.get(url)
					if (generatorFolderNode === null) {
						generatorFolderNode = new FolderNode(url, generatorFolder)
						allFolders.put(url, generatorFolderNode)
						folder.add(generatorFolderNode)
						UpdateMessage.fireStructureChanged(folder)
						folder.markDirty(false)
					}
					folder = generatorFolderNode
				}
				val generatorNode = new GeneratorNode(URLFactory.newURL(folder.URL, gen.getName(conn)), gen)
				folder.add(generatorNode)
				UpdateMessage.fireStructureChanged(folder)
				folder.markDirty(false)
			}
		}
		UpdateMessage.fireStructureChanged(this)
		this.markDirty(false)
	}

	override openImpl() {
		val Runnable runnable = [|openBackground]
		val thread = new Thread(runnable)
		thread.name = "oddgen Tree Opener"
		thread.start
	}

	def protected addFolder(String name) {
		val folder = new GeneratorFolder()
		folder.name = name
		folder.description = name
		val folderUrl = URLFactory.newURL(getURL(), name)
		val folderNode = new FolderNode(folderUrl, folder)
		_children.add(folderNode)
		UpdateMessage.fireChildAdded(this as Subject, folderNode)
		return folderNode

	}

	def initialize() {
		if (!initialized) {
			UpdateMessage.fireStructureChanged(this as Subject)
			markDirty(false)
			Logger.info(this, "RootNode initialized.")
			initialized = true
		}
	}

	def protected void collapseall(JTree tree, TreePath parent, TreePath root) {
		val node = parent.getLastPathComponent() as TreeNode;
		if (node.getChildCount() >= 0) {
			for (val e = node.children; e.hasMoreElements;) {
				val n = e.nextElement as TreeNode
				val path = parent.pathByAddingChild(n)
				collapseall(tree, path, root)
			}
		}
		if (parent != root) {
			if (!tree.isCollapsed(parent)) {
				tree.collapsePath(parent)
			}
		}
	}

	def void collapseall() {
		val tree = TreeUtils.findTree(OddgenNavigatorManager.instance.navigatorWindow.GUI)
		Logger.debug(this, "tree to collapse: %1$s found in %2$s.", tree,
			OddgenNavigatorManager.instance.navigatorWindow.GUI)
		val root = tree.model.root as ExplorerNode
		Logger.debug(this, "root node to collapse %s.", root)
		val treePath = new TreePath(root)
		collapseall(tree, treePath, treePath)
	}

}
