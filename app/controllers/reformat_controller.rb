class ReformatController < ApplicationController

# list climate tables for dumping
def climate_list
end

# dump out climate tables
def climate_dump
	tableMetadata = LsrsClimate.where(:WarehouseName=>params[:table]).first
	outputCsvFile = File.open("/development/data/climate/#{params[:table]}.txt", 'w')
	outputCsvFile.puts '--- #YAML'
	outputCsvFile.puts 'Title: "' + tableMetadata.Title_en + '"'
	outputCsvFile.puts 'Geography: "Polygons"'
	outputCsvFile.puts 'Framework: "' + tableMetadata.PolygonTable + '"'
	outputCsvFile.puts 'Timeframe: "???"'
	outputCsvFile.puts 'Origin: "Observations???"'
	outputCsvFile.puts 'Description: "???"'
	outputCsvFile.puts '--- #TSV'
	outputCsvFile.puts "id	long	lat	elev	tmax01	tmax02	tmax03	tmax04	tmax05	tmax06	tmax07	tmax08	tmax09	tmax10	tmax11	tmax12	tmin01	tmin02	tmin03	tmin04	tmin05	tmin06	tmin07	tmin08	tmin09	tmin10	tmin11	tmin12	ptot01	ptot02	ptot03	ptot04	ptot05	ptot06	ptot07	ptot08	ptot09	ptot10	ptot11	ptot12"
	records = eval(params[:table].capitalize).all
	for r in records do
		outputCsvFile.puts "#{r.id}	#{r.long}	lat	elev	tmax01	tmax02	tmax03	tmax04	tmax05	tmax06	tmax07	tmax08	tmax09	tmax10	tmax11	tmax12	tmin01	tmin02	tmin03	tmin04	tmin05	tmin06	tmin07	tmin08	tmin09	tmin10	tmin11	tmin12	ptot01	ptot02	ptot03	ptot04	ptot05	ptot06	ptot07	ptot08	ptot09	ptot10	ptot11	ptot12"
	end
	outputCsvFile.close
		
	
end


# This program reformats batch outputs
def test 

require 'csv'

@output = CSV.read("/production/sites/sislsrs/public/batch/results/20150616t121533r8504/output.csv", headers:true, header_converters: :symbol, converters: :all, col_sep: ",").collect {|row| row.to_hash}

require 'dbf'
require "#{Rails.root}/app/helpers/dbf-helper"

# prepare the fields array, which defines the dbf structure
fields = Array.new
fields.push({:field_name=>"POLY_ID", :field_size=>13, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"CMP_ID", :field_size=>15, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"POLY_RATING", :field_size=>20, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"CMP", :field_size=>2, :field_type=>"N", :decimals=>0})
fields.push({:field_name=>"PERCENT", :field_size=>3, :field_type=>"N", :decimals=>0})
fields.push({:field_name=>"CMP_CLASS", :field_size=>8, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"CLIMATE_POINTS", :field_size=>3, :field_type=>"N", :decimals=>0})
fields.push({:field_name=>"CLIMATE_CLASS", :field_size=>8, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"PROVINCE", :field_size=>2, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"SOIL_CODE", :field_size=>8, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"SOIL_NAME", :field_size=>30, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"SOIL_POINTS", :field_size=>3, :field_type=>"N", :decimals=>0})
fields.push({:field_name=>"SOIL_CLASS", :field_size=>8, :field_type=>"C", :decimals=>0})
fields.push({:field_name=>"LANDSCAPE_POINTS", :field_size=>3, :field_type=>"N", :decimals=>0})
fields.push({:field_name=>"LANDSCAPE_CLASS", :field_size=>8, :field_type=>"C", :decimals=>0})

# prepare the records array, which contains the content
records = Array.new 
rownum = 0
for csvRow in @output
dbaseRow = Hash.new
dbaseRow[:POLY_ID] = csvRow[:poly_id]
dbaseRow[:CMP_ID] = csvRow[:cmp_id]
dbaseRow[:POLY_RATING] = csvRow[:poly_rating]
dbaseRow[:CMP] = csvRow[:cmp]
dbaseRow[:PERCENT] = csvRow[:percent]
dbaseRow[:CMP_CLASS] = "#{csvRow[:cmp_class]}"
dbaseRow[:CLIMATE_POINTS] = csvRow[:climate_points]
dbaseRow[:CLIMATE_CLASS] = csvRow[:climate_class]
dbaseRow[:PROVINCE] = csvRow[:province]
dbaseRow[:SOIL_CODE] = csvRow[:soil_code]
dbaseRow[:SOIL_NAME] = csvRow[:soil_name]
dbaseRow[:SOIL_POINTS] = csvRow[:soil_points]
dbaseRow[:SOIL_CLASS] = csvRow[:soil_class]
dbaseRow[:LANDSCAPE_POINTS] = csvRow[:landscape_points]
dbaseRow[:LANDSCAPE_CLASS] = csvRow[:landscape_class]
records[rownum] = dbaseRow # add the completed hash to the records array
rownum += 1
end

dbf_writer("/production/sites/sislsrs/public/batch/results/20150616t121533r8504/output2.dbf", fields, records)



end


end
