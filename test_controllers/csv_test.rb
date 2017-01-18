# run using "script/console < app/controllers/csv_test.rb",
# or manually at the script/console prompt (but first remove leading tabs)
require 'fastercsv'

# fastest dump
csvFilename = "/home/peter/test/test.csv"
records = ActiveRecord::Base.connection.execute("SELECT * FROM gframeworks")

FasterCSV.open(csvFilename, 'w', { :force_quotes => true }) do |csv|
records.each do |row|
csv << row
end
end

# controlled dump
csvFilename = "/home/peter/test/gframeworks.csv"
records = Gframework.find(:all)
FasterCSV.open(csvFilename, 'w', { :force_quotes => true }) do |csv|
records.each do |row|
csv << [row.id, row.FrameworkURI, row.Title_en, row.GetData]
end
end


# controlled sql insert statements dump
records = Gframework.find(:all)
File.open("/home/peter/test/gframeworks.sql", "w") do |sql|
records.each do |row|
sql << "Insert into GFRAMEWORKS values"
sql << " ('" + row.id.to_s
sql << "','" + row.FrameworkURI
sql << "','" + row.Organization_en.gsub("'","''")
sql << "','" + row.Organization_fr.gsub("'","''")
sql << "','" + row.Title_en.gsub("'","''")
sql << "','" + row.Title_fr.gsub("'","''")
sql << "','" + row.Abstract_en.gsub("'","''")
sql << "','" + row.Abstract_fr.gsub("'","''")
sql << "','" + row.ReferenceDate
sql << "','" + row.StartDate
sql << "','" + row.Version
sql << "','" + row.Documentation_en
sql << "','" + row.Documentation_fr
sql << "','" + row.FrameworkKey
sql << "','" + row.MinLat.to_s
sql << "','" + row.MinLong.to_s
sql << "','" + row.MaxLat.to_s
sql << "','" + row.MaxLong.to_s
sql << "','" + row.Publish
sql << "');\n"
end
end
