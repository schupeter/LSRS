module LSRS_GDAS

  def LSRS_GDAS.top(outputFile, crop, framework, cmpTable, climateTitle, climateTableName)
    outputFile.puts '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
    if crop == "all" then
      outputFile.puts '<?xml-stylesheet type="text/xsl" href="/schemas/lsrs/5.0/stylesheets/gdasMulticropOutput_02.xsl"?>'
    else
      outputFile.puts '<?xml-stylesheet type="text/xsl" href="/schemas/lsrs/5.0/stylesheets/gdasBatchOutput_03.xsl"?>'
    end
    outputFile.puts '<GDAS service="TJS" xmlns="http://www.opengis.net/tjs/1.0" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/tjs/1.0  /schemas/tjs/1.0/tjsGetData_response.xsd" version="1.0" xml:lang="">'
    outputFile.puts ' <Framework>' + "\n"
    outputFile.puts '  <FrameworkURI>' + framework.FrameworkURI + '</FrameworkURI>'
    outputFile.puts '  <Organization>' + framework.Organization_en + '</Organization>'
    outputFile.puts '  <Title>' + framework.Title_en + '</Title>'
    outputFile.puts '  <Abstract>' + framework.Abstract_en + '</Abstract>'
    outputFile.puts '  <ReferenceDate startDate="' + framework.StartDate + '">' + framework.ReferenceDate + '</ReferenceDate>'
    outputFile.puts '  <Version>' + framework.Version + '</Version>'
    outputFile.puts '  <Documentation>' + framework.Documentation_en + '</Documentation>'
    outputFile.puts '  <FrameworkKey>'
    outputFile.puts '    <Column name="' + framework.FrameworkKey + '" type="http://www.w3.org/TR/xmlschema-2/#' + framework.DataType + '" length="' + framework.Length.to_s + '" decimals="' + framework.Decimals.to_s + '"/>'
    outputFile.puts '  </FrameworkKey>'
    outputFile.puts '  <BoundingCoordinates>'
    outputFile.puts '    <North>' + framework.North.to_s + '</North>'
    outputFile.puts '    <South>' + framework.South.to_s + '</South>'
    outputFile.puts '    <East>' + framework.East.to_s + '</East>'
    outputFile.puts '    <West>' + framework.West.to_s + '</West>'
    outputFile.puts '  </BoundingCoordinates>'
    outputFile.puts '  <DescribeDatasetsRequest xlink:href="http://lsrs.gis.agr.gc.ca/foo"/>'
		outputFile.puts '  <FrameworkName>' + framework.FrameworkName + '</FrameworkName>'
    outputFile.puts '  <Dataset>'
    outputFile.puts '   <DatasetURI>lsrs</DatasetURI>'
    outputFile.puts '   <Organization>AAFC</Organization>'
    outputFile.puts '   <Title>LSRS batch output</Title>'
    outputFile.puts '   <Abstract>LSRS batch output</Abstract>'
    outputFile.puts '   <ReferenceDate startDate="">' + DateTime::now.to_s + '</ReferenceDate>'
    outputFile.puts '   <Version>1</Version>'
    outputFile.puts '   <Documentation>n/a</Documentation>'
    outputFile.puts '   <DescribeDataRequest xlink:href="http://lsrs.gis.agr.gc.ca/foo"/>'
    outputFile.puts '   <Columnset>'
    outputFile.puts '     <FrameworkKey complete="' +  framework.Complete + '" relationship="' + framework.Relationship + '">'
    outputFile.puts '       <Column name="' + framework.FrameworkKey + '" type="http://www.w3.org/TR/xmlschema-2/#' + framework.DataType + '" length="' + framework.Length.to_s + '" decimals="' + framework.Decimals.to_s + '"/>'
    outputFile.puts '     </FrameworkKey>'
    outputFile.puts '     <Attributes>'
    outputFile.puts '       <Column name="' + crop + '" type="http://www.w3.org/TR/xmlschema-2/#string" length="30" decimals="0" purpose="Data">'
    outputFile.puts '         <Title>LSRS rating for ' + crop + '</Title>'
    outputFile.puts '         <Abstract>Nominal</Abstract>'
    outputFile.puts '         <Documentation></Documentation>'
    outputFile.puts '         <Values>'
    outputFile.puts '           <Nominal>'
    outputFile.puts '             <Classes>'
    outputFile.puts '               <Title>LSRS ratings</Title>'
    outputFile.puts '               <Abstract>LSRS ratings, based on CLI.</Abstract>'
    outputFile.puts '               <Documentation/>'
    outputFile.puts '             </Classes>'
    outputFile.puts '             <Exceptions>'
    outputFile.puts '             </Exceptions>'
    outputFile.puts '           </Nominal>'
    outputFile.puts '         </Values>'
    outputFile.puts '       </Column>'
    outputFile.puts '     </Attributes>'
    outputFile.puts '   </Columnset>'
    outputFile.puts '   <CmpTableName>' + cmpTable + '</CmpTableName>'
    outputFile.puts '   <ClimateTitle>' + climateTitle + '</ClimateTitle>'
    outputFile.puts '   <ClimateTableName>' + climateTableName + '</ClimateTableName>'
    outputFile.puts '   <Rowset>'
  end

  def LSRS_GDAS.bottom(outputFile)
    outputFile.puts '   </Rowset>'
    outputFile.puts '  </Dataset>'
    outputFile.puts ' </Framework>'
    outputFile.puts('</GDAS>')
  end

end
