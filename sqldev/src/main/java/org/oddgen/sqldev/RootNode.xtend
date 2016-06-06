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
import java.io.IOException
import javax.swing.JTree
import javax.swing.tree.TreeNode
import javax.swing.tree.TreePath
import oracle.ide.model.DefaultContainer
import oracle.ide.model.Subject
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import oracle.ideimpl.explorer.ExplorerNode
import org.oddgen.sqldev.model.GeneratorFolder
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
class RootNode extends DefaultContainer {
	private static String ROOT_NODE_NAME = OddgenResources.getString("ROOT_NODE_LONG_LABEL")
	private static String CLIENT_GEN_NAME = OddgenResources.getString("CLIENT_GEN_NODE_LONG_LABEL")
	private static String DBSERVER_GEN_NAME = OddgenResources.getString("DBSERVER_GEN_NODE_LONG_LABEL")
	private static RootNode INSTANCE
	private boolean initialized = false
	private GeneratorFolderNode clientGenerators
	private GeneratorFolderNode dbServerGenerators

	def static synchronized getInstance() {
		if (INSTANCE == null) {
			INSTANCE = new RootNode
			Logger.info(RootNode, "RootNode created.")
		}
		return INSTANCE
	}

	private new() {
		val url = URLFactory.newURL("oddgen.generators", ROOT_NODE_NAME)
		if (url == null) {
			Logger.error(this, "root node URL is null")
		}
		setURL(url)
	}

	def getClientGenerators() {
		try {
			open()
		} catch (IOException e) {
			Logger.error(this, e.message)
		}
		return clientGenerators
	}

	def getDbServerGenerators() {
		try {
			open()
		} catch (IOException e) {
			Logger.error(this, e.message)
		}
		return dbServerGenerators
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

	override protected openImpl() {
		val Runnable runnable = [|initialize]
		val thread = new Thread(runnable)
		thread.name = "oddgen Tree Opener"
		thread.start
	}

	def protected addFolder(String name) {
		val folder = new GeneratorFolder()
		folder.name = name
		folder.description = name
		val folderUrl = URLFactory.newURL(getURL(), name)
		val folderNode = new GeneratorFolderNode(folderUrl, folder)
		_children.add(folderNode)
		UpdateMessage.fireChildAdded(this as Subject, folderNode)
		return folderNode

	}

	def initialize() {
		if (!initialized) {
			clientGenerators = addFolder(CLIENT_GEN_NAME)
			dbServerGenerators = addFolder(DBSERVER_GEN_NAME)
			// refresh tree
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
