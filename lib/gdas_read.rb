module GDAS_read

  class Framework
    attr_accessor :FrameworkURI, :Organization, :Title, :Abstract, :ReferenceDate, :StartDate, :Version, :Documentation, :FrameworkKey, :FrameworkKeyType, :FrameworkKeyLength, :FrameworkKeyDecimals, :North, :South, :East, :West, :DescribeDatasets
  end

  def GDAS_read.framework(gdas)
    framework = Framework.new
    framework.FrameworkURI = gdas.search("//tjs:GDAS/tjs:Framework/tjs:FrameworkURI").first.content
    framework.Organization = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Organization").first.content
    framework.Title = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Title").first.content
    framework.Abstract = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Abstract").first.content
    framework.ReferenceDate = gdas.search("//tjs:GDAS/tjs:Framework/tjs:ReferenceDate").first.content
		if gdas.search("//tjs:GDAS/tjs:Framework/tjs:ReferenceDate/@startDate") != [] then
			framework.StartDate = gdas.search("//tjs:GDAS/tjs:Framework/tjs:ReferenceDate/@startDate").first.value
		end
    framework.Version = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Version").first.content
    framework.Documentation = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Documentation").first.content
    framework.FrameworkKey = gdas.search("//tjs:GDAS/tjs:Framework/tjs:FrameworkKey/tjs:Column/@name").first.value
    framework.FrameworkKeyType = gdas.search("//tjs:GDAS/tjs:Framework/tjs:FrameworkKey/tjs:Column/@type").first.value.split('#')[1]
    framework.FrameworkKeyLength = gdas.search("//tjs:GDAS/tjs:Framework/tjs:FrameworkKey/tjs:Column/@length").first.value
    framework.FrameworkKeyDecimals = gdas.search("//tjs:GDAS/tjs:Framework/tjs:FrameworkKey/tjs:Column/@decimals").first.value
    framework.North = gdas.search("//tjs:GDAS/tjs:Framework/tjs:BoundingCoordinates/tjs:North").first.content
    framework.South = gdas.search("//tjs:GDAS/tjs:Framework/tjs:BoundingCoordinates/tjs:South").first.content
    framework.East = gdas.search("//tjs:GDAS/tjs:Framework/tjs:BoundingCoordinates/tjs:East").first.content
    framework.West = gdas.search("//tjs:GDAS/tjs:Framework/tjs:BoundingCoordinates/tjs:West").first.content
    framework.DescribeDatasets = gdas.search("//tjs:GDAS/tjs:Framework/tjs:DescribeDatasetsRequest").first.content
		# return result as an array so it matches Rails database queries
    return Array(framework)
  end

  def GDAS_read.frameworkgeneric(root, ns, xml)
    framework = Framework.new
    framework.FrameworkURI = xml.search("#{root}/#{ns}Framework/#{ns}FrameworkURI").first.content
    framework.Organization = xml.search("#{root}/#{ns}Framework/#{ns}Organization").first.content
    framework.Title = xml.search("#{root}/#{ns}Framework/#{ns}Title").first.content
    framework.Abstract = xml.search("#{root}/#{ns}Framework/#{ns}Abstract").first.content
    framework.ReferenceDate = xml.search("#{root}/#{ns}Framework/#{ns}ReferenceDate").first.content
		if xml.search("#{root}/#{ns}Framework/#{ns}ReferenceDate/@startDate") != [] then
			framework.StartDate = xml.search("#{root}/#{ns}Framework/#{ns}ReferenceDate/@startDate").first.value
		end
    framework.Version = xml.search("#{root}/#{ns}Framework/#{ns}Version").first.content
    framework.Documentation = xml.search("#{root}/#{ns}Framework/#{ns}Documentation").first.content
    framework.FrameworkKey = xml.search("#{root}/#{ns}Framework/#{ns}FrameworkKey/#{ns}Column/@name").first.value
    framework.FrameworkKeyType = xml.search("#{root}/#{ns}Framework/#{ns}FrameworkKey/#{ns}Column/@type").first.value.split('#')[1]
    framework.FrameworkKeyLength = xml.search("#{root}/#{ns}Framework/#{ns}FrameworkKey/#{ns}Column/@length").first.value
    framework.FrameworkKeyDecimals = xml.search("#{root}/#{ns}Framework/#{ns}FrameworkKey/#{ns}Column/@decimals").first.value
    framework.North = xml.search("#{root}/#{ns}Framework/#{ns}BoundingCoordinates/#{ns}North").first.content
    framework.South = xml.search("#{root}/#{ns}Framework/#{ns}BoundingCoordinates/#{ns}South").first.content
    framework.East = xml.search("#{root}/#{ns}Framework/#{ns}BoundingCoordinates/#{ns}East").first.content
    framework.West = xml.search("#{root}/#{ns}Framework/#{ns}BoundingCoordinates/#{ns}West").first.content
    #framework.DescribeDatasets = xml.search("#{root}/#{ns}Framework/#{ns}DescribeDatasetsRequest/@xlink:href").first.content
		# return result as an array so it matches Rails database queries
    return Array(framework)
  end

  class Datasetx
    attr_accessor  :DatasetURI, :Organization, :Title, :Abstract, :ReferenceDate, :StartDate, :Version, :Documentation, :FrameworkKey, :KeyType, :KeyLength, :KeyDecimals, :KeyRelationship, :KeyComplete
  end

  def GDAS_read.dataset(gdas)
    dataset = Datasetx.new
    dataset.DatasetURI = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:DatasetURI").first.content
    dataset.Organization = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Organization").first.content
    dataset.Title = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Title").first.content
    dataset.Abstract = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Abstract").first.content
    dataset.ReferenceDate = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:ReferenceDate").first.content
		if gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:ReferenceDate/@startDate") != [] then
			dataset.StartDate = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:ReferenceDate/@startDate").first.value
		end
		dataset.Version = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Version").first.content
    dataset.Documentation = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Documentation").first.content
    dataset.FrameworkKey = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:FrameworkKey/tjs:Column/@name").first.value
    dataset.KeyType = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:FrameworkKey/tjs:Column/@type").first.value.split('#')[1]
    dataset.KeyLength = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:FrameworkKey/tjs:Column/@length").first.value
    dataset.KeyDecimals = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:FrameworkKey/tjs:Column/@decimals").first.value
    dataset.KeyRelationship = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:FrameworkKey/@relationship").first.value
    dataset.KeyComplete = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:FrameworkKey/@complete").first.value
		# return result as an array so it matches Rails database queries
    return Array(dataset)
  end

  def  GDAS_read.attributesAsXML(gdas)
    attributesXmlArray = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Attribute")
  end

  # these three class definitions need to mirror the database structure
  class Attribute
    attr_accessor :DatasetURI, :AttributeName, :Type, :Length, :Decimals, :Purpose, :TitlePrefix, :Documentation, :gattributedescription
  end

  class AttributeDescription
    attr_accessor :Title, :Abstract, :Documentation, :Kind, :Gaussian, :ShortUOM, :LongUOM, :ClassesTitle, :ClassesAbstract, :ClassesDocumentation, :ClassesURI, :Values
  end

  class Value
    attr_accessor :Identifier, :Title, :Abstract, :Documentation, :Rank, :Color
  end
	
  def GDAS_read.attributes(gdas, searchDepth)
		# store attribute metadata in one large hash called allAttributesHash, with the keys being the attribute names
		# the value of each key is another hash, with three keys: (Description, Values, and Nulls) 
		# "Description" contains a Hash, "Values" and "Nulls" are each arrays of hashes.
		# 
    attributesXmlArray = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset/tjs:Attributes/tjs:Column")
