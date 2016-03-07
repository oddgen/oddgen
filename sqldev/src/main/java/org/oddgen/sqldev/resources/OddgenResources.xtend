package org.oddgen.sqldev.resources

import oracle.dbtools.raptor.utils.MessagesBase

class OddgenResources extends MessagesBase {
	private static final ClassLoader CLASS_LOADER = OddgenResources.classLoader
	private static final String CLASS_NAME = OddgenResources.canonicalName
	private static final OddgenResources INSTANCE = new OddgenResources()

	private new() {
		super(CLASS_NAME, CLASS_LOADER)
	}

	def static getString(String paramString) {
		return INSTANCE.getStringImpl(paramString)
	}

	def static get(String paramString) {
		return getString(paramString)
	}

	def static getImage(String paramString) {
		return INSTANCE.getImageImpl(paramString)
	}

	def static format(String paramString, Object... paramVarArgs) {
		return INSTANCE.formatImpl(paramString, paramVarArgs)
	}

	def static getIcon(String paramString) {
		return INSTANCE.getIconImpl(paramString)
	}

	def static getInteger(String paramString) {
		return INSTANCE.getIntegerImpl(paramString)
	}
}