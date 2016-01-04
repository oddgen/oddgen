package trivadis.oddgen.sqldev.model

import com.jcabi.aspects.Loggable
import org.eclipse.xtend.lib.annotations.Accessors

@Loggable(prepend=true)
@Accessors
class Folder {
	private String name
	private String description
	private String tooltip
}