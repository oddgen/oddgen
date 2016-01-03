package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import oracle.ide.model.DefaultContainer
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import trivadis.oddgen.sqldev.resources.OddgenResources

class RootNode extends DefaultContainer {
	static final Logger logger = LoggerFactory.getLogger(OddgenNavigatorWindow.name)
	private static RootNode instance;

	@Loggable(prepend=true)
	def static RootNode getInstance() {
		if (instance == null) {
			instance = new RootNode
			logger.info("RootNode initialized")
		}
		return instance
	}

	override def getShortLabel() {
		return OddgenResources.getString("ROOT_NODE_SHORT_LABEL")
	}

	override def getLongLabel() {
		return OddgenResources.getString("ROOT_NODE_LONG_LABEL")
	}
	
	override def getIcon() {
		return OddgenResources.getIcon("ODDGEN_FOLDER_ICON")
	}
}
