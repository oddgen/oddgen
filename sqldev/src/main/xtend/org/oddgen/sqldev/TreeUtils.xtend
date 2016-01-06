package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.awt.Component
import java.awt.Container
import java.awt.event.MouseAdapter
import java.awt.event.MouseEvent
import java.util.Arrays
import java.util.LinkedList
import javax.swing.JTree

@Loggable(prepend=true)
class TreeUtils {
	def static void immatateDblClick(Component paramComponent) {
		immatateDblClick(findTree(paramComponent))
	}

	def static void immatateDblClick(JTree paramJTree) {
		paramJTree.addMouseListener(new MouseAdapter() {
			override void mousePressed(MouseEvent paramAnonymousMouseEvent) {
			}
		})
	}

	def static JTree findTree(Component component) {
		val components = new LinkedList<Component>()
		components.add(component)
		while (!components.isEmpty()) {
			var comp = components.removeLast() as Component
			var Object obj
			if ((comp instanceof JTree)) {
				obj = comp as JTree
				return obj as JTree
			}
			if ((comp instanceof Container)) {
				obj = comp as Container
				components.addAll(Arrays.asList((obj as Container).getComponents()))
			}
		}
		return null
	}
}
