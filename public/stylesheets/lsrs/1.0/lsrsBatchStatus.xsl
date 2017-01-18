<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wps="http://www.opengis.net/wps/1.0.0" xpath-default-namespace="http://www.opengis.net/wps/1.0" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:template match="/">
<!-- WEB PAGE -->
<html> 
 <head>
  <link rel="stylesheet" type="text/css" href="/stylesheets/lsrs/1.0/lsrs.css" />
  <title>LSRS batch status report</title>
  
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
<a href="/contents.html">Land Suitability Rating System (LSRS)</a>
</p>
</center>
<hr height="4px" color="gray"/>
<!-- CONTENT -->
<div class="colLayout">

<center>
<h2>LSRS batch status report</h2>

<table class="intro">
<xsl:for-each select="//wps:ExecuteResponse/wps:DataInputs/wps:Input">
  <xsl:choose>
    <xsl:when test="ows:Identifier='CmpTable'">
      <tr><td class="subheader">Component Table:</td><td class="Abbr"><xsl:value-of select="wps:Data/wps:LiteralData" /></td></tr>
    </xsl:when>
    <xsl:when test="ows:Identifier='FromPoly'">
      <tr><td class="subheader">From Polygon #:</td><td class="Abbr"><xsl:value-of select="wps:Data/wps:LiteralData" /></td></tr>
    </xsl:when>
    <xsl:when test="ows:Identifier='ToPoly'">
      <tr><td class="subheader">To Polygon #:</td><td class="Abbr"><xsl:value-of select="wps:Data/wps:LiteralData" /></td></tr>
    </xsl:when>
    <xsl:when test="ows:Identifier='Crop'">
      <tr><td class="subheader">Crop:</td><td class="Abbr"><xsl:value-of select="wps:Data/wps:LiteralData" /></td></tr>
    </xsl:when>
    <xsl:when test="ows:Identifier='Management'">
      <tr><td class="subheader">Management:</td><td class="Abbr"><xsl:value-of select="wps:Data/wps:LiteralData" /></td></tr>
    </xsl:when>
    <xsl:when test="ows:Identifier='ClimateTable'">
      <tr><td class="subheader">Climate Table:</td><td class="Abbr"><xsl:value-of select="wps:Data/wps:LiteralData" /></td></tr>
    </xsl:when>
  </xsl:choose>
</xsl:for-each>
</table>

<h3>status</h3>

<table class="lsrsSummary">
<tr>
  <td class="mid">As of: <xsl:value-of select="//wps:ExecuteResponse/wps:Status/@creationTime" />, 
    <xsl:choose>
      <xsl:when test="//wps:ExecuteResponse/wps:Status/wps:ProcessAccepted">the batch process has been accepted.</xsl:when>
      <xsl:when test="//wps:ExecuteResponse/wps:Status/wps:ProcessStarted">the batch process has started.</xsl:when>
      <xsl:when test="//wps:ExecuteResponse/wps:Status/wps:ProcessSuceeded">the batch process is complete.</xsl:when>
    </xsl:choose>
  </td>
</tr>
<tr><td class="mid">-</td></tr>
<xsl:choose>
  <xsl:when test="//wps:ExecuteResponse/wps:Status/wps:ProcessAccepted">
    <tr>
      <td class="mid"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="//wps:ExecuteResponse/@statusLocation" /></xsl:attribute>Update this page.</xsl:element></td>
    </tr>
  </xsl:when>
  <xsl:when test="//wps:ExecuteResponse/wps:Status/wps:ProcessStarted">
    <tr>
      <td class="mid">Completed <xsl:value-of select="//wps:ExecuteResponse/wps:Status/wps:ProcessStarted/@percentCompleted" />%.</td>
    </tr>
    <tr><td class="mid">-</td></tr>
    <tr>
      <td class="mid"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="//wps:ExecuteResponse/@statusLocation" /></xsl:attribute>Get latest status.</xsl:element></td>
    </tr>
		<tr>
					<td class="mid">- or -</td>
		</tr>
    <tr>
      <td class="mid"><a href="output.html">View Results so far</a></td>
    </tr>
  </xsl:when>
  <xsl:when test="//wps:ExecuteResponse/wps:Status/wps:ProcessSuceeded">
    <tr>
      <td class="mid"><xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="//wps:ExecuteResponse/wps:ProcessOutputs/wps:Output/wps:Reference/@href" /></xsl:attribute>View Results</xsl:element></td>
    </tr>
  </xsl:when>
</xsl:choose>
<tr>
      <td class="mid">- or -</td>
</tr>
<tr>
      <td class="mid"><a href="/lsrsbatchstatus/client">View batch queue</a></td>
</tr>
</table>

</center>

<!-- FOOTER BEGINS | DEBUT DU PIED DE LA PAGE -->
<div class="footer">
<div class="footerline"></div>
</div>
<!-- FOOTER ENDS | FIN DU PIED DE LA PAGE -->
</div>
</div>
</div>
</body>
</html>
<!-- PAGE ENDS -->
</xsl:template>
</xsl:stylesheet>
