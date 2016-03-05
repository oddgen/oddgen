package org.oddgen.sqldev.model

import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

abstract class AbstractModel {
	override toString() {
		new ToStringBuilder(this).addAllFields.toString
	}
}