#    allAttributesHash = Hash.new
    attributesArray = Array.new
		attributeNumber = 0
    for attributeXML in attributesXmlArray do
      attributeXML.register_default_namespace("tjs")
      attribute = Attribute.new
      attribute.gattributedescription = AttributeDescription.new
      attribute.DatasetURI = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:DatasetURI").first.content
			attribute.Type = attributeXML.search("@type").first.value.split('#')[1]
			attribute.Length = attributeXML.search("@length").first.value.to_i
			attribute.Decimals = attributeXML.search("@decimals").first.value.to_i
      attribute.Purpose = attributeXML.search("@purpose").first.value
      attribute.AttributeName = attributeXML.search("@name").first.value
      attribute.gattributedescription.Title = attributeXML.search("tjs:Title").first.content
      attribute.gattributedescription.Abstract = attributeXML.search("tjs:Abstract").first.content
      attribute.gattributedescription.Documentation = attributeXML.search("tjs:Documentation").first.content
      if attributeXML.search("tjs:Values/tjs:Nominal") != []
        attribute.gattributedescription.Kind = "Nominal"
        classesXmlArray = attributeXML.search("tjs:Values/tjs:Nominal/tjs:Classes")
        if classesXmlArray != [] and searchDepth == "all" then
          # COMPLETE THIS SECTION and equivalent sections below
					attribute.gattributedescription.ClassesURI = "foobar"
        else
          attribute.gattributedescription.ClassesURI = "n/a"
        end
				nullsArray = [] # FIX THIS!!!!!!!!!!!!!!
      end
      if attributeXML.search("tjs:Values/tjs:Ordinal") != [] # THIS SECTION SHOULD BE WORKING NOW
        attribute.gattributedescription.Kind = "Ordinal"
        classesXmlArray = attributeXML.search("tjs:Values/tjs:Ordinal/tjs:Classes")
        if classesXmlArray != [] and searchDepth == "all" then
					# get the class description
					classHash = AttributeDescription.new
					classHash.ClassesTitle = attributeXML.search("tjs:Values/tjs:Ordinal/tjs:Classes/tjs:Title").first.content
					classHash.ClassesAbstract = attributeXML.search("tjs:Values/tjs:Ordinal/tjs:Classes/tjs:Abstract").first.content
					classHash.ClassesDocumentation = attributeXML.search("tjs:Values/tjs:Ordinal/tjs:Classes/tjs:Documentation").first.content
					# get the valid values
					valuesXmlArray = attributeXML.search("tjs:Values/tjs:Ordinal/tjs:Classes/tjs:Value")
					valuesArray = Array.new
					for valueXML in valuesXmlArray do
						valueXML.register_default_namespace("tjs")
						value = Value.new
						value.Identifier = valueXML.search("tjs:Identifier").first.content
						value.Title = valueXML.search("tjs:Title").first.content
						value.Abstract = valueXML.search("tjs:Abstract").first.content
						value.Documentation = valueXML.search("tjs:Documentation").first.content
						value.Rank = valueXML.search("@rank").first.value
						value.Color = valueXML.search("@color").first.value
						valuesArray.push value
					end
					# get the null values 
					nullsXmlArray = attributeXML.search("tjs:Values/tjs:Ordinal/tjs:Classes/tjs:Exception")
					nullsArray = Array.new
					for nullXML in nullsXmlArray do
						nullXML.register_default_namespace("tjs")
						null = Value.new
						null.Identifier = nullXML.search("tjs:Identifier").first.content
						null.Title = nullXML.search("tjs:Title").first.content
						null.Abstract = nullXML.search("tjs:Abstract").first.content
						null.Documentation = nullXML.search("tjs:Documentation").first.content
						null.Color = nullXML.search("@color").first.value
						nullsArray.push null
					end
					attribute.gattributedescription.ClassesURI = "foobar"
        else
          attribute.gattributedescription.ClassesURI = "n/a"
        end
      end
      if attributeXML.search("tjs:Values/tjs:Measure") != []
        attribute.gattributedescription.Kind = "Measure"
        attribute.gattributedescription.ShortUOM = attributeXML.search("tjs:Values/tjs:Measure/tjs:UOM/tjs:ShortForm").first.content
        attribute.gattributedescription.LongUOM = attributeXML.search("tjs:Values/tjs:Measure/tjs:UOM/tjs:LongForm").first.content
        classesXmlArray = attributeXML.search("tjs:Values/tjs:Measure/tjs:Classes")
        if classesXmlArray != [] and searchDepth == "all" then
					# get the class description
					classHash = AttributeDescription.new
					classHash.ClassesTitle = attributeXML.search("tjs:Values/tjs:Measure/tjs:Classes/tjs:Title").first.content
					classHash.ClassesAbstract = attributeXML.search("tjs:Values/tjs:Measure/tjs:Classes/tjs:Abstract").first.content
					classHash.ClassesDocumentation = attributeXML.search("tjs:Values/tjs:Measure/tjs:Classes/tjs:Documentation").first.content
					# get the null values 
					nullsXmlArray = attributeXML.search("tjs:Values/tjs:Measure/tjs:Classes/tjs:Exception")
					nullsArray = Array.new
					for nullXML in nullsXmlArray do
						nullXML.register_default_namespace("tjs")
						null = Value.new
						null.Identifier = nullXML.search("tjs:Identifier").first.content
						null.Title = nullXML.search("tjs:Title").first.content
						null.Abstract = nullXML.search("tjs:Abstract").first.content
						null.Documentation = nullXML.search("tjs:Documentation").first.content
						null.Color = nullXML.search("@color").first.value
						nullsArray.push null
					end
					attribute.gattributedescription.ClassesURI = "foobar"
        else
          attribute.gattributedescription.ClassesURI = "n/a"
        end
				nullsArray = [] # FIX THIS!!!!!!!!!!!!!!
				valuesArray = []
      end
      if attributeXML.search("tjs:Values/tjs:Count") != []
        attribute.gattributedescription.Kind = "Count"
        attribute.gattributedescription.ShortUOM = attributeXML.search("tjs:Values/tjs:Count/tjs:UOM/tjs:ShortForm").first.content
        attribute.gattributedescription.LongUOM = attributeXML.search("tjs:Values/tjs:Count/tjs:UOM/tjs:LongForm").first.content
        classesXmlArray = attributeXML.search("tjs:Values/tjs:Count/tjs:Classes")
        if classesXmlArray != [] and searchDepth == "all" then
          # COMPLETE THIS SECTION and equivalent sections below
					attribute.gattributedescription.ClassesURI = "foobar"
        else
          attribute.gattributedescription.ClassesURI = "n/a"
        end
				nullsArray = [] # FIX THIS!!!!!!!!!!!!!!
      end
			attributeNumber += 1
			attributeHash = Hash.new
			attributeHash["AttributeNumber"] = attributeNumber
			attributeHash["Description"] = attribute
			attributeHash["Class"] = classHash
			attributeHash["Values"] = valuesArray
			attributeHash["Nulls"] = nullsArray
