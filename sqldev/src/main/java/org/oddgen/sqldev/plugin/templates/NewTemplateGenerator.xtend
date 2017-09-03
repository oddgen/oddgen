package org.oddgen.sqldev.plugin.templates

import java.sql.Connection
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.Node

class NewTemplateGenerator implements OddgenGenerator2 {

	public static var TEMPLATE_NAME = "Template name"
	public static var GENERATE_FILES = "Generate files?"
	public static var OUTPUT_DIR = "Output directory"
	public static var PACKAGE_NAME = "Package name"
	public static var CLASS_NAME = "Class name"
	public static var DISPLAY_NAME = "Display name"
	public static var DESCRIPTION = "Description"
	public static var OBJECT_TYPES = "Object types"
	public static var PARAMETERS = "Parameters"
	public static var GENERATE_LOV = "Generate list of values?"

	override getName(Connection conn) {
		return "New..."
	}

	override getDescription(Connection conn) {
		return "Generate a new generator based on a template and parameters"
	}

	override getFolders(Connection conn) {
		return #["Templates"]
	}

	override getHelp(Connection conn) {
		return "<p>not yet available</p>"
	}

	override getNodes(Connection conn, String parentNodeId) {
		val params = new LinkedHashMap<String, String>()
		params.put(TEMPLATE_NAME, "PL/SQL")
		//params.put(GENERATE_FILES, "No")
		params.put(OUTPUT_DIR, "")
		params.put(PACKAGE_NAME, "")
		params.put(CLASS_NAME, "")
		params.put(DISPLAY_NAME, "")
		//params.put(DESCRIPTION, "")
		params.put(OBJECT_TYPES, "TABLE,VIEW")
		params.put(PARAMETERS, "p1,p2?")
		//params.put(GENERATE_LOV, "Yes")
		val node = new Node
		node.id = "template"
		node.params = params
		node.leaf = true
		node.generatable = true
		return #[node]
	}

	override getLov(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val lov = new HashMap<String, List<String>>()
		lov.put(TEMPLATE_NAME, #["PL/SQL", "Xtend"])
		lov.put(GENERATE_FILES, #["Yes", "No"])
		lov.put(GENERATE_LOV, #["Yes", "No"])
		return lov
	}

	override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
		val paramStates = new HashMap<String, Boolean>()
		paramStates.put(CLASS_NAME, params.get(TEMPLATE_NAME) == "Xtend")
		return paramStates
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
		return "todo"
	}

}
