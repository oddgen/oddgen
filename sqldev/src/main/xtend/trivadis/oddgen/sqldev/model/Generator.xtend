package trivadis.oddgen.sqldev.model

import com.jcabi.aspects.Loggable
import oracle.ide.model.DefaultContainer
import org.eclipse.xtend.lib.annotations.Accessors

@Loggable(prepend=true)
@Accessors
class Generator extends DefaultContainer {
	private String name
	private String description
	
}