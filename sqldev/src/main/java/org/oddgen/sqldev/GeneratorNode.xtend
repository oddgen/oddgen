package org.oddgen.sqldev

import java.net.URL
import oracle.ide.model.DefaultContainer
import oracle.ide.model.UpdateMessage
import oracle.ide.net.URLFactory
import org.oddgen.sqldev.model.DatabaseGenerator
import org.oddgen.sqldev.model.Generator
import org.oddgen.sqldev.model.ObjectType
import org.oddgen.sqldev.resources.OddgenResources

class GeneratorNode extends DefaultContainer {
	private Generator generator

	new(URL url, Generator generator) {
		super(url)
		this.generator = generator
	}

	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_ICON")
	}

	override getLongLabel() {
		return generator?.getDescription
	}

	override getShortLabel() {
		return generator?.name
	}

	override getToolTipText() {
		return generator?.getDescription
	}

	override openImpl() {
		if (generator instanceof DatabaseGenerator) {
			val gen = generator as DatabaseGenerator
			for (name : gen.objectTypes) {
				val objectType = new ObjectType()
				objectType.generator = generator
				objectType.name = name
				val node = new ObjectTypeNode(URLFactory.newURL(this.URL, objectType.name), objectType)
				this.add(node)
			}
			UpdateMessage.fireStructureChanged(this)
			this.markDirty(false)
		}
	}

}
