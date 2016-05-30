package org.oddgen.sqldev.model

import java.util.LinkedHashMap
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class GeneratorSelection {
	private ObjectName objectName
	private LinkedHashMap<String, String> params
}