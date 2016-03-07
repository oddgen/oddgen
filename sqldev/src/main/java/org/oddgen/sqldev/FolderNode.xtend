package org.oddgen.sqldev

import com.jcabi.log.Logger
import java.net.URL
import javax.swing.tree.TreePath
import oracle.ide.model.DefaultContainer
import oracle.ideimpl.explorer.ExplorerNode
import org.oddgen.sqldev.model.Folder
import org.oddgen.sqldev.resources.OddgenResources

class FolderNode extends DefaultContainer {
	Folder folder;

	new() {
	}

	new(URL url) {
		this(url, null)
	}

	new(URL url, Folder folder) {
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
			tree.selectionPath = childPath
			Logger.debug(this, "selected")
		}
	}
	
}
