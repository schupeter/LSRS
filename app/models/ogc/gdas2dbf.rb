module GDAS2DBF
  
  def GDAS2DBF.convert(gdas, dbfname, rails_root)
    #initialize environment
    require "/production/sites/sislsrs/app/models/ogc/gdas_read"
    require 'dbf'
    require "/production/sites/sislsrs/app/helpers/dbf-helper"
    
    # get GDAS file
    gdas.register_default_namespace("tjs")

    # get the metadata
    @frameworkHash = GDAS_read.framework(gdas)[0]
    @attributesArray = GDAS_read.attributes(gdas, "none")
    #@attributesXMLArray = GDAS_read.attributesAsXML(gdas)
    valueTypeArray = Array.new
    for attribute in @attributesArray do
      valueTypeArray.push attribute["Description"].Type
    end

    # prepare the fields array, which defines the structure of the new dbase file 
    fields = Array.new
    if @frameworkHash.FrameworkKeyType == "string" then fieldType = "C" else fieldType = "N" end
    fields.push({:field_name=>@frameworkHash.FrameworkKey.upcase, :field_size=>@frameworkHash.FrameworkKeyLength.to_i, :field_type=>fieldType, :decimals=>@frameworkHash.FrameworkKeyDecimals.to_i})
#  fields.push({:field_name=>"POLY_ID", :field_size=>12, :field_type=>"N", :decimals=>0})  # FIX THIS HARD CODING
    for attribute in @attributesArray do
      case attribute["Description"].Type # TODO expand list of valid values
        when "string" then columnType = "C"
        when "float" then columnType = "N"
        when "integer" then columnType = "N"
      end
      fields.push({:field_name=>attribute["Description"].AttributeName.upcase, :field_size=>attribute["Description"].Length, :field_type=>columnType, :decimals=>attribute["Description"].Decimals})
    end

    # get the data
    @rowsetArray = GDAS_read.rowset(gdas, @frameworkHash.FrameworkKeyType, valueTypeArray)
    # prepare the records array, which contains the content
    records = Array.new 
    rownum = 0
    for gdasRow in @rowsetArray
      dbaseRow = Hash.new
      dbaseRow[:POLY_ID] = gdasRow[0]
      dbaseRow[@attributesArray[0]["Description"].AttributeName.upcase.to_sym] = gdasRow[1][0]
      records[rownum] = dbaseRow # add the completed hash to the records array
      rownum += 1
    end

    # write out dbase file
    dbf_writer(dbfname, fields, records)
  end

end