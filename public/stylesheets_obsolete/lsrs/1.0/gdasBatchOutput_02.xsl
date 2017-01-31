<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tjs="http://www.opengis.net/tjs/1.0" xpath-default-namespace="http://www.opengis.net/tjs/1.0" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:template match="/">
<html> 
 <head>
  <link rel="stylesheet" type="text/css" href="/stylesheets/lsrs/1.0/lsrs.css" />
  <!-- TEMPLATE SCRIPTS/CSS BEGIN | DEBUT DES SCRIPTS/CSS DU GABARIT -->
<link href="http://www.agr.gc.ca/webassets/css/clf2/base.css" media="screen, print" rel="stylesheet" type="text/css" />
<link href="http://www.agr.gc.ca/webassets/css/clf2/3col.css" media="screen, print" rel="stylesheet" type="text/css" />
<style type="text/css" media="all">
@import url(http://www.agr.gc.ca/webassets/css/clf2/base2.css);
</style>
<!-- TEMPLATE SCRIPTS/CSS END | FIN DES SCRIPTS/CSS DU GABARIT -->
<!-- PROGRESSIVE ENHANCEMENT BEGINS | DEBUT DE L'AMELIORATION PROGRESSIVE -->

<script src="http://www.agr.gc.ca/webassets/scripts/pe-ap.js" type="text/javascript"></script>

<script type="text/javascript">
 /* <![CDATA[ */
  var params = {
   lng:"eng",
   pngfix:"http://www.agr.gc.ca/webassets/images/inv.gif
  };
  PE.progress(params);
 /* ]]> */
 </script>
<!-- PROGRESSIVE ENHANCEMENT ENDS | FIN DE L'AMELIORATION PROGRESSIVE -->
<!-- CUSTOM SCRIPTS/CSS BEGIN | DEBUT DES SCRIPTS/CSS PERSONNALISES -->
<link href="http://www.agr.gc.ca/webassets/css/clf2/base-institution.css" media="screen, print" rel="stylesheet" type="text/css" />
<link href="http://www.agr.gc.ca/webassets/css/clf2_custom/institution.css" media="screen, print" rel="stylesheet" type="text/css" />
<link href="http://www.agr.gc.ca/webassets/css/clf2_custom/gen.css" media="screen, print" rel="stylesheet" type="text/css" />
<link href="../css/clf2_custom/CanSIS/canSIS-custom.css" media="screen, print" rel="stylesheet" type="text/css" />
<link rel="stylesheet"  href="/stylesheets/lsrs/1.0/lsrs.css" type="text/css"/>
<!-- CUSTOM SCRIPTS/CSS END | FIN DES SCRIPTS/CSS PERSONNALISES -->
<!-- TEMPLATE PRINT CSS BEGINS | DEBUT DU CSS DU GABARIT POUR L'IMPRESSION -->
<link href="http://www.agr.gc.ca/webassets/css/clf2/pf-if.css" rel="stylesheet" type="text/css" />
<!-- TEMPLATE PRINT CSS ENDS | FIN DU CSS DU GABARIT POUR L'IMPRESSION -->
<link href="http://www.agr.gc.ca/webassets/css/clf2/pf-if.css" rel="stylesheet" type="text/css" />

 </head>
<body>
<div class="page">
<div class="core">
<!-- FIP HEADER -->
<div class="fip"><a name="tphp" id="tphp"><img src="http://www.agr.gc.ca/webassets/images/sig-eng.gif" alt="Government of Canada" width="372" height="20" /></a></div>
<div class="cwm"><img src="http://www.agr.gc.ca/webassets/images/wmms.gif" alt="Symbol of the Government of Canada" width="83" height="20" /></div>
<!-- BREAD CRUMB -->
<center>
<p class="breadcrumb">
<a href="http://sis.agr.gc.ca/cansis/index.html">CanSIS</a> &gt; 
<a href="http://sis.agr.gc.ca/cansis/systems/index.html">Systems</a> &gt; 
<a href="/index.html">Land Suitability Rating System (LSRS)</a>
</p>
</center>
<hr height="4px" color="gray"/>
<!-- CONTENT -->
<center>
<h2>Land Suitability Rating Information</h2>

<table class="intro">
<tr><td class="subheader">Database:</td><td class="Abbr"><xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Title" /></td></tr>
<tr><td class="subheader">Climate:</td><td class="Abbr"><xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:ClimateTitle" /></td></tr>
<tr><td class="subheader">Crop:</td><td class="Abbr"><xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:Attributes/tjs:Column/@name" /></td></tr>
</table>
<br/>
<table class="lsrsSummary">
<tr>
 <th>Polygon</th>
 <th>Rating</th>
 <th colspan="2">View</th>
</tr>
<xsl:for-each select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Rowset/tjs:Row">
<tr>
<td class="Abbr"><xsl:value-of select="tjs:K" /></td>
<td class="Abbr"><xsl:value-of select="tjs:V" /></td>
<td class="Abbr"><xsl:element name="a"><xsl:attribute name="href">/lsrs/service?ClimateTable=<xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:ClimateTable"/>&amp;CmpTable=<xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:CmpTable"/>&amp;POLYID=<xsl:value-of select="tjs:K" />&amp;CROP=<xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:Attributes/tjs:Column/@name" />&amp;RESPONSE=Summary</xsl:attribute>Summary</xsl:element></td>
<td class="Abbr"><xsl:element name="a"><xsl:attribute name="href">/lsrs/service?ClimateTable=<xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:ClimateTable"/>&amp;CmpTable=<xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:CmpTable"/>&amp;POLYID=<xsl:value-of select="tjs:K" />&amp;CROP=<xsl:value-of select="//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:Attributes/tjs:Column/@name" />&amp;RESPONSE=Details</xsl:attribute>Details</xsl:element></td>
</tr>
</xsl:for-each>
</table>

</center>
</div>
</div>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
