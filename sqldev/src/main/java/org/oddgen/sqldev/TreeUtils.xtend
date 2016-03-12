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
import java.awt.Component
import java.awt.Container
import java.awt.event.MouseAdapter
import java.awt.event.MouseEvent
import java.util.Arrays
import java.util.LinkedList
import javax.swing.JTree

@Loggable
class TreeUtils {
	def static immatateDblClick(Component paramComponent) {
		immatateDblClick(findTree(paramComponent))
	}

	def static immatateDblClick(JTree jtree) {
		jtree.addMouseListener(new MouseAdapter() {
			override void mousePressed(MouseEvent paramAnonymousMouseEvent) {
			}
		})
	}

	def static findTree(Component component) {
		val components = new LinkedList<Component>()
		components.add(component)
		while (!components.isEmpty()) {
			var comp = components.removeLast() as Component
			var Object obj
			if (comp instanceof JTree) {
				obj = comp as JTree
				return obj as JTree
			}
			if (comp instanceof Container) {
				obj = comp as Container
				components.addAll(Arrays.asList((obj as Container).getComponents()))
			}
		}
		return null
	}
}
