package trivadis.oddgen.sqldev.model

import com.jcabi.aspects.Loggable
import org.eclipse.xtend.lib.annotations.Accessors
import trivadis.oddgen.sqldev.LoggableConstants

@Loggable(value=LoggableConstants.DEBUG, prepend=true)
@Accessors
class Folder {
	private String name
	private String description
	private String tooltip

	def getTooltip() {
		return if(tooltip == null) description else tooltip
	}
}