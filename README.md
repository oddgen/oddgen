# oddgen

<img src="https://raw.github.com/oddgen/oddgen/main/sqldev/src/main/resources/org/oddgen/sqldev/resources/images/oddgen_512x512_text.png" style="padding-left:15px; padding-bottom:20px" title="Tooling for dictionary-driven code generation" align="right" width="128px" />

## Introduction

oddgen is a SQL Developer extension to invoke dictionary-driven code generators. Dictionary-driven means that the predominant part of a model is stored in the data dictionary of the RDBMS or in related data stores. Generators written in a JVM language or in PL/SQL are discovered after connecting to a database and presented in a navigator tree. The oddgen generator interface is designed to hide the complexity from the user and to support generation of any target code in just a few mouse clicks.

See <https://www.oddgen.org/> for more information about the product.     

## Releases

Binary releases are published [here](https://github.com/oddgen/oddgen/releases).

## How to Build

1. [Download](http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html) and install SQL Developer 17.2.0
2. [Download](https://maven.apache.org/download.cgi) and install Apache Maven 3.5.0
3. [Download](https://git-scm.com/downloads) and install a git command line client
4. Clone the oddgen repository
5. Open a terminal window in the oddgen root folder and type 

		cd sqldev
		
6. Run maven build by the following command

		mvn -Dsqldev.basedir=/Applications/SQLDeveloper17.2.0.app/Contents/Resources/sqldeveloper -DskipTests=true clean package
		
	Amend the parameter sqldev.basedir to match the path of your SQL Developer installation. This folder is used to reference various Oracle jar files which are not available in public Maven repositories
7. The resulting file ```oddgen_for_SQLDev_x.x.x-SNAPSHOT.zip``` may be installed within SQL Developer

## License

oddgen is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>. 