#			allAttributesHash[attribute.AttributeName] = attributeHash
      attributesArray.push attributeHash
			
    end
#    return allAttributesHash
    return attributesArray
  end

  def GDAS_read.rowset_asStrings(gdas)
    # store each Row XML element in a separate array element - NULLS ARE NOT HANDLED!
    rowsetXmlArray = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Rowset/tjs:Row")
    #create array containing content of all rows.  Each element is an array, with K in position 0 followed by Vs
    # Note that this differs from how the data is stored when writing the rowset in the partial _gdas_write_rowset.rb
    rowsetArray = Array.new
    for row in rowsetXmlArray do
      row.register_default_namespace("tjs")
      rowArray = Array.new
      rowArray.push row.search("tjs:K").first.content
      vXMLArray = row.search("tjs:V").to_a
      for value in vXMLArray do
        rowArray.push value.content 
      end
      rowsetArray.push rowArray
    end
    return rowsetArray
  end

  def  GDAS_read.attributesAsXML(gdas)
    attributesXmlArray = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Columnset")
  end

  def GDAS_read.rowset(gdas, keyType, valueTypeArray)
    # store each Row XML element in a separate array element.  Retain original string values and create interpreted values.
    rowsetXmlArray = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Rowset/tjs:Row")
    #create an array containing content of all rows.  Each element is an array, with K in position 0 followed by each V as part of its own array
		# the V array contains the original value in position 0 and an object of correct type (according to the metadata) or nil in position 1. 
    # Note that this differs from how the data is stored when writing the rowset in the partial _gdas_write_rowset.rb
		rowsetArray = Array.new
		for row in rowsetXmlArray do
			row.register_default_namespace("tjs")
			rowArray = Array.new
			# populate K value in rowArray
			case keyType 
				when "string" then rowArray.push row.search("tjs:K").first.content
				when "integer" then rowArray.push row.search("tjs:K").first.content.to_i
				when "float" then rowArray.push row.search("tjs:K").first.content.to_f  # TODO: add other types
			end
			# populate V values in rowArray
			vXMLArray = row.search("tjs:V").to_a
			vXMLArray.each_with_index {|value, i|
				vArray = Array.new
				vArray.push value.content
				if value.search("@null") != [] then 
					vArray.push nil 
				else
					case valueTypeArray[i] # TODO:  ADD THE OTHER TYPES IN HERE
						#
						# TODO:  USE eval("vArray.push value.content.#{valueTypeArray[i]}") after adjusting the contents of valueTypeArray
						when "string" then vArray.push value.content.to_s
						when "integer" then vArray.push value.content.to_i
						when "float" then vArray.push value.content.to_f
					end
				end
				rowArray.push vArray 
			}
			rowsetArray.push rowArray
		end
    return rowsetArray
	end

  def GDAS_read.rowset_test(gdas, keyType, valueMethodArray)
    # store each Row XML element in a separate array element.  Retain original string values and create interpreted values.
    rowsetXmlArray = gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Rowset/tjs:Row")
    #create an array containing content of all rows.  Each element is an array, with K in position 0 followed by each V as part of its own array
		# the V array contains the original value in position 0 and an object of correct type (according to the metadata) or nil in position 1. 
    # Note that this differs from how the data is stored when writing the rowset in the partial _gdas_write_rowset.rb
		rowsetArray = Array.new
		for row in rowsetXmlArray do
			row.register_default_namespace("tjs")
			rowArray = Array.new
			# populate K value in rowArray
			case keyType 
				when "string" then rowArray.push row.search("tjs:K").first.content
				when "integer" then rowArray.push row.search("tjs:K").first.content.to_i
				when "float" then rowArray.push row.search("tjs:K").first.content.to_f  # TODO: add other types
			end
			# populate V values in rowArray
			vXMLArray = row.search("tjs:V").to_a
			vXMLArray.each_with_index {|value, i|
				vArray = Array.new
				vArray.push value.content
				if value.search("@null") != [] then 
					vArray.push nil 
				else
					eval("vArray.push value.content.#{valueMethodArray[i]}")
				end
				rowArray.push vArray 
			}
			rowsetArray.push rowArray
		end
    return rowsetArray
	end

	def GDAS_read.datatypeStrings(inputAttributesHash)
		valueTypeArray = Array.new
		inputAttributesHash.each_value { |value| valueTypeArray[value['AttributeNumber'] - 1] = value["Description"].Type} 
		return valueTypeArray
	end

  def GDAS_read.datatypeMethods(valueTypeArray)
		valueMethodArray = valueTypeArray.map {|v| 
		case v
		when "string" then "to_s"
		when "integer" then  "to_i"
		when "float" then "to_f"
		end
		}
	end

end