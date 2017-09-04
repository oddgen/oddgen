package org.oddgen.sqldev.plugin.templates

import java.sql.Connection
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.Node

class NewPlsqlGenerator implements OddgenGenerator2 {

	public static val PACKAGE_NAME = "Package name"
	public static val OUTPUT_DIR = "Output directory"

	override getName(Connection conn) {
		return "New PL/SQL oddgen plugin"
	}

	override getDescription(Connection conn) {
		return "Generate a new oddgen PL/SQL plugin"
	}

	override getFolders(Connection conn) {
		return #["Templates"]
	}

	override getHelp(Connection conn) {
		return "<p>not yet available</p>"
	}

	override getNodes(Connection conn, String parentNodeId) {
		val params = new LinkedHashMap<String, String>()
		params.put(PACKAGE_NAME, "NEW_GENERATOR")
		params.put(OUTPUT_DIR, "")
		val node = new Node
		node.id = "new"
		node.params = params
		node.leaf = true
		node.generatable = true
		return #[node]
	}

	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return new HashMap<String, List<String>>
	}

	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		return new HashMap<String, Boolean>
	}

	override generateProlog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generateSeparator(Connection conn) {
		return ""
	}

	override generateEpilog(Connection conn, List<Node> nodes) {
		return ""
	}

	override generate(Connection conn, Node node) {
		return '''
			if output directory is empty the worksheet contains
			- oddgen_types (if no object exists with that name in target schema)
			- generator packae specfication
			- generator package body
			
			if the output directory is defined, the following four files are generated:
			- install.sql
			- oddgen_types.pks
			- «node.params.get(PACKAGE_NAME).toLowerCase».pks
			- «node.params.get(PACKAGE_NAME).toLowerCase».pkb
			plus some information in the worksheet.
		'''
	}

}
