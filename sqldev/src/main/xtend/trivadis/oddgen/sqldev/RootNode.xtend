package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.io.IOException
import oracle.ide.model.DefaultContainer
import oracle.ide.net.URLFactory
import trivadis.oddgen.sqldev.model.Folder
import trivadis.oddgen.sqldev.resources.OddgenResources

@Loggable(prepend=true)
class RootNode extends DefaultContainer {
	private static RootNode INSTANCE;
	private boolean initialized = false;
	private FolderNode clientGenerators;
	private FolderNode dbServerGenerators;

	def static synchronized RootNode getInstance() {

		if (INSTANCE == null) {
			INSTANCE = new RootNode
			Logger.info(RootNode, "RootNode initialized")
		}
		return INSTANCE
	}

	private new() {
		setURL(URLFactory.newURL("oddgen.generators", OddgenResources.get("ROOT_NODE_SHORT_LABEL")))
	}

	def getClientGenerators() {
		try {
			open()
		} catch (IOException e) {
			Logger.error(this, e.message)
		}
		return clientGenerators
	}

	def getDbServerGenerators() {
		try {
			open()
		} catch (IOException e) {
			Logger.error(this, e.message)
		}
		return dbServerGenerators
	}

	override getShortLabel() {
		return OddgenResources.get("ROOT_NODE_SHORT_LABEL")
	}

	override getLongLabel() {
		return OddgenResources.getString("ROOT_NODE_LONG_LABEL")
	}

	override getToolTipText() {
		return getLongLabel()
	}

	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_FOLDER_ICON")
	}

	override protected openImpl() {
		val Runnable runnable = [|initialize]
		val thread = new Thread(runnable)
		thread.name = "oddgen Tree Opener"
		thread.start
	}

	def protected initialize() {
		if (!initialized) {
			initialized = true
			val clientFolder = new Folder()
			clientFolder.name = OddgenResources.getString("CLIENT_GEN_NODE_SHORT_LABEL")
			clientFolder.description = OddgenResources.getString("CLIENT_GEN_NODE_LONG_LABEL")
			val url = URLFactory.newURL(getURL(), clientFolder.description)
			val clientFolderNode = new FolderNode(url, clientFolder)
			_children.add(clientFolderNode)
		}

	}
}
