<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gls="http://www.opengis.net/gls/0.12" xpath-default-namespace="http://www.opengis.net/gls/0.12" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:template match="/">
 <html> <head>
 <title>LSRS Error</title>
 <style type="text/css">
table
{ text-align: center;
font-family: Verdana;
font-weight: normal;
font-size: 11px;
color: #404040;
width: 600px;
background-color: #fafafa;
border: 1px #6699CC solid;
border-collapse: collapse;
border-spacing: 0px; }

table.intro
{ font-family: Verdana;
font-weight: normal;
font-size: 11px;
color: #404040;
width: 250px;
background-color: #fafafa;
border: 1px #6699CC solid;
border-collapse: collapse;
border-spacing: 0px; }

th
{ text-align: right;
}

td
{ text-align: right;
}

td.Abbr
{ text-align: left;
text-indent: 5px;
}

td.mid
{ text-align: center;
text-indent: 5px;
}

td.Header
{ border-bottom: 2px solid #6699CC;
border-left: 1px solid #6699CC;
background-color: #BEC8D1;
text-align: left;
text-indent: 5px;
font-family: Verdana;
font-weight: bold;
font-size: 11px;
color: #404040; }

td.Space
{ border-left: 1px solid #6699CC;
height: 20px; }

td.lsrsBody
{ border-bottom: 1px solid #9CF;
border-top: 0px;
border-left: 1px solid #9CF;
border-right: 0px;
text-align: left;
text-indent: 10px;
font-family: Verdana, sans-serif, Arial;
font-weight: normal;
font-size: 11px;
color: #404040;
background-color: #fafafa; }

table.lsrsSubheader
{ text-align: center;
font-family: Verdana;
font-weight: normal;
font-size: 11px;
color: #404040;
width: 580px;
background-color: #fafafa;
border: 1px #6699CC solid;
border-collapse: collapse;
border-spacing: 0px; } 
</style>
</head>
<body>

<h2>Error:</h2>

<h3><xsl:value-of select="ows:ExceptionReport/ows:ExceptionText" /></h3>


</body>
</html>
</xsl:template>
</xsl:stylesheet>
