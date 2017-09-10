/*
 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.oddgen.sqldev.plugin.templates

import java.io.File
import java.sql.Connection
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.List
import java.util.regex.Pattern
import oracle.ide.config.Preferences
import org.oddgen.sqldev.generators.OddgenGenerator2
import org.oddgen.sqldev.generators.model.Node
import org.oddgen.sqldev.model.PreferenceModel
import org.oddgen.sqldev.plugin.PluginUtils
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.SingleConnectionDataSource

class NewXtendSqlDeveloperExtension implements OddgenGenerator2 {

	public static val CLASS_NAME = "Class name"
	public static val PACKAGE_NAME = "Package name"
	public static val OUTPUT_DIR = "Output directory"

	var JdbcTemplate jdbcTemplate
	var Node node
	var Connection conn
	var String extensionId
	val extension TemplateTools templateTools = new TemplateTools
	val preferences = PreferenceModel.getInstance(Preferences.getPreferences());
	
	def private bundleXmlTemplate() '''
		<update-bundle version="1.0"
			xmlns="http://xmlns.oracle.com/jdeveloper/updatebundle" xmlns:u="http://xmlns.oracle.com/jdeveloper/update">
			<u:update id="«extensionId»">
				<u:name>#EXTENSION_NAME#</u:name>
				<u:version>#EXTENSION_VERSION#</u:version>
				<u:author>#EXTENSION_OWNER#</u:author>
				<u:author-url>https://www.oddgen.org/</u:author-url>
				<u:description><![CDATA[SQL Developer oddgen plugin «node.params.get(CLASS_NAME)».]]></u:description>
			</u:update>
		</update-bundle>
	'''

	def private extensionXmlTemplate() '''
		<extension id="«extensionId»" version="#EXTENSION_VERSION#"
			esdk-version="2.0" xmlns="http://jcp.org/jsr/198/extension-manifest"
			rsbundle-class="«node.params.get(PACKAGE_NAME)».resources.Resources">
			<name rskey="EXTENSION_NAME" />
			<owner rskey="EXTENSION_OWNER" />
			<trigger-hooks xmlns="http://xmlns.oracle.com/ide/extension">
				<triggers>
					<settings-ui-hook>
						<page id="ODDGEN_«node.params.get(CLASS_NAME).toUpperCase»_PREFERENCES_PAGE" parent-idref="/preferences">
							<label>${PREF_LABEL}</label>
							<traversable-class>«node.params.get(PACKAGE_NAME)».PreferencePanel
							</traversable-class>
						</page>
					</settings-ui-hook>
				</triggers>
			</trigger-hooks>
		</extension>
	'''

	def private pomXmlTemplate() '''
		<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
			<modelVersion>4.0.0</modelVersion>

			<!-- The Basics -->
			<groupId>org.oddgen</groupId>
			<artifactId>«extensionId»</artifactId>
			<version>1.0.0-SNAPSHOT</version>
			<packaging>bundle</packaging>
			<properties>
				<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
				<jdk.version>1.7</jdk.version>
				<jdk.version.test>1.8</jdk.version.test>
				<xtend.version>2.12.0</xtend.version>
				<sqldev.basedir>«PluginUtils.sqlDevExtensionDir.parentFile.parentFile.absolutePath»</sqldev.basedir>
				<final.name>«node.params.get(CLASS_NAME).toLowerCase»_for_SQLDev-${project.version}</final.name>
			</properties>
			<dependencies>
				<!-- SQL Developer specific dependencies (not available in public Maven repositories) -->
				<dependency>
					<groupId>oracle</groupId>
					<artifactId>idert</artifactId>
					<version>12.2.0</version>
					<scope>system</scope>
					<systemPath>${sqldev.basedir}/ide/lib/idert.jar</systemPath>
				</dependency>
				<dependency>
					<groupId>oracle</groupId>
					<artifactId>javax-ide</artifactId>
					<version>12.2.0</version>
					<scope>system</scope>
					<systemPath>${sqldev.basedir}/ide/lib/javax-ide.jar</systemPath>
				</dependency>
				<dependency>
					<groupId>oracle</groupId>
					<artifactId>javatools-nodeps</artifactId>
					<version>12.2.0</version>
					<scope>system</scope>
					<systemPath>${sqldev.basedir}/modules/oracle.javatools/javatools-nodeps.jar</systemPath>
				</dependency>
				<dependency>
					<groupId>oracle</groupId>
					<artifactId>oracle.ide</artifactId>
					<version>12.2.0</version>
					<scope>system</scope>
					<systemPath>${sqldev.basedir}/ide/extensions/oracle.ide.jar</systemPath>
				</dependency>
				<dependency>
					<groupId>oracle</groupId>
					<artifactId>oracle.dbtools-common</artifactId>
					<version>12.2.0</version>
					<scope>system</scope>
					<systemPath>${sqldev.basedir}/sqldeveloper/lib/oracle.dbtools-common.jar</systemPath>
				</dependency>
				<dependency>
					<groupId>oracle</groupId>
					<artifactId>uic</artifactId>
					<version>12.2.2</version>
					<scope>system</scope>
					<systemPath>${sqldev.basedir}/ide/lib/uic.jar</systemPath>
				</dependency>
				<dependency>
					<groupId>oracle</groupId>
					<artifactId>ojdbc8</artifactId>
					<version>12.2.0</version>
					<scope>system</scope>
					<systemPath>${sqldev.basedir}/jdbc/lib/ojdbc8.jar</systemPath>
				</dependency>

				<!-- ordinary dependencies -->
				<dependency>
					<groupId>org.oddgen</groupId>
					<artifactId>org.oddgen.sqldev</artifactId>
					<version>0.3.0</version>
					<scope>provided</scope>
				</dependency>
				<!-- transient dependencies of org.oddgen.sqldev, workaround, see https://github.com/oddgen/oddgen/issues/24 -->
				<dependency>
					<groupId>org.eclipse.xtend</groupId>
					<artifactId>org.eclipse.xtend.lib</artifactId>
					<version>${xtend.version}</version>
					<scope>provided</scope>
				</dependency>
				<dependency>
					<groupId>org.springframework</groupId>
					<artifactId>spring-jdbc</artifactId>
					<version>4.3.10.RELEASE</version>
					<scope>provided</scope>
				</dependency>
				<!-- test dependencies -->
				<dependency>
					<groupId>junit</groupId>
					<artifactId>junit</artifactId>
					<version>4.12</version>
					<scope>test</scope>
				</dependency>
			</dependencies>

			<!-- Build Settings -->
			<build>
				<sourceDirectory>${project.basedir}/src/main/java</sourceDirectory>
				<testSourceDirectory>${project.basedir}/src/test/java</testSourceDirectory>
				<resources>
					<resource>
						<directory>src/main/resources</directory>
						<includes>
							<include>**/*.*</include>
						</includes>
					</resource>
				</resources>
				<plugins>
					<plugin>
						<groupId>org.eclipse.xtend</groupId>
						<artifactId>xtend-maven-plugin</artifactId>
						<!-- change version might need "mvn -U" to update snapshots -->
						<version>${xtend.version}</version>
						<executions>
							<execution>
								<id>main</id>
								<goals>
									<goal>compile</goal>
								</goals>
								<configuration>
									<javaSourceVersion>${jdk.version}</javaSourceVersion>
									<outputDirectory>${project.basedir}/src/main/xtend-gen</outputDirectory>
								</configuration>
							</execution>
							<execution>
								<id>test</id>
								<goals>
									<goal>testCompile</goal>
								</goals>
								<configuration>
									<javaSourceVersion>${jdk.version.test}</javaSourceVersion>
									<testOutputDirectory>${project.basedir}/src/test/xtend-gen</testOutputDirectory>
								</configuration>
							</execution>
						</executions>
					</plugin>
					<plugin>
						<groupId>org.apache.maven.plugins</groupId>
						<version>3.7.0</version>
						<artifactId>maven-compiler-plugin</artifactId>
						<configuration>
							<source>${jdk.version}</source>
							<target>${jdk.version}</target>
							<!-- used by Maven build -->
							<testSource>${jdk.version.test}</testSource>
							<testTarget>${jdk.version.test}</testTarget>
							<includes>
								<include>**/*.java</include>
							</includes>
						</configuration>
						<executions>
							<!-- used by Eclipse when updating project -->
							<execution>
								<id>test-compile</id>
								<phase>process-test-sources</phase>
								<goals>
									<goal>testCompile</goal>
								</goals>
								<configuration>
									<source>${jdk.version.test}</source>
									<target>${jdk.version.test}</target>
								</configuration>
							</execution>
						</executions>
					</plugin>
					<plugin>
						<groupId>org.apache.maven.plugins</groupId>
						<artifactId>maven-surefire-plugin</artifactId>
						<version>2.20</version>
						<configuration>
							<!-- -noverify is required in some environments to avoid java.lang.VerifyError -->
							<argLine>-noverify
								-Djava.util.logging.config.file=${project.basedir}/src/test/resources/logging.conf</argLine>
							<includes>
								<include>**/*.java</include>
							</includes>
						</configuration>
					</plugin>
					<plugin>
						<groupId>org.codehaus.mojo</groupId>
						<artifactId>buildnumber-maven-plugin</artifactId>
						<!-- version inherited from plugin section -->
						<executions>
							<execution>
								<phase>validate</phase>
								<goals>
									<goal>create</goal>
								</goals>
							</execution>
						</executions>
						<configuration>
							<format>{0,date,yyyyMMdd.HHmmss}</format>
							<items>
								<item>timestamp</item>
							</items>
						</configuration>
					</plugin>
					<plugin>
						<groupId>org.apache.maven.plugins</groupId>
						<artifactId>maven-antrun-plugin</artifactId>
						<version>1.8</version>
						<executions>
							<execution>
								<phase>prepare-package</phase>
								<configuration>
									<target>
										<copy failonerror="true" file="sqldeveloper.xml" tofile="target/sqldeveloper.xml" />
										<copy failonerror="true" file="bundle.xml" tofile="target/bundle.xml" />
										<copy failonerror="true" file="extension.xml"
											tofile="target/classes/META-INF/extension.xml" />
									</target>
								</configuration>
								<goals>
									<goal>run</goal>
								</goals>
							</execution>
						</executions>
					</plugin>
					<plugin>
						<groupId>org.codehaus.mojo</groupId>
						<artifactId>properties-maven-plugin</artifactId>
						<version>1.0.0</version>
						<executions>
							<execution>
								<phase>initialize</phase>
								<goals>
									<goal>read-project-properties</goal>
								</goals>
								<configuration>
									<urls>
										<url>
											file:///${project.basedir}/src/main/resources/«node.params.get(PACKAGE_NAME).replace(".", "/")»/resources/Resources.properties
										</url>
									</urls>
								</configuration>
							</execution>
						</executions>
					</plugin>
					<plugin>
						<groupId>org.codehaus.mojo</groupId>
						<artifactId>build-helper-maven-plugin</artifactId>
						<version>3.0.0</version>
						<executions>
							<execution>
								<id>parse-version</id>
								<goals>
									<goal>parse-version</goal>
								</goals>
							</execution>
						</executions>
					</plugin>
					<plugin>
						<groupId>com.google.code.maven-replacer-plugin</groupId>
						<artifactId>replacer</artifactId>
						<version>1.5.3</version>
						<executions>
							<execution>
								<phase>prepare-package</phase>
								<goals>
									<goal>replace</goal>
								</goals>
							</execution>
						</executions>
						<configuration>
							<includes>
								<include>${project.basedir}/target/sqldeveloper.xml</include>
								<include>${project.basedir}/target/bundle.xml</include>
								<include>${project.basedir}/target/classes/META-INF/extension.xml</include>
							</includes>
							<replacements>
								<replacement>
									<token>#EXTENSION_VERSION#</token>
									<value>${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.incrementalVersion}.${buildNumber}</value>
								</replacement>
								<replacement>
									<token>#EXTENSION_SHORT_VERSION#</token>
									<value>${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.incrementalVersion}</value>
								</replacement>
								<replacement>
									<token>#EXTENSION_DEPLOYABLE#</token>
									<value>${final.name}.zip</value>
								</replacement>
								<replacement>
									<token>#EXTENSION_NAME#</token>
									<value>${EXTENSION_NAME}</value>
								</replacement>
								<replacement>
									<token>#EXTENSION_OWNER#</token>
									<value>${EXTENSION_OWNER}</value>
								</replacement>
							</replacements>
						</configuration>
					</plugin>
					<plugin>
						<groupId>org.apache.felix</groupId>
						<artifactId>maven-bundle-plugin</artifactId>
						<version>3.3.0</version>
						<extensions>true</extensions>
						<configuration>
							<finalName>${project.name}</finalName>
							<archive>
								<addMavenDescriptor>false</addMavenDescriptor>
							</archive>
							<instructions>
								<Bundle-SymbolicName>${project.name}</Bundle-SymbolicName>
								<Bundle-Version>${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.incrementalVersion}</Bundle-Version>
								<Bundle-Build>${buildNumber}</Bundle-Build>
								<Include-Resource>
									{maven-resources},
									{maven-dependencies},
									META-INF/extension.xml=target/classes/META-INF/extension.xml
								</Include-Resource>
								<Export-Package>
									«node.params.get(PACKAGE_NAME)»,
									«node.params.get(PACKAGE_NAME)».resources
								</Export-Package>
								<_exportcontents>
									org.eclipse.xtext.xbase.lib
								</_exportcontents>
								<Require-Bundle>
									org.oddgen.sqldev,
									oracle.javatools-nodeps,
									oracle.idert,
									oracle.ide,
									oracle.ide.db,
									oracle.sqldeveloper,
									oracle.uic
								</Require-Bundle>
								<Import-Package>!*</Import-Package>
								<Embed-Directory>lib</Embed-Directory>
								<Embed-Transitive>true</Embed-Transitive>
								<Embed-Dependency>*;scope=compile|runtime</Embed-Dependency>
							</instructions>
						</configuration>
					</plugin>
					<plugin>
						<artifactId>maven-assembly-plugin</artifactId>
						<version>3.0.0</version>
						<configuration>
							<finalName>${final.name}</finalName>
							<appendAssemblyId>false</appendAssemblyId>
							<descriptors>
								<descriptor>sqldev_assembly.xml</descriptor>
							</descriptors>
							<recompressZippedFiles>true</recompressZippedFiles>
						</configuration>
						<executions>
							<execution>
								<id>deploy-assembly</id>
								<phase>package</phase>
								<goals>
									<goal>single</goal>
								</goals>
							</execution>
						</executions>
					</plugin>
				</plugins>
				<pluginManagement>
					<plugins>
						<plugin>
							<groupId>org.eclipse.m2e</groupId>
							<artifactId>lifecycle-mapping</artifactId>
							<version>1.0.0</version>
							<configuration>
								<lifecycleMappingMetadata>
									<pluginExecutions>
										<pluginExecution>
											<pluginExecutionFilter>
												<groupId>org.apache.maven.plugins</groupId>
												<artifactId>maven-dependency-plugin</artifactId>
												<versionRange>[3.0.1,)</versionRange>
												<goals>
													<goal>copy-dependencies</goal>
												</goals>
											</pluginExecutionFilter>
											<action>
												<ignore />
											</action>
										</pluginExecution>
										<pluginExecution>
											<pluginExecutionFilter>
												<groupId>
													org.codehaus.mojo
												</groupId>
												<artifactId>
													build-helper-maven-plugin
												</artifactId>
												<versionRange>
													[3.0.0,)
												</versionRange>
												<goals>
													<goal>parse-version</goal>
												</goals>
											</pluginExecutionFilter>
											<action>
												<ignore></ignore>
											</action>
										</pluginExecution>
									</pluginExecutions>
								</lifecycleMappingMetadata>
							</configuration>
						</plugin>
						<plugin>
							<groupId>org.codehaus.mojo</groupId>
							<artifactId>buildnumber-maven-plugin</artifactId>
							<version>1.4</version>
						</plugin>
					</plugins>
				</pluginManagement>
			</build>

			<!-- Environment Settings -->
			<scm>
				<!-- Required for buildnumber-maven-plugin -->
				<!-- Works if the repository does not exist, but throws a warning --> 
				<connection>scm:git:git://github.com/«node.params.get(CLASS_NAME).toLowerCase».git</connection>
			</scm>
		</project>
	'''

	def private sqldevAssemblyXmlTemplate() '''
		<assembly
			xmlns="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://maven.apache.org/plugins/maven-assembly-plugin/assembly/1.1.2 http://maven.apache.org/xsd/assembly-1.1.2.xsd">
			<id>bin</id>
			<formats>
				<format>zip</format>
			</formats>
			<includeBaseDirectory>false</includeBaseDirectory>
			<fileSets>
				<fileSet>
					<directory>${project.build.directory}</directory>
					<outputDirectory>${file.separator}</outputDirectory>
					<includes>
						<include>${project.name}.jar</include>
					</includes>
				</fileSet>
				<fileSet>
					<directory>${project.build.directory}</directory>
					<outputDirectory>${file.separator}META-INF</outputDirectory>
					<includes>
						<include>bundle.xml</include>
					</includes>
				</fileSet>
			</fileSets>
		</assembly>
	'''
	
	def private sqldeveloperXmlTemplate() '''
		<?xml version="1.0" encoding="UTF-8" ?>
		<updates version="2.0"
		  xmlns="http://xmlns.oracle.com/jdeveloper/updatecenter"
		  xmlns:u="http://xmlns.oracle.com/jdeveloper/update">
		    <u:update id="«extensionId»">
		        <u:name>#EXTENSION_NAME#</u:name>
		        <u:version>#EXTENSION_VERSION#</u:version>
		        <u:author>#EXTENSION_OWNER#</u:author>
		        <u:author-url>https://www.oddgen.org/</u:author-url>
				<u:description><![CDATA[SQL Developer oddgen plugin «node.params.get(CLASS_NAME)».]]></u:description>
		        <u:bundle-url>https://github.com/oddgen/«node.params.get(CLASS_NAME).toLowerCase»/releases/download/v#EXTENSION_SHORT_VERSION#/#EXTENSION_DEPLOYABLE#</u:bundle-url>
		    </u:update>
		</updates>
	'''

	def private generatorXtendTemplate() '''
		/*
		 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
		 * 
		 * Licensed under the Apache License, Version 2.0 (the "License");
		 * you may not use this file except in compliance with the License.
		 * You may obtain a copy of the License at
		 * 
		 *     http://www.apache.org/licenses/LICENSE-2.0
		 * 
		 * Unless required by applicable law or agreed to in writing, software
		 * distributed under the License is distributed on an "AS IS" BASIS,
		 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		 * See the License for the specific language governing permissions and
		 * limitations under the License.
		 */
		package «node.params.get(PACKAGE_NAME)»

		import java.sql.Connection
		import java.util.ArrayList
		import java.util.HashMap
		import java.util.LinkedHashMap
		import java.util.List
		import oracle.ide.config.Preferences
		import org.oddgen.sqldev.dal.DalTools
		import org.oddgen.sqldev.generators.OddgenGenerator2
		import org.oddgen.sqldev.generators.model.Node
		import org.springframework.jdbc.core.BeanPropertyRowMapper
		import org.springframework.jdbc.core.JdbcTemplate
		import org.springframework.jdbc.datasource.SingleConnectionDataSource
		
		class «node.params.get(CLASS_NAME)» implements OddgenGenerator2 {
		
			public static var P1 = "P1?"
			public static var P2 = "P2"
			public static var P3 = "P3"

			override isSupported(Connection conn) {
				return (new DalTools(conn)).isAtLeastOracle(9,2)
			}
		
			override getName(Connection conn) {
				return "«node.params.get(CLASS_NAME).toFirstUpper»"
			}
		
			override getDescription(Connection conn) {
				return "«node.params.get(CLASS_NAME).toFirstUpper»"
			}
		
			override getFolders(Connection conn) {
				val preferences = PreferenceModel.getInstance(Preferences.getPreferences());
				val folders = new ArrayList<String>
				for (f : preferences.folder.split(",").filter[!it.empty]) {
					folders.add(f.trim)
				}
				return folders
			}
		
			override getHelp(Connection conn) {
				return "<p>not yet available</p>"
			}
		
			override getNodes(Connection conn, String parentNodeId) {
				val params = new LinkedHashMap<String, String>()
				params.put(P1, "Yes")
				params.put(P2, "Value 1")
				params.put(P3, "Some value")
				if (parentNodeId === null || parentNodeId.empty) {
					val tableNode = new Node
					tableNode.id = "TABLE"
					tableNode.params = params
					tableNode.leaf = false
					tableNode.generatable = true
					tableNode.multiselectable = true
					val viewNode = new Node
					viewNode.id = "VIEW"
					viewNode.params = params
					viewNode.leaf = false
					viewNode.generatable = true
					viewNode.multiselectable = true
					return #[tableNode, viewNode]
				} else {
					val sql = «"'''"»
						SELECT object_type || '.' || object_name AS id,
						       object_type AS parent_id,
						       1 AS leaf,
						       1 AS generatable,
						       1 AS multiselectable
						  FROM user_objects
						 WHERE object_type = ?
						   AND generated = 'N'
					«"'''"»
					val jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
					val nodes = jdbcTemplate.query(sql, new BeanPropertyRowMapper<Node>(Node), #[parentNodeId])
					for (node : nodes) {
						node.params = params
					}
					return nodes
				}
			}
		
			override HashMap<String, List<String>> getLov(Connection conn, LinkedHashMap<String, String> params,
				List<Node> nodes) {
				val lov = new HashMap<String, List<String>>()
				lov.put(P1, #["Yes", "No"])
				lov.put(P2, #["Value 1", "Value 2", "Value 3"])
				return lov
			}
		
			override getParamStates(Connection conn, LinkedHashMap<String, String> params, List<Node> nodes) {
				val paramStates = new HashMap<String, Boolean>()
				paramStates.put(P2, params.get(P1) == "Yes")
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
		
			override generate(Connection conn, Node node) «"'''"»
				-- «"«"»node.id«"»"» «"«"»node.params.get(P1)«"»"» «"«"»node.params.get(P2)«"»"» «"«"»node.params.get(P3)«"»"»
			«"'''"»
		}
	'''
	
	def private PreferenceModelXtendTemplate() '''
		/*
		 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
		 * 
		 * Licensed under the Apache License, Version 2.0 (the "License");
		 * you may not use this file except in compliance with the License.
		 * You may obtain a copy of the License at
		 * 
		 *     http://www.apache.org/licenses/LICENSE-2.0
		 * 
		 * Unless required by applicable law or agreed to in writing, software
		 * distributed under the License is distributed on an "AS IS" BASIS,
		 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		 * See the License for the specific language governing permissions and
		 * limitations under the License.
		 */
		package «node.params.get(PACKAGE_NAME)»
		
		import oracle.javatools.data.HashStructure
		import oracle.javatools.data.HashStructureAdapter
		import oracle.javatools.data.PropertyStorage
		import org.eclipse.xtext.xbase.lib.util.ToStringBuilder
		
		class PreferenceModel extends HashStructureAdapter {
			static final String DATA_KEY = "«extensionId»"
		
			private new(HashStructure hash) {
				super(hash)
			}
		
			def static getInstance(PropertyStorage prefs) {
				return new PreferenceModel(findOrCreate(prefs, DATA_KEY))
			}
		
			static final String KEY_FOLDER = "folder"
		
			def getFolder() {
				return getHashStructure.getString(PreferenceModel.KEY_FOLDER, "«preferences.defaultClientGeneratorFolder»")
			}
		
			def setFolder(String folder) {
				getHashStructure.putString(PreferenceModel.KEY_FOLDER, folder)
			}
		
			override toString() {
				new ToStringBuilder(this).addAllFields.toString
			}
		}
	'''
	
	def private preferencePanelXtendTemplate() '''
		/*
		 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
		 * 
		 * Licensed under the Apache License, Version 2.0 (the "License");
		 * you may not use this file except in compliance with the License.
		 * You may obtain a copy of the License at
		 * 
		 *     http://www.apache.org/licenses/LICENSE-2.0
		 * 
		 * Unless required by applicable law or agreed to in writing, software
		 * distributed under the License is distributed on an "AS IS" BASIS,
		 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		 * See the License for the specific language governing permissions and
		 * limitations under the License.
		 */
		package «node.params.get(PACKAGE_NAME)»
		
		import javax.swing.JTextField
		import oracle.ide.panels.DefaultTraversablePanel
		import oracle.ide.panels.TraversableContext
		import oracle.ide.panels.TraversalException
		import oracle.javatools.ui.layout.FieldLayoutBuilder
		import «node.params.get(PACKAGE_NAME)».PreferenceModel
		import «node.params.get(PACKAGE_NAME)».resources.Resources
		
		class PreferencePanel extends DefaultTraversablePanel {
			val JTextField folderTextField = new JTextField
		
			new() {
				layoutControls()
			}
		
			def private layoutControls() {
				val FieldLayoutBuilder builder = new FieldLayoutBuilder(this)
				builder.alignLabelsLeft = true
				builder.add(
					builder.field.label.withText(Resources.getString("PREF_FOLDER_LABEL")).component(folderTextField))
				builder.addVerticalSpring
			}
		
			override onEntry(TraversableContext traversableContext) {
				var PreferenceModel info = traversableContext.userInformation
				folderTextField.text = info.folder
				super.onEntry(traversableContext)
			}
		
			override onExit(TraversableContext traversableContext) throws TraversalException {
				var PreferenceModel info = traversableContext.userInformation
				info.folder = folderTextField.text
				super.onExit(traversableContext)
			}
		
			def private static PreferenceModel getUserInformation(TraversableContext tc) {
				return PreferenceModel.getInstance(tc.propertyStorage)
			}
		}
	'''
	
	def private resourcesXtendTemplate() '''
		/*
		 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
		 * 
		 * Licensed under the Apache License, Version 2.0 (the "License");
		 * you may not use this file except in compliance with the License.
		 * You may obtain a copy of the License at
		 * 
		 *     http://www.apache.org/licenses/LICENSE-2.0
		 * 
		 * Unless required by applicable law or agreed to in writing, software
		 * distributed under the License is distributed on an "AS IS" BASIS,
		 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		 * See the License for the specific language governing permissions and
		 * limitations under the License.
		 */
		package «node.params.get(PACKAGE_NAME)».resources
		
		import oracle.dbtools.raptor.utils.MessagesBase
		
		class Resources extends MessagesBase {
			private static final ClassLoader CLASS_LOADER = Resources.classLoader
			private static final String CLASS_NAME = Resources.canonicalName
			private static final Resources INSTANCE = new Resources()
		
			private new() {
				super(CLASS_NAME, CLASS_LOADER)
			}
		
			def static getString(String paramString) {
				return INSTANCE.getStringImpl(paramString)
			}
		
			def static get(String paramString) {
				return getString(paramString)
			}
		
			def static getImage(String paramString) {
				return INSTANCE.getImageImpl(paramString)
			}
		
			def static format(String paramString, Object... paramVarArgs) {
				return INSTANCE.formatImpl(paramString, paramVarArgs)
			}
		
			def static getIcon(String paramString) {
				return INSTANCE.getIconImpl(paramString)
			}
		
			def static getInteger(String paramString) {
				return INSTANCE.getIntegerImpl(paramString)
			}
		}
	'''
	
	def private resourcesPropertiesTemplate() '''
		# English (default) resources for extension «extensionId»
		
		# Externally used constants (pom.xml, bundle.xml, extension.xml, sqldeveloper.xml)
		EXTENSION_NAME=«node.params.get(CLASS_NAME)» for SQL Developer
		EXTENSION_OWNER=Philipp Salvisberg
		
		# Translatable text
		PREF_LABEL=«node.params.get(CLASS_NAME)»
		PREF_FOLDER_LABEL=Root folder
	'''

	def private generatorTestXtendTemplate() '''
		/*
		 * Copyright 2017 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
		 * 
		 * Licensed under the Apache License, Version 2.0 (the "License");
		 * you may not use this file except in compliance with the License.
		 * You may obtain a copy of the License at
		 * 
		 *     http://www.apache.org/licenses/LICENSE-2.0
		 * 
		 * Unless required by applicable law or agreed to in writing, software
		 * distributed under the License is distributed on an "AS IS" BASIS,
		 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		 * See the License for the specific language governing permissions and
		 * limitations under the License.
		 */
		package «node.params.get(PACKAGE_NAME)».tests
		
		import java.util.Properties
		import org.junit.Assert
		import org.junit.Before
		import org.junit.Test
		import «node.params.get(PACKAGE_NAME)».«node.params.get(CLASS_NAME)»
		import org.oddgen.sqldev.generators.OddgenGenerator2
		import org.springframework.jdbc.core.JdbcTemplate
		import org.springframework.jdbc.datasource.SingleConnectionDataSource
		
		class «node.params.get(CLASS_NAME)»Test {
			var SingleConnectionDataSource dataSource
			var JdbcTemplate jdbcTemplate
			var OddgenGenerator2 gen
		
			@Before
			def void setup() {
				val p = new Properties()
				p.load(this.getClass().getResourceAsStream("/test.properties"))
				dataSource = new SingleConnectionDataSource()
				dataSource.driverClassName = "oracle.jdbc.OracleDriver"
				if (!p.getProperty("sid").empty) {
					dataSource.url = «"'''"»jdbc:oracle:thin:@«"«"»p.getProperty("host")«"»"»:«"«"»p.getProperty("port")«"»"»:«"«"»p.getProperty("sid")«"»"»«"'''"»
				} else {
					dataSource.url = «"'''"»jdbc:oracle:thin:@«"«"»p.getProperty("host")«"»"»:«"«"»p.getProperty("port")«"»"»/«"«"»p.getProperty("service")«"»"»«"'''"»
				}
				dataSource.username = p.getProperty("username")
				dataSource.password = p.getProperty("password")
				jdbcTemplate = new JdbcTemplate(dataSource)
				gen = new «node.params.get(CLASS_NAME)»
			}
			
			@Test
			def isSupportedTest() {
				if (!dataSource.password.empty) {
					Assert.assertTrue(gen.isSupported(dataSource.connection))
				}
			}
			
			@Test
			def getNameTest() {
				Assert.assertEquals("«node.params.get(CLASS_NAME)»", gen.getName(null))
			}
		
			@Test
			def getDescriptionTest() {
				Assert.assertEquals("«node.params.get(CLASS_NAME)»", gen.getDescription(null))
			}
			
			@Test
			def getFoldersTest() {
				Assert.assertEquals(#[«FOR f : preferences.defaultClientGeneratorFolder.split(",") SEPARATOR ", "»"«f.trim»"«ENDFOR»], gen.getFolders(null))
			}
		
			@Test
			def getHelpTest() {
				Assert.assertFalse(gen.getFolders(null).empty)
			}
			
			@Test
			def getNodesTest() {
				Assert.assertEquals(#["TABLE", "VIEW"], gen.getNodes(null, null).map[it.id])
				if (dataSource.username.equalsIgnoreCase("SCOTT") &&  !dataSource.password.empty) {
					val nodes = gen.getNodes(dataSource.connection, "TABLE")
					Assert.assertEquals(4, nodes.size)
					val tableNames = nodes.sortBy[it.id].map[it.id.split("\\.").get(1)]
					Assert.assertEquals(#["BONUS", "DEPT", "EMP", "SALGRADE"], tableNames)
				}
			}
			
			@Test
			def getLovTest() {
				val lovs = gen.getLov(null, null, null)
				Assert.assertEquals(2, lovs.size)
				Assert.assertEquals(#["Yes", "No"], lovs.get("P1?"))
				Assert.assertEquals(#["Value 1", "Value 2", "Value 3"], lovs.get("P2"))
			}
			
			@Test
			def getParamStatesTest() {
				val params = gen.getNodes(null, null).get(0).params
				Assert.assertEquals(true, gen.getParamStates(null, params, null).get("P2"))
				params.put("P1?", "No")
				Assert.assertEquals(false, gen.getParamStates(null, params, null).get("P2"))
			}
			
			@Test
			def generatePrologTest() {
				Assert.assertEquals("", gen.generateProlog(null, null))
			}
		
			@Test
			def generateSeparatorTest() {
				Assert.assertEquals("", gen.generateSeparator(null))
			}
		
			@Test
			def generateEpilogTest() {
				Assert.assertEquals("", gen.generateEpilog(null, null))
			}
			
			@Test
			def generateTest() {
				if (dataSource.username.equalsIgnoreCase("SCOTT") &&  !dataSource.password.empty) {
					val node = gen.getNodes(dataSource.connection, "TABLE").findFirst[it.id == "TABLE.EMP"]
					val expected = «"'''"»
						-- TABLE.EMP Yes Value 3 some other value
					«"'''"»
					Assert.assertTrue(expected != gen.generate(dataSource.connection, node))
					node.params.put("P2", "Value 3")
					node.params.put("P3", "some other value")
					Assert.assertEquals(expected, gen.generate(dataSource.connection, node))
				}
			}
		}
	'''
	
	def private getHostFromUrl(String url) {
		val p = Pattern.compile("@(.*?):")
		val m = p.matcher(url)
		if (m.find) {
			return m.group(1)
		} else {
			return ""
		}
	}

	def private getPortFromUrl(String url) {
		val p = Pattern.compile("@(.*?):([0-9]+)")
		val m = p.matcher(url)
		if (m.find) {
			return m.group(2)
		} else {
			return ""
		}
	}
	
	def private getSidFromUrl(String url) {
		val p = Pattern.compile("@(.*?):([0-9]+):(.*)")
		val m = p.matcher(url)
		if (m.find) {
			return m.group(3)
		} else {
			return ""
		}
	}

	def private getServiceFromUrl(String url) {
		val p = Pattern.compile("@(.*?):([0-9]+)/(.*)")
		val m = p.matcher(url)
		if (m.find) {
			return m.group(3)
		} else {
			return ""
		}
	}
	
	def private testPropertiesTemplate() '''
		# properties to connect to Oracle Database using JDBC thin driver
		«IF conn.metaData.databaseProductName.startsWith("Oracle")»
			«val url=conn.metaData.URL»
			host=«url.hostFromUrl»
			port=«url.portFromUrl»
			sid=«url.sidFromUrl»
			service=«url.serviceFromUrl»
		«ELSE»
			host=localhost
			port=1521
			sid=ORCL
			service=
		«ENDIF»

		# oracle users
		username=scott
		password=
		
	'''

	override isSupported(Connection conn) {
		return true
	}

	override getName(Connection conn) {
		return "SQL Developer extension"
	}

	override getDescription(Connection conn) {
		return "Generate a Xtend oddgen SQL Developer extension."
	}

	override getFolders(Connection conn) {
		return #["Templates"]
	}

	override getHelp(Connection conn) {
		return "<p>not yet available</p>"
	}

	override getNodes(Connection conn, String parentNodeId) {
		val params = new LinkedHashMap<String, String>()
		params.put(CLASS_NAME, "NewGenerator")
		params.put(PACKAGE_NAME, "org.oddgen.plugin")
		params.put(OUTPUT_DIR, '''«System.getProperty("user.home")»«File.separator»oddgen«File.separator»sqldev''')
		val node = new Node
		node.id = "SQL Developer extension template"
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
		this.jdbcTemplate = new JdbcTemplate(new SingleConnectionDataSource(conn, true))
		this.node = node
		this.conn = conn
		this.extensionId = '''«node.params.get(PACKAGE_NAME)».«node.params.get(CLASS_NAME).toLowerCase»'''
		var String result
		val outputDir = node.params.get(OUTPUT_DIR)
		val mainJavaDir = '''«outputDir»«File.separator»src«File.separator»main«File.separator»java«File.separator»«node.params.get(PACKAGE_NAME).replace(".",File.separator)»'''
		val mainResourceDir = '''«outputDir»«File.separator»src«File.separator»main«File.separator»resources«File.separator»«node.params.get(PACKAGE_NAME).replace(".",File.separator)»«File.separator»resources'''
		val testJavaDir = '''«outputDir»«File.separator»src«File.separator»test«File.separator»java«File.separator»«node.params.get(PACKAGE_NAME).replace(".",File.separator)»«File.separator»tests'''
		val testResourceDir = '''«outputDir»«File.separator»src«File.separator»test«File.separator»resources'''
		val zipFile = '''«node.params.get(CLASS_NAME).toLowerCase»_for_SQLDev-1.0.0-SNAPSHOT.zip'''
		result = '''
			«mkdirs(outputDir)»
			«mkdirs(mainJavaDir)»
			«mkdirs('''«mainJavaDir»«File.separator»resources''')»
			«mkdirs(mainResourceDir)»
			«mkdirs(testJavaDir)»
			«mkdirs(testResourceDir)»
			«writeToFile('''«outputDir»«File.separator»bundle.xml''', bundleXmlTemplate.toString)»
			«writeToFile('''«outputDir»«File.separator»extension.xml''', extensionXmlTemplate.toString)»
			«writeToFile('''«outputDir»«File.separator»pom.xml''', pomXmlTemplate.toString)»
			«writeToFile('''«outputDir»«File.separator»sqldev_assembly.xml''', sqldevAssemblyXmlTemplate.toString)»
			«writeToFile('''«outputDir»«File.separator»sqldeveloper.xml''', sqldeveloperXmlTemplate.toString)»
			«writeToFile('''«mainJavaDir»«File.separator»«node.params.get(CLASS_NAME)».xtend''', generatorXtendTemplate.toString)»
			«writeToFile('''«mainJavaDir»«File.separator»PreferenceModel.xtend''', PreferenceModelXtendTemplate.toString)»
			«writeToFile('''«mainJavaDir»«File.separator»PreferencePanel.xtend''', preferencePanelXtendTemplate.toString)»
			«writeToFile('''«mainJavaDir»«File.separator»resources«File.separator»Resources.xtend''', resourcesXtendTemplate.toString)»
			«writeToFile('''«mainResourceDir»«File.separator»Resources.properties''', resourcesPropertiesTemplate.toString)»
			«writeToFile('''«testJavaDir»«File.separator»«node.params.get(CLASS_NAME)»Test.xtend''', generatorTestXtendTemplate.toString)»
			«writeToFile('''«testResourceDir»«File.separator»test.properties''', testPropertiesTemplate.toString)»
			
			To build the SQL Developer plugin:
			
			cd "«outputDir»"
			mvn clean package
			
			To install the plugin:
			
			start SQL Developer, 
			   - select "Check for Updates..." in the help menu
			   - use the "Install From Local File" option to install «outputDir»«File.separator»target«File.separator»«zipFile»
			
			To uninstall the plugin:
			
			start SQL Developer,
			   - select "Features..." in the tools menu
			   - select the checkbox of the plugins to uninstall and press "Uninstall"
		'''
	}
}
