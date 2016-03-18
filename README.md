# oddgen

<img src="https://github.com/oddgen/oddgen/blob/master/sqldev/src/main/resources/org/oddgen/sqldev/resources/images/oddgen_512x512_text.png?raw=true" style="padding-left:15px; padding-bottom:20px" title="Tooling for dictionary-driven code generation" align="right" width="128px" />

## Introduction

oddgen is a SQL Developer extension to invoke dictionary-driven code generators. Dictionary-driven means that the predominant part of a model is stored in an Oracle data dictionary or in other related relational tables. Generators written in PL/SQL are discovered after connecting to a database and presented in a navigator tree. The oddgen generator interface is designed to hide the complexity from the user and to support generation of any target code in just a few mouse clicks.

See <https://www.oddgen.org/> for more information about the product.     

## Releases

Binary releases are published [here](https://github.com/oddgen/oddgen/releases).

## Issues
Please file your bug reports, enhancement requests, questions and other support requests within Github's issue tracker [Issues](https://help.github.com/articles/about-issues/). The following links should help you to find similar issues:

* [Questions](https://github.com/oddgen/oddgen/issues?q=is%3Aissue+label%3Aquestion)
* [Open enhancements](https://github.com/oddgen/oddgen/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement)
* [Open bugs](https://github.com/oddgen/oddgen/issues?q=is%3Aopen+is%3Aissue+label%3Abug)

[submit new issue](https://github.com/oddgen/oddgen/issues/new).

## How to Contribute

1. Describe your idea by [submitting an issue](https://github.com/oddgen/oddgen/issues/new)
2. [Fork the oddgen respository](https://github.com/oddgen/oddgen/fork)
3. [Create a branch](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/), commit and publish your changes and enhancements
4. [Create a pull request](https://help.github.com/articles/creating-a-pull-request/)

## How to Build

1. [Download](http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html) and install SQL Developer 4.1.x
2. [Download](https://maven.apache.org/download.cgi) and install Apache Maven 3.1.x
3. Clone the oddgen repository
4. Open a terminal window in the oddgen root folder and type ```cd sqldev```
5. Run maven build by the following command ```mvn -Dsqldev.basedir=/Applications/SQLDeveloper4.1.3.app/Contents/Resources/sqldeveloper  -DskipTests=true clean package``` - Amend the parameter sqldev.basedir to match the path of your SQL Developer installation. This folder is used to reference various Oracle jar files which are not available in public Maven repositories
6. The resulting file oddgen_for_SQLDev_x.x.x-SNAPSHOT.zip may be installed within SQL Developer

## License

oddgen is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>. 
