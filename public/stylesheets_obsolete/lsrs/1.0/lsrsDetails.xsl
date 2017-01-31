<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gls="http://www.opengis.net/gls/0.12" xpath-default-namespace="http://www.opengis.net/gls/0.12" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:template match="/">
<!-- WEB PAGE -->
<html> 
 <head>
  <link rel="stylesheet" type="text/css" href="/stylesheets/lsrs/1.0/lsrs.css" />
  <title>LSRS detailed calculation</title>
  
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
<h2>Land Suitability Rating</h2>

<table class="intro">
<tr><td class="subheader">Polygon:</td><td class="Abbr"><xsl:element name="a"><xsl:attribute name="href">http://website.gis.agr.gc.ca/cansis/services/vector/<xsl:value-of select="translate(LSRS/Request/FrameworkName,'_','/')" />/cmp/<xsl:value-of select="LSRS/Request/Polygon" />.html</xsl:attribute><xsl:value-of select="LSRS/Request/Polygon" /></xsl:element></td></tr>
<tr><td class="subheader">Database:</td><td class="Abbr"><xsl:value-of select="LSRS/Request/Database" /></td></tr>
<tr><td class="subheader">Climate:</td><td class="Abbr"><xsl:value-of select="LSRS/Request/Climate" /></td></tr>
<tr><td class="subheader">Crop:</td><td class="Abbr"><xsl:value-of select="LSRS/Request/Crop" /></td></tr>
<tr><td class="subheader">Management:</td><td class="Abbr"><xsl:value-of select="LSRS/Request/Management" /></td></tr>
<tr><td class="subheader">Rating:</td><td class="Abbr"><xsl:value-of select="LSRS/Rating/FinalCombinedRating" /></td></tr>
</table>

<br/><hr/>
<h3>Climate Rating</h3>
<table cellspacing="0">
<tr><th colspan="7">1) Moisture Deficit Factor {<a href="/documentation/Section3_1">info</a>}</th></tr>
<tr><td>P-PE Index =</td><td><xsl:value-of select="round(LSRS/Climate/Moisture/PPE)" /></td><td class="Abbr">(a1)</td><td></td><td>Moisture Deficit Point deduction =</td><td><xsl:value-of select="round(LSRS/Climate/Moisture/DeductionUsed)"/></td><td class="Abbr"><a href="/documentation/Section3_1_(A)">(A)</a></td></tr>
<tr><td>100 - A =</td><td><xsl:value-of select="round(LSRS/Climate/Moisture/Value)" /></td><td class="Abbr"></td><td></td><td></td><td></td><td></td></tr>

<tr><th colspan="7">2) Temperature Factor {<a href="/documentation/Section3_2a">info</a>}</th></tr>
<xsl:choose>
  <xsl:when test="LSRS/Climate/Temperature/HF/CHU">
    <tr><td>CHU Index =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/CHU/CHU)"/></td><td class="Abbr">(h1)</td><td></td><td>CHU point deduction =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/CHU/DeductionUsed)"/></td><td class="Abbr">(H)</td></tr>
    <tr><td>100 - H =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/Value)"/></td><td class="Abbr"></td><td></td><td></td><td></td></tr>
  </xsl:when>
  <xsl:when test="LSRS/Climate/Temperature/HF/EGDD">
    <tr><td>EGDD Index =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/EGDD/EGDD)"/></td><td class="Abbr">(h1)</td><td></td><td>EGDD point deduction =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/EGDD/DeductionUsed)"/></td><td class="Abbr"><a href="/documentation/Section3_2_2">(H)</a></td></tr>
    <tr><td>100 - H =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/Value)"/></td><td class="Abbr"></td><td></td><td></td><td></td></tr>
  </xsl:when>
  <xsl:when test="LSRS/Climate/Temperature/HF/GDD">
    <tr><td>Heat Factor 1 <a href="/documentation/Section3_2_4">(GDD)</a>  =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/GDD/HF1/GDD)"/></td><td></td><td></td><td>HF1 point deduction =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/GDD/HF1/DeductionUsed)"/></td><td class="Abbr"><a href="/documentation/Section3_2_1">(h1)</a></td></tr>
    <tr><td>Heat Factor 2 <a href="/documentation/Section3_2_5">(GSL)</a>  =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/GDD/HF2/GSL)"/></td><td></td><td></td><td>HF2 point deduction =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/GDD/HF2/DeductionUsed)"/></td><td class="Abbr"><a href="/documentation/Section3_2_3">(h2)</a></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>Temperature Deduction =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/HF/Value)"/></td><td class="Abbr"><a href="/documentation/Section3_2_2">(H)</a></td></tr>
    <tr><td>100 - H =</td><td><xsl:value-of select="round(LSRS/Climate/Temperature/Value)"/></td><td class="Abbr"></td><td></td><td></td><td></td><td></td></tr>
  </xsl:when>
