package org.oddgen.sqldev.model

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class ObjectType extends AbstractModel {
	Generator generator
	String name
}