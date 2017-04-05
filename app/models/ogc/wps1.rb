class Wps1
  def Wps1.CreateStatusXml(statusURL, outputURL, cmpTable, fromSL, toSL, crop, management, climateTable, status, percentCompleted)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
    xml.instruct! :'xml-stylesheet', :type=>"text/xsl", :href=>"/schemas/lsrs/5.0/stylesheets/lsrsBatchStatus.xsl" 
    xml.tag!("wps:ExecuteResponse", 
    "xml:lang".to_sym => "en", 
    "service".to_sym => "WPS", 
    "version".to_sym => "1.0.0", 
    "xsi:schemaLocation".to_sym => "http://www.opengis.net/wps/1.0.0 ../wpsExecute_response.xsd",
    "xmlns:ows".to_sym => "http://www.opengis.net/ows/1.1", 
    "xmlns:wps".to_sym => "http://www.opengis.net/wps/1.0.0", 
    "xmlns:xlink".to_sym => "http://www.w3.org/1999/xlink",
    "xmlns:xsi".to_sym => "http://www.w3.org/2001/XMLSchema-instance",
    "statusLocation".to_sym => statusURL) do
      xml.tag!("wps:Process", "processVersion".to_sym => "1")  do
        xml.tag!("ows:Identifier", "LSRS")
        xml.tag!("ows:Title", "LSRS output")
        xml.tag!("ows:Abstract", "LSRS output")
        xml.tag!("wps:Profile", "None")
        xml.tag!("wps:WSDL", "xlink:href" => "http://foo.bar/foo")
      end
      xml.tag!("wps:Status", "creationTime".to_sym => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")) do
        if status == "ProcessAccepted" then xml.tag!("wps:ProcessAccepted") end
        if status == "ProcessStarted" then xml.tag!("wps:ProcessStarted", "percentCompleted".to_sym => percentCompleted) end
        if status == "ProcessSucceeded" then xml.tag!("wps:ProcessSuceeded") end
      end
      xml.tag!("wps:DataInputs") do
        xml.tag!("wps:Input") do
          xml.tag!("ows:Identifier", "CmpTable")
          xml.tag!("ows:Title", "Component Table")
          xml.tag!("wps:Data") do
            xml.tag!("wps:LiteralData", cmpTable)
          end
        end
        xml.tag!("wps:Input") do
          xml.tag!("ows:Identifier", "FromPoly")
          xml.tag!("ows:Title", "From Polygon Identifer")
          xml.tag!("wps:Data") do
            xml.tag!("wps:LiteralData", fromSL)
          end
        end
        xml.tag!("wps:Input") do
          xml.tag!("ows:Identifier", "ToPoly")
          xml.tag!("ows:Title", "To Polygon Identifier")
          xml.tag!("wps:Data") do
            xml.tag!("wps:LiteralData", toSL)
          end
        end
        xml.tag!("wps:Input") do
          xml.tag!("ows:Identifier", "Crop")
          xml.tag!("ows:Title", "Crop to be rated")
          xml.tag!("wps:Data") do
            xml.tag!("wps:LiteralData", crop)
          end
        end
        xml.tag!("wps:Input") do
          xml.tag!("ows:Identifier", "Management")
          xml.tag!("ows:Title", "Soil management assumptions")
          xml.tag!("wps:Data") do
            xml.tag!("wps:LiteralData", management)
          end
        end
        xml.tag!("wps:Input") do
          xml.tag!("ows:Identifier", "ClimateTable")
          xml.tag!("ows:Title", "Climate Table")
          xml.tag!("wps:Data") do
            xml.tag!("wps:LiteralData", climateTable)
          end
        end
      end
      xml.tag!("wps:OutputDefinitions") do
        xml.tag!("wps:Output", "mimeType".to_sym => "text/xml", "encoding".to_sym => "UTF-8", "schema".to_sym => "http://foo.bar/lsrs_schema.xsd", "asReference".to_sym => "true") do
          xml.tag!("ows:Identifier", "LSRS ratings")
          xml.tag!("ows:Title", "LSRS ratings")
          xml.tag!("ows:Abstract", "LSRS ratings")
        end
      end
      xml.tag!("wps:ProcessOutputs") do
        xml.tag!("wps:Output") do
          xml.tag!("ows:Identifier", "LSRS ratings")
          xml.tag!("ows:Title", "LSRS ratings")
          xml.tag!("ows:Abstract", "LSRS ratings")
          xml.tag!("wps:Reference", "mimeType".to_sym => "text/xml", "encoding".to_sym => "UTF-8", "schema".to_sym => "http://foo.bar/lsrs_schema.xsd", "href".to_sym => outputURL)
        end
      end
    end
    return xml
  end

  def Wps1.CreateOutputXml(crop, ratingArray)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
    xml.instruct! :'xml-stylesheet', :type=>"text/xsl", :href=>"/stylesheets/lsrs/1.0/lsrsBatch.xsl" 
    xml.LSRS do
      xml.Crop(crop)
      for record in ratingArray do
        xml.Polygon do
          xml.Id(record[0])
          xml.Rating(record[1])
        end
      end
    end
		return xml
  end

 def Wps1.DescribeProcess(processHash, lang)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
    xml.tag!("wps:ProcessDescription", 
    "xml:lang".to_sym => "#{lang}", 
    "service".to_sym => "WPS", 
    "version".to_sym => "1.0.0", 
    "xsi:schemaLocation".to_sym => "http://www.opengis.net/wps/1.0.0 ../wpsDescribeProcess_response.xsd",
    "xmlns:ows".to_sym => "http://www.opengis.net/ows/1.1", 
    "xmlns:wps".to_sym => "http://www.opengis.net/wps/1.0.0", 
    "xmlns:xlink".to_sym => "http://www.w3.org/1999/xlink",
    "xmlns:xsi".to_sym => "http://www.w3.org/2001/XMLSchema-instance",
    "processVersion".to_sym => "#{processHash['processVersion']}", 
    "storeSupported".to_sym => "#{processHash['storeSupported']}", 
    "statusSupported".to_sym => "#{processHash['statusSupported']}") do
      xml.tag!("ows:Identifier", "#{processHash['identifier']}")
      xml.tag!("ows:Title", "#{processHash['Title'][lang]}")
      xml.tag!("ows:Abstract", "#{processHash['Abstract'][lang]}")
      for metadata in processHash['Metadata'][lang]
        xml.tag!("ows:Metadata", "xlink:title".to_sym => "#{metadata}")
      end # for metadata
      xml.tag!("wps:Profile", "#{processHash['Profile']}")
      xml.tag!("DataInputs") do
        for input in processHash['DataInputs']
          xml.tag!("Input",
          "minOccurs".to_sym => "#{input['minOccurs']}", 
          "maxOccurs".to_sym => "#{input['maxOccurs']}") do
            xml.tag!("ows:Identifier", "#{input['Identifier']}")
            xml.tag!("ows:Title", "#{input['Title'][lang]}")
            xml.tag!("ows:Abstract", "#{input['Abstract'][lang]}")
            case input['InputForm'] 
              when "ComplexData"
                xml.tag!("#{input['InputForm']}",
                "maximumMegabytes".to_sym => "#{input['maximumMegabytes']}") do
                  xml.tag!("Default") do
                    xml.tag!("Format") do
                      xml.tag!("MimeType", "#{input['DefaultFormat']['Format']['MimeType']}")
                      xml.tag!("Encoding", "#{input['DefaultFormat']['Format']['Encoding']}")
                      xml.tag!("Schema", "#{input['DefaultFormat']['Format']['Schema']}")
                    end # Format
                  end # Default
                  xml.tag!("Supported") do
                    for format in input['SupportedFormats']
                      xml.tag!("Format") do
                        xml.tag!("MimeType", "#{format['MimeType']}")
                        xml.tag!("Encoding", "#{format['Encoding']}")
                        xml.tag!("Schema", "#{format['Schema']}")
                      end # Format
                    end # for format
                  end # Supported
                end # InputForm
              when "LiteralData"
                xml.tag!("#{input['InputForm']}") do
                  xml.tag!("ows:DataType", input['DataType'], "ows:reference".to_sym => ("http://www.w3.org/TR/xmlschema-2/#" + input['DataType']))
                  xml.tag!("UOMs") do
                    xml.tag!("Default") do
                      xml.tag!("ows:UOM", "#{input['UOMs']['Default']}")
                    end # Default
                    xml.tag!("Supported") do
                      for uom in input['UOMs']['Supported']
                        xml.tag!("ows:UOM", "#{uom}")
                      end #for uom
                    end # Supported
                  end # UOMs
                  xml.tag!("ows:AnyValue") # HARD CODED FOR NOW - EXPAND ON THIS SECTION WHEN NEEDED !!!!!!!!!
                  xml.tag!("DefaultValue", "#{input['DefaultValue']}")
                end # InputForm
              when "BoundingBox"
              # CREATE THIS SECTION WHEN NEEDED !!!!!!!!!
            end # case InputForm
          end # Input
        end # for input
      end # DataInputs
      # ADD SUPPORT FOR literaldata AND boundingboxdata IN PROCESSOUTPUTS
      xml.tag!("ProcessOutputs") do
        for output in processHash['ProcessOutputs']
          xml.tag!("Output") do
            xml.tag!("ows:Identifier", "#{output['Identifier']}")
            xml.tag!("ows:Title", "#{output['Title'][lang]}")
            xml.tag!("ows:Abstract", "#{output['Abstract'][lang]}")
            xml.tag!("#{output['OutputForm']}") do
              xml.tag!("Default") do
                xml.tag!("Format") do
                  xml.tag!("MimeType", "#{output['DefaultFormat']['Format']['MimeType']}")
                  xml.tag!("Encoding", "#{output['DefaultFormat']['Format']['Encoding']}")
                  xml.tag!("Schema", "#{output['DefaultFormat']['Format']['Schema']}")
                end # Format
              end # Default
              xml.tag!("Supported") do
                for format in output['SupportedFormats']
                  xml.tag!("Format") do
                    xml.tag!("MimeType", "#{format['MimeType']}")
                    xml.tag!("Encoding", "#{format['Encoding']}")
                    xml.tag!("Schema", "#{format['Schema']}")
                  end # Format
                end # for format
              end # Supported
            end # OutputForm
          end # Output
        end # for output
      end # wps:ProcessOutputs
    end # wps:ProcessDescriptions
		return xml
  end
end