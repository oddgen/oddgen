package org.oddgen.sqldev.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Folder extends AbstractModel {
	private String name
	private String description
	private String tooltip

	def getTooltip() {
		return if(tooltip == null) description else tooltip
	}
}