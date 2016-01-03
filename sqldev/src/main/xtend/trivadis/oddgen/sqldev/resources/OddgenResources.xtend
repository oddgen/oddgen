package trivadis.oddgen.sqldev.resources

import java.awt.Image
import javax.swing.Icon
import oracle.dbtools.raptor.utils.MessagesBase

class OddgenResources extends MessagesBase {
	private static final ClassLoader CLASS_LOADER = OddgenResources.classLoader
	private static final String CLASS_NAME = OddgenResources.canonicalName
	private static final OddgenResources INSTANCE = new OddgenResources();

	private new() {
		super(CLASS_NAME, CLASS_LOADER);
	}

	def static String getString(String paramString) {
		return INSTANCE.getStringImpl(paramString)
	}

	def static String get(String paramString) {
		return getString(paramString)
	}

	def static Image getImage(String paramString) {
		return INSTANCE.getImageImpl(paramString)
	}

	def static String format(String paramString, Object... paramVarArgs) {
		return INSTANCE.formatImpl(paramString, paramVarArgs)
	}

	def static Icon getIcon(String paramString) {
		return INSTANCE.getIconImpl(paramString)
	}

	def static Integer getInteger(String paramString) {
		return INSTANCE.getIntegerImpl(paramString)
	}
}