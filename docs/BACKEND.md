Backend
=====

Backend files involved with frontend application behavior:

- islandora_transforms (repository)
- foxmlToSolr.xslt (ryerson)
- slurp_all_MODS_to_solr.xslt (ryerson)
- schema.xml (ryerson)
- solrconfig.xml (ryerson)

Gsearch
-----------

**islandora_transforms (repository)**

XSLT for transforming the usual suspects. By default uses the repository at:

https://github.com/lyrasis/islandora_transforms

_Examples:_

- https://github.com/FLVC/islandora_transforms

**foxmlToSolr.xslt**

Transform Fedora foxml to SOLR leveraging the islandora_transforms stylesheets.

_Notes:_

- Has multiple xsl:include elements that needs to have the path set correctly.
- Paths set to /var/lib/tomcat7 for Docker.

_Examples:_

- https://github.com/ryersonlibrary/islandora/blob/master/templates/default/foxmlToSolr.xslt.erb

**slurp_all_MODS_to_solr.xslt**

Sounds like it converts all MODS elements to SOLR =)

_Notes:_

- Has an xsl:include that needs to have the path set correctly.
- Path set to /var/lib/tomcat7 for Docker.

_Examples:_

- https://github.com/ryersonlibrary/islandora/blob/master/templates/default/slurp_all_MODS_to_solr.xslt.erb

Solr
-----

**schema-version.xml**

- Versioned schema file for SOLR

_Examples:_

- https://github.com/ryersonlibrary/islandora/blob/master/templates/default/schema.xml.erb

**solrconfig-version.xml**

- Versioned solrconfig file for SOLR
- Updated lib path entries

_Examples:_

- https://github.com/ryersonlibrary/islandora/blob/master/templates/default/solrconfig.xml.erb

---
