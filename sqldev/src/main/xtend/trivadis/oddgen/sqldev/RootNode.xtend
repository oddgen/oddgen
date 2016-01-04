package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.io.IOException
import oracle.ide.model.DefaultContainer
import oracle.ide.net.URLFactory
import trivadis.oddgen.sqldev.model.Folder
import trivadis.oddgen.sqldev.resources.OddgenResources
import oracle.ide.model.UpdateMessage
import oracle.ide.model.Subject

@Loggable(value=LoggableConstants.DEBUG, prepend=true)
class RootNode extends DefaultContainer {
	private static String ROOT_NODE_NAME = OddgenResources.getString("ROOT_NODE_LONG_LABEL")
	private static String CLIENT_GEN_NAME =  OddgenResources.getString("CLIENT_GEN_NODE_LONG_LABEL")
	private static String DBSERVER_GEN_NAME =  OddgenResources.getString("DBSERVER_GEN_NODE_LONG_LABEL")
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
		val url =  URLFactory.newURL("oddgen.generators", ROOT_NODE_NAME)
		if (url == null) {
			Logger.error(this, "root node URL is null")
		}
		setURL(url)
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
		return ROOT_NODE_NAME
	}

	override getLongLabel() {
		return ROOT_NODE_NAME
	}

	override getToolTipText() {
		return ROOT_NODE_NAME
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
	
	def protected addFolder (String name) {
			val folder = new Folder()
			folder.name = name
			folder.description = name
			val folderUrl = URLFactory.newURL(getURL(), name)
			val folderNode = new FolderNode(folderUrl, folder)
			_children.add(folderNode)
			UpdateMessage.fireChildAdded(this as Subject, folderNode);
		
	}

	def initialize() {
		if (!initialized) {
			addFolder(CLIENT_GEN_NAME)
			addFolder(DBSERVER_GEN_NAME)
			// refresh tree
			UpdateMessage.fireStructureChanged(this as Subject);
			markDirty(false);
			Logger.info(this, "RootNode initialized")
			initialized = true
		}
	}
}
