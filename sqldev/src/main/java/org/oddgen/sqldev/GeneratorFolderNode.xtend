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
import oracle.ide.config.Preferences
import oracle.ide.model.DefaultContainer
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import oracle.ideimpl.explorer.ExplorerNode
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.model.GeneratorFolder
import org.oddgen.sqldev.model.PreferenceModel
import org.oddgen.sqldev.plugin.PluginUtils
import org.oddgen.sqldev.resources.OddgenResources

@Loggable(LoggableConstants.DEBUG)
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

	@Loggable
	def void openBackground() {
		val folder = this
		folder.removeAll
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		if (conn != null) {
			if (folder == RootNode.instance.dbServerGenerators) {
				val dao = new DatabaseGeneratorDao(conn)
				val dbgens = dao.findAll
				Logger.info(this, "discovered %d database generators", dbgens.size)
				for (dbgen : dbgens) {
					val node = new GeneratorNode(URLFactory.newURL(folder.URL, dbgen.getName(conn)), dbgen)
					folder.add(node)
				}
			} else if (folder == RootNode.instance.clientGenerators) {
				val cgens = PluginUtils.findOddgenGenerators(PluginUtils.findJars)
				Logger.info(this, "discovered %d client generators", cgens.size)
				val preferences = PreferenceModel.getInstance(Preferences.getPreferences());
				for (cgen : cgens) {
					if (preferences.showClientGeneratorExamples &&
						cgen.name != "org.oddgen.sqldev.generators.DatabaseGenerator" ||
						cgen.name != "org.oddgen.sqldev.plugin.examples.HelloWorldClientGenerator" &&
							cgen.name != "org.oddgen.sqldev.plugin.examples.ViewClientGenerator")
								try {
									val gen = cgen.newInstance
									val node = new GeneratorNode(URLFactory.newURL(folder.URL, gen.getName(conn)), gen)
									folder.add(node)
								} catch (Exception e) {
									Logger.error(this, "Cannot populate client generator %s1 node due to %s2",
										cgen.name, e.message)
								}
						}
					}
				}
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
		