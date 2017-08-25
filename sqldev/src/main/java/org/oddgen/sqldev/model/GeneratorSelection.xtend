package org.oddgen.sqldev.model

import org.eclipse.xtend.lib.annotations.Accessors
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.Node

@Accessors
class GeneratorSelection {
	private OddgenGenerator2 generator
	private Node node
}