<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wps="http://www.opengis.net/wps/1.0.0" xpath-default-namespace="http://www.opengis.net/wps/1.0.0" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:template match="/">
<html> 
 <head>
  <style type="text/css">
.restable {margin: auto; background: #FFF; border-collapse: collapse; border-top: 1px solid #363;}
.restable th {font-weight: bold; padding: .3em .7em; text-align: left; vertical-align: top; background: #9C9; white-space: nowrap; border-top: 1px solid #363; border-bottom: 1px solid #363;}
.restable td {font-weight: normal; padding: .3em .7em; text-align: left; vertical-align: top;}
th {font-size:16px; font-weight: bold; padding: .3em .7em; text-align: right;}
th.main {font-size:20px; font-weight: bold; font-style:italic; padding: .3em .7em; text-align: left;}
  </style>
 </head>
<body>
<h1><xsl:value-of select="//wps:ProcessDescription/ows:Title" /></h1>
<table>
  <tr><td colspan="3"><hr/></td></tr>
  <tr><th class="main">Purpose</th><td colspan="2"><xsl:value-of select="//wps:ProcessDescription/ows:Abstract" /></td></tr>
  <tr><td colspan="3"><hr/></td></tr>
  <tr><th class="main">Request</th><th>Method:</th><td>GET</td></tr>
  <tr><th></th><th>URL:</th><td></td></tr>
  <tr><th></th><th></th><td>
    <table class="restable">
      <tbody>
        <tr><th>Parameter</th><th>Value</th><th>Description</th></tr>
          <xsl:for-each select="//wps:ProcessDescription/DataInputs/Input">
            <tr>
              <td><b><xsl:value-of select="ows:Identifier" /></b></td>
              <xsl:choose>
                <xsl:when test="@minOccurs = 1">
                  <td><xsl:value-of select="*/ows:DataType" />(Mandatory)</td>
                </xsl:when>
                <xsl:otherwise>
                  <td><xsl:value-of select="*/ows:DataType" />(Optional)</td>
                </xsl:otherwise>
              </xsl:choose>
             <td><xsl:value-of select="ows:Abstract" /></td>
            </tr>
          </xsl:for-each>
        <tr><td colspan="3">Note:  If none of the mandatory parameters is present the service returns this service description document.</td></tr>
      </tbody>
    </table></td></tr>
  <tr><td colspan="3"><hr/></td></tr>
  <xsl:for-each select="//wps:ProcessDescription/ProcessOutputs/Output">
    <tr><th class="main">Response</th><th>Identifier:</th><td><xsl:value-of select="ows:Identifier" /></td></tr>
    <tr><th></th><th>Title:</th><td><xsl:value-of select="ows:Title" /></td></tr>
    <tr><th></th><th>Description:</th><td><xsl:value-of select="ows:Abstract" /></td></tr>
    <tr><th></th><th>MimeType:</th><td><xsl:value-of select="ComplexOutput/Default/Format/MimeType" /></td></tr>
    <tr><th></th><th>Encoding:</th><td><xsl:value-of select="ComplexOutput/Default/Format/Encoding" /></td></tr>
    <tr><th></th><th>Schema:</th><td><xsl:value-of select="ComplexOutput/Default/Format/Schema" /></td></tr>
  </xsl:for-each>
  <tr><td colspan="3"><hr/></td></tr>
</table>

<p><i>This web service is based on <a href="http://www.opengeospatial.org/standards/wps">WPS 1.0</a></i></p>

</body>
</html>
</xsl:template>
</xsl:stylesheet>
