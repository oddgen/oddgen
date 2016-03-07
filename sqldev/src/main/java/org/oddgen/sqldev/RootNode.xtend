package org.oddgen.sqldev

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
import org.oddgen.sqldev.model.Folder
import org.oddgen.sqldev.resources.OddgenResources

class RootNode extends DefaultContainer {
	private static String ROOT_NODE_NAME = OddgenResources.getString("ROOT_NODE_LONG_LABEL")
	private static String CLIENT_GEN_NAME = OddgenResources.getString("CLIENT_GEN_NODE_LONG_LABEL")
	private static String DBSERVER_GEN_NAME = OddgenResources.getString("DBSERVER_GEN_NODE_LONG_LABEL")
	private static RootNode INSTANCE
	private boolean initialized = false
	private FolderNode clientGenerators
	private FolderNode dbServerGenerators

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
		val folder = new Folder()
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
			tree.collapsePath(parent)
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
