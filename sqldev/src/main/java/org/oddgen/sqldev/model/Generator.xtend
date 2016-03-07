package org.oddgen.sqldev.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Generator extends AbstractModel {
	/** name of the generator */
	String name

	/** description of the generator */
	String description
}