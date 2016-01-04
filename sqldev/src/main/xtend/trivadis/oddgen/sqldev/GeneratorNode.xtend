package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.net.URL
import oracle.ide.model.DefaultContainer
import trivadis.oddgen.sqldev.model.Generator
import trivadis.oddgen.sqldev.resources.OddgenResources

@Loggable(value=LoggableConstants.DEBUG, prepend=true)
class GeneratorNode extends DefaultContainer {
	private Generator generator

	new() {
	}

	new(URL url) {
		this(url, null)
	}

	new(URL url, Generator generator) {
		super(url)
		this.generator = generator
	}

	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_ICON")
	}

	override getLongLabel() {
		return generator?.getDescription
	}

	override getShortLabel() {
		return generator?.name
	}

	override getToolTipText() {
		return generator?.getDescription
	}

	def getGenerator() {
		return generator;
	}
}