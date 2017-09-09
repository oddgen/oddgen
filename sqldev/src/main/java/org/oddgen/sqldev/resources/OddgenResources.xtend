package org.oddgen.sqldev.resources

import java.io.BufferedReader
import java.io.InputStreamReader
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
		try {
			val icon = INSTANCE.getIconImpl(paramString)
			return icon
		} catch (Exception e) {
			if (paramString.toLowerCase.contains("folder")) {
				return INSTANCE.getIconImpl("UNKNOWN_FOLDER_ICON")
			} else {
				return INSTANCE.getIconImpl("UNKNOWN_ICON")
			}
		}
	}

	def static getInteger(String paramString) {
		return INSTANCE.getIntegerImpl(paramString)
	}
	
	def static getTextFile(String paramString) {
		val fileName = getString(paramString)
		val url = INSTANCE.class.getResource(fileName);
		val in = new BufferedReader(new InputStreamReader(url.openStream))
		val sb = new StringBuffer
		var String line;
		while ((line = in.readLine) !== null) {
			sb.append(line)
			sb.append(System.lineSeparator)
		}
        in.close();
        return sb.toString
    }	
}