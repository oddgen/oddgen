package trivadis.oddgen.sqldev.net

import java.net.URL
import oracle.ide.net.URLFileSystemHelper

class OddgenURLFileSystemHelper extends URLFileSystemHelper {
	public static final String PROTOCOL = "oddgen.generators";

	override lastModified(URL url) {
		return Long.MAX_VALUE;
	}
}