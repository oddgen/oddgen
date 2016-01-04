package trivadis.oddgen.sqldev

import com.jcabi.aspects.Loggable
import java.net.URL
import oracle.ide.model.DefaultContainer
import trivadis.oddgen.sqldev.model.Folder
import trivadis.oddgen.sqldev.resources.OddgenResources

@Loggable(prepend=true)
class FolderNode extends DefaultContainer {
	Folder folder;

	new () {}
	
	new (URL url) {
		this(url, null)
	}
	
	new (URL url, Folder folder) {
		super(url)
		this.folder = folder
	}
	
	override getIcon() {
		return OddgenResources.getIcon("ODDGEN_FOLDER_ICON")
	}
	
	override getLongLabel() {
		return folder?.getDescription
	}
	
	override getShortLabel() {
		return folder?.name
	}
	
	override getToolTipText() {
		return folder?.tooltip
	}
	
	def getFolder() {
		return folder;
	}	
}