</xsl:choose>

<tr><th colspan="7">3) Basic Climate Rating</th></tr>
<tr><td>lower of (100 - A) or (100 - H) =</td><td><xsl:value-of select="round(LSRS/Climate/BasicRating/Value)"/></td><td class="Abbr">(B)</td><td></td><td></td><td></td></tr>

<tr><th colspan="7">4) Climate Modifiers {<a href="/documentation/Section3_3">info</a>}</th></tr>
<tr><td>Excess Spring Moisture =</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M1/ESM)"/></td><td class="Abbr"></td><td></td><td>% deduction</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M1/Value)"/></td><td class="Abbr"><a href="/documentation/Section3_3_1">(m1)</a></td></tr>
<tr><td>Excess Fall Moisture =</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M2/EFM)"/></td><td class="Abbr"></td><td></td><td>% deduction</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M2/Value)"/></td><td class="Abbr"><a href="/documentation/Section3_3_2">(m2)</a></td></tr>
<tr><td>Early Fall Frost =</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M3/EFF)"/></td><td class="Abbr"></td><td></td><td>% deduction</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M3/Value)"/></td><td class="Abbr"><a href="/documentation/Section3_3_3">(m3)</a></td></tr>
<tr><td>Risk of Hail Index =</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M4/RHI)"/></td><td class="Abbr"></td><td></td><td>% deduction</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/M4/Value)"/></td><td class="Abbr">(m4)</td></tr>
<tr><td></td><td></td><td></td><td></td><td>Total % deduction</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/SumM)"/></td><td></td></tr>
<tr><td></td><td></td><td></td><td></td><td>Actual Deduction =</td><td><xsl:value-of select="round(LSRS/Climate/Modifiers/Value)"/></td><td class="Abbr">(M)</td></tr>

<xsl:if test="LSRS/Climate/Ba/Apply = 1">
<tr><th colspan="7">5) Canola Climate Rating Adjustment</th></tr>
<tr><td>Days > 30 <sup>o</sup>C during flowering =</td><td><xsl:value-of select="round(LSRS/Climate/Ba/CANHM)"/></td><td></td><td></td><td>Adjustment percent =</td><td><xsl:value-of select="round(LSRS/Climate/Ba/Percent)"/></td><td class="Abbr"></td></tr>
<tr><td></td><td></td><td></td><td></td><td>Adjustment amount =</td><td><xsl:value-of select="round(LSRS/Climate/Ba/Value)"/></td><td class="Abbr">(Ba)</td></tr>
</xsl:if>

<tr><th colspan="7">Climate Rating</th></tr>
<tr><td>Final Climate Rating (B <xsl:if test="LSRS/Climate/Ba/Apply = 1">- Ba </xsl:if>- M) =</td><td><xsl:value-of select="round(LSRS/Climate/Value)"/></td><td class="Abbr">(C)</td><td></td><td></td><td></td></tr>
<tr><td>LSRS Class =</td><td><xsl:value-of select="LSRS/Climate/Rating"/></td><td></td><td></td><td></td><td></td></tr>
</table>

