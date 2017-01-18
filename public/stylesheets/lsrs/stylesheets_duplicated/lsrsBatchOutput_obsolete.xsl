<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gls="http://www.opengis.net/gls/0.12" xpath-default-namespace="http://www.opengis.net/gls/0.12" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:template match="/">
<html> 
 <head>
  <link rel="stylesheet" type="text/css" href="/stylesheets/lsrs/1.0/lsrs.css" />
 </head>
<body>
<center>

<h2>Land Suitability Rating Information</h2>

<table class="intro">
<tr><td class="subheader">Database:</td><td class="Abbr">SLC 3.0</td></tr>
<tr><td class="subheader">Climate:</td><td class="Abbr">1961-1990 normals</td></tr>
<tr><td class="subheader">Crop:</td><td class="Abbr"><xsl:value-of select="LSRS/Crop" /></td></tr>
</table>
<br/>
<table class="lsrsSummary">
<tr>
 <th>Polygon</th>
 <th>Rating</th>
 <th colspan="2">View</th>
</tr>
<xsl:for-each select="//LSRS/Polygon">
<tr>
<td class="Abbr"><xsl:value-of select="Id" /></td>
<td class="Abbr"><xsl:value-of select="Rating" /></td>
<td class="Abbr"><xsl:element name="a"><xsl:attribute name="href">/lsrs/service?POLYID=<xsl:value-of select="Id"/>&amp;CROP=<xsl:value-of select="../Crop" />&amp;RESPONSE=Summary</xsl:attribute>Summary</xsl:element></td>
<td class="Abbr"><xsl:element name="a"><xsl:attribute name="href">/lsrs/service?POLYID=<xsl:value-of select="Id"/>&amp;CROP=<xsl:value-of select="../Crop" />&amp;RESPONSE=Details</xsl:attribute>Details</xsl:element></td>
</tr>
</xsl:for-each>
</table>


</center>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
