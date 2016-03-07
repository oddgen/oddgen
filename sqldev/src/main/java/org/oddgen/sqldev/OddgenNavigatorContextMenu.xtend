package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.Component
import java.awt.event.KeyEvent
import java.awt.event.KeyListener
import java.awt.event.MouseAdapter
import java.awt.event.MouseEvent
import oracle.ide.Context
import oracle.ide.Ide
import oracle.ide.controller.ContextMenu
import oracle.ide.controller.ContextMenuListener
import oracle.ide.controller.Controller
import oracle.ide.controller.IdeAction
import oracle.ide.model.Node
import oracle.ideimpl.explorer.CustomTree
import oracle.ideimpl.explorer.ExplorerNode

@Loggable(prepend=true)
class OddgenNavigatorContextMenu implements ContextMenuListener, Controller {
	private static final int OPEN_CMD_ID = Ide.findOrCreateCmdID("oddgen.OPEN")
	private static final int REFRESH_CMD_ID = Ide.findOrCreateCmdID("oddgen.REFRESH")
	private static final int COLLAPSEALL_CMD_ID = Ide.findOrCreateCmdID("oddgen.COLLAPSEALL")
	private static final IdeAction OPEN_ACTION = getAction(OPEN_CMD_ID)
	private static final IdeAction REFRESH_ACTION = getAction(REFRESH_CMD_ID)
	private static final IdeAction COLLAPSEALL_ACTION = getAction(COLLAPSEALL_CMD_ID)
	private static OddgenNavigatorContextMenu INSTANCE

	def private static IdeAction getAction(int actionId) {
		val action = IdeAction.get(actionId)
		action.addController(getInstance())
		return action
	}

	def static synchronized getInstance() {
		if (INSTANCE == null) {
			INSTANCE = new OddgenNavigatorContextMenu()
		}
		return INSTANCE
	}

	def attachMouseListener(Component component) {
		var tree = TreeUtils.findTree(component)
		tree.addMouseListener(
			new MouseAdapter() {
				override mousePressed(MouseEvent event) {
					if ((event.getButton() == MouseEvent.BUTTON1) && ((event.getSource() instanceof CustomTree)) &&
						((event.getSource() as CustomTree).getLastSelectedPathComponent() as ExplorerNode !== null) &&
						(((event.getSource() as CustomTree).getLastSelectedPathComponent() as ExplorerNode).
							getUserObject() !== null)) {
						val treePath = (event.getSource() as CustomTree).getPathForLocation(event.getX(), event.getY())
						if (treePath !== null) {
							val ExplorerNode explorerNode = treePath.getLastPathComponent() as ExplorerNode
							val Node node = explorerNode.getUserObject() as Node
							if ((node instanceof GeneratorNode)) {
								// TODO: 
								Logger.debug(this, "on node " + node)
							}
						}
					}
				}
			})
		tree.addKeyListener(new KeyListener() {
			override keyPressed(KeyEvent event) {
			}

			override keyReleased(KeyEvent event) {
			}

			override keyTyped(KeyEvent event) {
			}
		})
	}

	override handleDefaultAction(Context paramContext) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override menuWillHide(ContextMenu paramContextMenu) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override menuWillShow(ContextMenu paramContextMenu) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override handleEvent(IdeAction paramIdeAction, Context paramContext) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override update(IdeAction paramIdeAction, Context paramContext) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}