<xsl:for-each select="LSRS/SoilLandscape/Cmp">
  <br/><hr/>
  <h2><xsl:value-of select="Percent" /> percent <xsl:value-of select="SoilName" /></h2>
  <table class="intro">
		<tr><td class="subheader">Soil_id:</td><td class="Abbr"><xsl:element name="a"><xsl:attribute name="href">http://sis.agr.gc.ca/cansis/soils/<xsl:value-of select="translate(substring(Soil_id,1,2),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />/<xsl:value-of select="substring(Soil_id,3,3)" />/<xsl:value-of select="substring(Soil_id,6,5)" />/<xsl:value-of select="substring(Soil_id,11,1)" />/description.html</xsl:attribute><xsl:value-of select="Soil_id" /></xsl:element></td></tr>
		<tr><td class="subheader">Order:</td><td class="Abbr"><xsl:value-of select="Order3" /></td></tr>
		<tr><td class="subheader">SubGroup.GreatGroup:</td><td class="Abbr"><xsl:value-of select="SubGroup3" />.<xsl:value-of select="GreatGroup3" /></td></tr>
		<xsl:if test="Managements">
			<tr><td class="header"><br/><i>Management practices</i></td></tr>
			<xsl:if test="Managements/WaterTableDepth">
				<tr><td class="subheader">Water Table Depth (cm):</td><td class="Abbr"><xsl:value-of select="Managements/WaterTableDepth" /></td></tr>
			</xsl:if>
			<tr><td class="subheader">Reaction (pH):</td><td class="Abbr"><xsl:value-of select="Managements/Reaction" /></td></tr>
		</xsl:if>
  </table>
  <xsl:choose>
    <xsl:when test="MineralSoil">
      <h3>Mineral Soil Rating</h3>
      <table cellspacing="0">
      <tr><th colspan="7">1) Moisture Factor</th></tr>
      <tr><td>P-PE Index =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Moisture/PPE,'0.0')" /></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>AWHC</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Surface %Si =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Surface/Si)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Surface %C =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Surface/C)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Surface %CF =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Surface/CF)"/></td><td></td><td></td><td>AWHC/Surface deduction =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Surface/AWHCdeduction)"/></td><td></td></tr>
      <tr><td class="Abbr">Subsurface Texture</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Subsurface %Si =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Subsurface/Si)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Subsurface %C =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Subsurface/C)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Subsurface %CF =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Subsurface/CF)"/></td><td></td><td></td><td>Subsurface Adjustment =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Subsurface/Adjustment)"/></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Subtotal Texture Deduction =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/SubtotalTextureDeduction)"/></td><td class="Abbr">(a)</td></tr>
      <tr><td class="Abbr">Water Table Depth in cm =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/WaterTableDepth)"/></td><td></td><td></td><td>Water Table Deduction % =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/WaterTableDeduction)"/></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Reduction amount of (a) =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/ReductionAmount)"/></td><td class="Abbr">(b)</td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Final Moisture deduction (a - b) =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Deduction)"/></td><td class="Abbr">(M)</td></tr>

      <tr><th colspan="7">2) Surface Factors</th></tr>
      <tr><td class="Abbr">Structure/Consistency (%OC)</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>%OC =</td><td><xsl:value-of select="format-number(MineralSoil/SurfaceFactors/OC,'0.00')"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>%S =</td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/S)"/></td><td></td><td>Pt deduction=</td><td></td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/ConsistenceDeductionD)"/></td><td class="Abbr"><a href="/documentation/Section4_2_1">(D)</a></td></tr>
      <tr><td class="Abbr">OM Context (using %OC above) =</td><td><xsl:value-of select="format-number(MineralSoil/SurfaceFactors/OC,'0.00')"/></td><td></td><td>Pt deduction=</td><td></td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/OMContextDeductionF)"/></td><td class="Abbr"><a href="/documentation/Section4_2_2">(F)</a></td></tr>
      <tr><td class="Abbr">Depth of Top Soil (cm) =</td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/DepthOfTopSoil)"/></td><td></td><td>Pt deduction=</td><td></td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/DepthOfTopSoilDeductionE)"/></td><td class="Abbr"><a href="/documentation/Section4_2_3">(E)</a></td></tr>
      <tr><td></td><td></td><td></td><td></td><td class="mid"><u>Interim</u></td><td></td><td></td></tr>

      <tr><td class="Abbr">Reaction (pH) =</td><td><xsl:value-of select="format-number(MineralSoil/SurfaceFactors/Reaction,'0.00')"/></td><td></td><td>Pt deduction=</td><td class="mid"><xsl:value-of select="round(MineralSoil/SurfaceFactors/ReactionDeductionInterim)"/></td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/ReactionDeduction)"/></td><td class="Abbr"><a href="/documentation/Section4_2_4">(V)</a></td></tr>
      <tr><td class="Abbr">Salinity (EC) (dS/m) =</td><td><xsl:value-of select="format-number(MineralSoil/SurfaceFactors/Salinity,'0.00')"/></td><td></td><td>Pt deduction=</td><td class="mid"><xsl:value-of select="round(MineralSoil/SurfaceFactors/SalinityDeductionInterim)"/></td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/SalinityDeduction)"/></td><td class="Abbr"><a href="/documentation/Section4_2_5">(N)</a></td></tr>
      <tr><td class="Abbr">Sodicity (SAR) =</td><td><xsl:value-of select="format-number(MineralSoil/SurfaceFactors/Sodicity,'0.00')"/></td><td></td><td>Pt deduction=</td><td class="mid"><xsl:value-of select="round(MineralSoil/SurfaceFactors/SodicityDeductionInterim)"/></td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/SodicityDeduction)"/></td><td class="Abbr"><a href="/documentation/Section4_2_6">(Y)</a></td></tr>

      <tr><td></td><td></td><td></td><td></td><td>Most limiting (of 3 above) = </td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/MostLimitingDeduction)"/></td><td></td></tr>
      <tr><td class="Abbr">Organic Surfaces</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Depth organic horizons (Ox) =</td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/DepthOrganicHorizons)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Bulk density organic horizons =</td><td><xsl:value-of select="format-number(MineralSoil/SurfaceFactors/BulkDensityOrganicHorizons,'0.00')"/></td><td></td><td>Pt deduction=</td><td></td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/OrganicSurfaceDeduction)"/></td><td class="Abbr">(O)</td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Total Surface Deductions = </td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/TotalDeductions)"/></td><td class="Abbr">(c1)</td></tr>
      <tr><td class="Abbr">Interim Soil Rating = </td><td><xsl:value-of select="round(MineralSoil/SurfaceFactors/InterimSoilRatingD)"/></td><td class="Abbr">(d)</td><td></td><td></td><td></td></tr>

      <tr><th colspan="7">3) Subsurface Factors {<a href="/documentation/Section4_3">info</a>}</th></tr>
      <tr><td class="Abbr">Subsurface Impedence</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Highest Impedence BD =</td><td><xsl:value-of select="format-number(MineralSoil/SubsurfaceFactors/HighestImpedenceBD,'0.00')"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>% Clay =</td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/HighestImpedenceClay)"/></td><td></td><td></td><td>% deduction =</td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/HighestImpedenceClayDeduction)"/></td><td></td></tr>
      <tr><td class="Abbr">% Impedence Modification</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Depth to impeding layer =</td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/ImpedingDepth)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>P-PE (from above) =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Moisture/PPE,'0.0')" /></td><td></td><td colspan="2">% modification deduction =</td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/ImpedenceModificationDeduction)"/></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Final % deduction = </td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/ImpedenceDeduction)"/></td><td class="Abbr"><a href="/documentation/Section4_3_1">(D)</a></td></tr>
      <tr><td></td><td></td><td></td><td></td><td class="mid"><u>Interim</u></td><td></td><td></td></tr>
      <tr><td class="Abbr">Reaction (subsurface pH) =</td><td><xsl:value-of select="format-number(MineralSoil/SubsurfaceFactors/Reaction,'0.00')"/></td><td></td><td>Pt deduction =</td><td class="mid"><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/ReactionDeductionInterim)"/></td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/ReactionDeduction)"/></td><td class="Abbr">(V)</td></tr>
      <tr><td class="Abbr">Salinity (EC) (dS/m) =</td><td><xsl:value-of select="format-number(MineralSoil/SubsurfaceFactors/Salinity,'0.00')"/></td><td></td><td>Pt deduction =</td><td class="mid"><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/SalinityDeductionInterim)"/></td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/SalinityDeduction)"/></td><td class="Abbr">(N)</td></tr>
      <tr><td class="Abbr">Sodicity (SAR) =</td><td><xsl:value-of select="format-number(MineralSoil/SubsurfaceFactors/Sodicity,'0.00')"/></td><td></td><td>Pt deduction =</td><td class="mid"><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/SodicityDeductionInterim)"/></td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/SodicityDeduction)"/></td><td class="Abbr">(Y)</td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Most limiting (of 3 above) = </td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/MostLimitingDeduction)"/></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Subsurface % deduction = </td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/PercentDeduction)"/></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>% reduction of (d) = </td><td><xsl:value-of select="round(MineralSoil/SubsurfaceFactors/PercentReduction)"/></td><td class="Abbr">(e)</td></tr>
      <tr><td>Interim Basic Soil Rating (d - e)</td><td><xsl:value-of select="round(MineralSoil/InterimBasicSoilRating)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Final Basic Soil Rating </td><td><xsl:value-of select="round(MineralSoil/FinalBasicSoilRating)"/></td><td class="Abbr">(f)</td><td></td><td></td><td></td><td></td></tr>

      <tr><th colspan="7">4) Drainage Factor</th></tr>
      <tr><td>Water Table Depth in cm =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/WaterTableDepth)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>P-PE Index =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Moisture/PPE,'0.0')" /></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Surface %Si =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Surface/Si)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Surface %C =</td><td><xsl:value-of select="round(MineralSoil/MoistureFactor/Surface/C)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>% Drainage deduction = </td><td><xsl:value-of select="round(MineralSoil/DrainageFactor/PercentDeduction)"/></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Drainage deduction = </td><td><xsl:value-of select="round(MineralSoil/DrainageFactor/Deduction)"/></td><td class="Abbr">(W)</td></tr>

      <tr><th colspan="7">Soil Rating</th></tr>
      <tr><td>Final Mineral Soil Rating (f - W) =</td><td><xsl:value-of select="round(MineralSoil/Rating)"/></td><td class="Abbr">(S)</td><td></td><td></td><td></td><td></td></tr>
      <tr><td>LSRS Class =</td><td><xsl:value-of select="MineralSoil/Class"/></td><td></td><td></td><td></td><td></td><td></td></tr>

    </table>
    </xsl:when>
    <xsl:when test="OrganicSoil">
      <h3>Organic Soil Rating</h3>
      <table cellspacing="0">
      <tr><th colspan="7">1) Soil Temperature  {<a href="/documentation/Section5_1">info</a>}</th></tr>
      <tr><td class="Abbr">EGDD Index =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Temperature/HF/EGDD/EGDD,'0.0')" /></td><td></td><td></td><td>Temperature Deduction = </td><td><xsl:value-of select="round(OrganicSoil/SoilClimate/TemperatureDeduction)"/></td><td class="Abbr"><a href="/documentation/Section5_1">(Z)</a></td></tr>
      <tr><td class="Abbr">Organic Base Rating (100 - Z) = </td><td><xsl:value-of select="round(OrganicSoil/SoilClimate/OrganicBaseRating)"/></td><td class="Abbr">(a)</td><td></td><td></td><td></td></tr>

      <tr><th colspan="7">2) Moisture Deficit Factor {<a href="/documentation/Section5_2">info</a>}</th></tr>
      <tr><td class="Abbr">P-PE Index =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Moisture/PPE,'0.0')" /></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td class="Abbr">Surface % Fibre =</td><td><xsl:value-of select="round(LSRS_Layers/Surface/Fibre)" /></td><td class="Abbr"><a href="/documentation/Section5_2_1">(f)</a></td><td></td><td>Water Capacity/Climate Deduction =</td><td><xsl:value-of select="format-number(OrganicSoil/MoistureFactor/WaterCapacityDeduction,'0.0')" /></td><td class="Abbr"><a href="/documentation/Section5_2_2">(m1)</a></td></tr>
      <tr><td class="Abbr">Water Table Depth =</td><td><xsl:value-of select="round(WaterTableDepth)" /></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td class="Abbr">Subsurface % Fibre =</td><td><xsl:value-of select="round(LSRS_Layers/Subsurface/Fibre)" /></td><td></td><td></td><td>Water Table Adjustment =</td><td><xsl:value-of select="format-number(OrganicSoil/MoistureFactor/WaterTableAdjustment,'0.0')" /></td><td class="Abbr"><a href="/documentation/Section5_2_3">(m2)</a></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Moisture Deficit Deduction =</td><td><xsl:value-of select="round(OrganicSoil/MoistureFactor/MoistureDeficitDeduction)" /></td><td class="Abbr"><a href="/documentation/Section5_2_4">(M)</a></td></tr>
      <tr><td class="Abbr">Interim Rating (a - M) = </td><td><xsl:value-of select="round(OrganicSoil/MoistureFactor/InterimRating)"/></td><td class="Abbr">(b)</td><td></td><td></td><td></td></tr>

      <tr><th colspan="7">3) Surface Factors {<a href="/documentation/Section5_3">info</a>}</th></tr>
      <tr><td class="Abbr">Surface Structure</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>P-PE =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Moisture/PPE,'0.0')"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Surface % Fibre =</td><td><xsl:value-of select="round(LSRS_Layers/Surface/Fibre)"/></td><td></td><td></td><td>% Deduction =</td><td><xsl:value-of select="format-number(OrganicSoil/SurfaceFactors/StructureDeduction,'0.0')"/></td><td class="Abbr"><a href="/documentation/Section5_3_1">(B)</a></td></tr>
      <tr><td class="Abbr">Surface Reaction (pH) =</td><td><xsl:value-of select="round(LSRS_Layers/Surface/Reaction)"/></td><td></td><td></td><td>Reaction Deduction =</td><td><xsl:value-of select="format-number(OrganicSoil/SurfaceFactors/ReactionDeduction,'0.0')"/></td><td class="Abbr"><a href="/documentation/Section5_3_2">(V)</a></td></tr>
      <tr><td class="Abbr">Surface Salinity (EC) =</td><td><xsl:value-of select="round(LSRS_Layers/Surface/Salinity)"/></td><td></td><td></td><td>Salinity Deduction =</td><td><xsl:value-of select="format-number(OrganicSoil/SurfaceFactors/SalinityDeduction,'0.0')"/></td><td class="Abbr"><a href="/documentation/Section5_3_3">(N)</a></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Max of Reaction / Salinity =</td><td><xsl:value-of select="format-number(OrganicSoil/SurfaceFactors/MostLimitingDeduction,'0.0')" /></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Surface Factors Deduction % =</td><td><xsl:value-of select="round(OrganicSoil/SurfaceFactors/TotalDeductions)" /></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Final Surface Deduction =</td><td><xsl:value-of select="round(OrganicSoil/SurfaceFactors/FinalDeduction)"/></td><td class="Abbr"><a href="/documentation/Section5_3_4">(sf)</a></td></tr>
      <tr><td class="Abbr">Basic Organic Rating (b - sf) =</td><td><xsl:value-of select="round(OrganicSoil/SurfaceFactors/BasicOrganicRating)"/></td><td class="Abbr">(c)</td><td></td><td></td><td></td><td></td></tr>

      <tr><th colspan="7">4) Subsurface Factors {<a href="/documentation/Section5_4">info</a>}</th></tr>
      <tr><td class="Abbr">Subsurface Structure</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Subsurface % Fibre =</td><td><xsl:value-of select="round(LSRS_Layers/Subsurface/Fibre)"/></td><td></td><td></td><td>% Deduction =</td><td><xsl:value-of select="format-number(OrganicSoil/SubsurfaceFactors/StructureDeduction,'0.0')"/></td><td class="Abbr"><a href="/documentation/Section5_4_1">(B)</a></td></tr>
      <tr><td class="Abbr">Substrate</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>P-PE =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Moisture/PPE,'0.0')"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Organic Depth =</td><td><xsl:value-of select="format-number(OrganicDepth,'0.0')"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Substrate Master Horizon =</td><td><xsl:value-of select="SubstrateMasterHorizon"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Substrate COFRAG =</td><td><xsl:value-of select="SubstrateCoarseFragments"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Substrate % Si =</td><td><xsl:value-of select="SubstrateSilt"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td>Substrate % C =</td><td><xsl:value-of select="SubstrateClay"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Substrate Deduction % =</td><td><xsl:value-of select="format-number(OrganicSoil/SubsurfaceFactors/SubstrateDeduction,'0.0')" /></td><td class="Abbr"><a href="/documentation/Section5_4_2">(G)</a></td></tr>
      <tr><td class="Abbr">Subsurface Reaction (pH) =</td><td><xsl:value-of select="round(LSRS_Layers/Subsurface/Reaction)"/></td><td></td><td></td><td>Reaction Deduction =</td><td><xsl:value-of select="format-number(OrganicSoil/SubsurfaceFactors/ReactionDeduction,'0.0')"/></td><td class="Abbr"><a href="/documentation/Section5_4_3">(V)</a></td></tr>
      <tr><td class="Abbr">Subsurface Salinity (EC) =</td><td><xsl:value-of select="round(LSRS_Layers/Subsurface/Salinity)"/></td><td></td><td></td><td>Salinity Deduction =</td><td><xsl:value-of select="format-number(OrganicSoil/SubsurfaceFactors/SalinityDeduction,'0.0')"/></td><td class="Abbr"><a href="/documentation/Section5_4_4">(N)</a></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Max of Reaction / Salinity =</td><td><xsl:value-of select="format-number(OrganicSoil/SubsurfaceFactors/MostLimitingDeduction,'0.0')" /></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Subsurface Factors Deduction % =</td><td><xsl:value-of select="round(OrganicSoil/SubsurfaceFactors/TotalDeductions)" /></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Final Subsurface Deduction =</td><td><xsl:value-of select="round(OrganicSoil/SubsurfaceFactors/FinalDeduction)"/></td><td class="Abbr"><a href="/documentation/Section5_4_5">(ssf)</a></td></tr>
      <tr><td class="Abbr">Interim Final Rating (c - ssf) =</td><td><xsl:value-of select="round(OrganicSoil/SubsurfaceFactors/InterimFinalRating)"/></td><td class="Abbr">(d)</td><td></td><td></td><td></td><td></td></tr>

      <tr><th colspan="7">5) Drainage Factor {<a href="/documentation/Section5_5">info</a>}</th></tr>
      <tr><td class="Abbr">P-PE Index =</td><td><xsl:value-of select="format-number(/LSRS/Climate/Moisture/PPE,'0.0')" /></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td class="Abbr">Water Table Depth =</td><td><xsl:value-of select="round(WaterTableDepth)" /></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td class="Abbr">Subsurface % Fibre =</td><td><xsl:value-of select="round(LSRS_Layers/Subsurface/Fibre)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Drainage Deduction % =</td><td><xsl:value-of select="round(OrganicSoil/DrainageFactor/PercentDeduction)" /></td><td class="Abbr"><a href="/documentation/Section5_5_1">(w1)</a></td></tr>
      <tr><td></td><td></td><td></td><td></td><td>Drainage Deduction =</td><td><xsl:value-of select="round(OrganicSoil/DrainageFactor/Deduction)" /></td><td class="Abbr"><a href="/documentation/Section5_5_2">(W)</a></td></tr>

      <tr><th colspan="7">Soil Rating</th></tr>
      <tr><td>Final Organic Soil Rating (d - W) =</td><td><xsl:value-of select="round(OrganicSoil/Rating)"/></td><td class="Abbr">(O)</td><td></td><td></td><td></td><td></td></tr>
      <tr><td>LSRS Class =</td><td><xsl:value-of select="OrganicSoil/Class"/></td><td></td><td></td><td></td><td></td><td></td></tr>

    </table>
    </xsl:when>
  </xsl:choose>

  <h3>Landscape Rating</h3>
  <table cellspacing="0">
    <tr><th colspan="7">1) Landscape Factors {<a href="/documentation/Section6_1_0">info</a>}</th></tr>
    <tr><td class="Abbr">Region Number =</td><td><xsl:value-of select="/LSRS/SoilLandscape/ErosivityRegion" /></td><td class="Abbr"><a href="/documentation/Section6_1_01">(rn)</a></td><td></td><td></td><td></td><td></td></tr>
    <tr><td class="Abbr">Percent Slope =</td><td><xsl:value-of select="Slp50" /></td><td></td><td></td><td></td><td></td><td></td></tr>
    <tr><td class="Abbr">Landscape Type =</td><td><xsl:value-of select="Landscape/Complexity" /></td><td class="Abbr"><a href="/documentation/Section6_1_02">(lt)</a></td><td></td><td></td><td></td><td></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>Landscape Point Deduction =</td><td><xsl:value-of select="round(Landscape/Slope/Deduction)" /></td><td class="Abbr"><a href="/documentation/Section6_1">(T)</a></td></tr>
    <tr><td class="Abbr">Basic Landscape Rating =</td><td><xsl:value-of select="round(Landscape/Slope/BasicRating)"/></td><td class="Abbr">(a)</td><td></td><td></td><td></td><td></td></tr>

    <tr><th colspan="7">2) Coarse Fragment Modification</th></tr>
    <tr><td class="Abbr">Stoniness (m<sup>3</sup>/ha/year) =</td><td><xsl:value-of select="format-number(StoninessValue,'0.00')"/></td><td></td><td></td><td>Stoniness % Deduction =</td><td><xsl:value-of select="round(Landscape/CoarseFragment/StoninessPercentDeduction)"/></td><td class="Abbr"><a href="/documentation/Section6_2_1">(P)</a></td></tr>
    <tr><td class="Abbr">Coarse Fragments (gravel) =</td><td><xsl:value-of select="round(LSRS_Layers/Surface/CF)"/></td><td></td><td></td><td>Coarse Fragments % Deduction =</td><td><xsl:value-of select="round(Landscape/CoarseFragment/GravelPercentDeduction)"/></td><td class="Abbr">(P)</td></tr>
    <tr><td class="Abbr">Wood</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
    <tr><td>Surface Wood % =</td><td><xsl:value-of select="round(LSRS_Layers/Surface/Wood)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
    <tr><td>Subsurface Wood % =</td><td><xsl:value-of select="round(LSRS_Layers/Subsurface/Wood)"/></td><td></td><td></td><td></td><td></td><td></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>Wood Content % Deduction =</td><td><xsl:value-of select="round(Landscape/CoarseFragment/WoodContentPercentDeduction)" /></td><td class="Abbr"><a href="/documentation/Section6_2_2">(J)</a></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>Total C.F. % Deduction =</td><td><xsl:value-of select="round(Landscape/CoarseFragment/TotalCFPercentDeduction)" /></td><td></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>C.F. Deduction to Subtract =</td><td><xsl:value-of select="round(Landscape/CoarseFragment/CFDeduction)" /></td><td class="Abbr">(b)</td></tr>
    <tr><td class="Abbr">Interim Landscape Rating (a - b) =</td><td><xsl:value-of select="round(Landscape/CoarseFragment/InterimRating)"/></td><td class="Abbr">(c)</td><td></td><td></td><td></td><td></td></tr>

    <tr><th colspan="7">3) Other Deductions</th></tr>
    <tr><td class="Abbr">Pattern =</td><td><xsl:value-of select="round(Landscape/Pattern)"/></td><td></td><td></td><td>Pattern % Deduction =</td><td><xsl:value-of select="round(Landscape/Other/PatternPercentDeduction)"/></td><td class="Abbr"><a href="/documentation/Section6_2_3">(K)</a></td></tr>
    <tr><td class="Abbr">Flooding</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
    <tr><td>Frequency % =</td><td><xsl:value-of select="Landscape/FloodingFreq" /></td><td></td><td></td><td></td><td></td><td></td></tr>
    <tr><td>Inundation Period =</td><td><xsl:value-of select="Landscape/FloodingPeriod" /></td><td></td><td></td><td></td><td></td><td></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>Flooding % Deduction =</td><td><xsl:value-of select="round(Landscape/Other/FloodingPercentDeduction)" /></td><td class="Abbr"><a href="/documentation/Section6_2_4">(I)</a></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>Total Other % Deductions =</td><td><xsl:value-of select="round(Landscape/Other/TotalPercentDeductions)" /></td><td></td></tr>
    <tr><td></td><td></td><td></td><td></td><td>Final Other Deductions =</td><td><xsl:value-of select="round(Landscape/Other/Deduction)" /></td><td class="Abbr">(d)</td></tr>

    <tr><th colspan="7">Landscape Rating</th></tr>
    <tr><td>Final Landscape Rating (c - d) =</td><td><xsl:value-of select="round(Landscape/Rating)"/></td><td class="Abbr">(L)</td><td></td><td></td><td></td><td></td></tr>
    <tr><td>LSRS Class =</td><td><xsl:value-of select="Landscape/Class"/></td><td></td><td></td><td></td><td></td><td></td></tr>
    
  </table>

</xsl:for-each>

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
