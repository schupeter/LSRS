# TRY #1
drainageFactorHash = {"PerDecim"=>2, "ClimateRating"=>54, "remainingSubfactorArray"=>[], "Percent"=>20, "PrimarySubfactor"=>nil, "Class"=>3, "LandscapeRating"=>0, "SoilRating"=>0, "MostLimitingFactor"=>"Soil", "Subfactors"=>"AH"}
dominantFactorHash = {"PerDecim"=>7, "ClimateRating"=>54, "remainingSubfactorArray"=>[["H", 54.3822716736]], "Percent"=>70, "PrimarySubfactor"=>"A", "Class"=>3, "LandscapeRating"=>89.3333334, "SoilRating"=>61.7704915924883, "MostLimitingFactor"=>"Climate", "Subfactors"=>"AH"}
dissimilarFactorHash = {"PerDecim"=>1, "ClimateRating"=>54, "remainingSubfactorArray"=>[["D", 24.0485]], "Percent"=>10, "PrimarySubfactor"=>"M", "Class"=>4, "LandscapeRating"=>89.3333334, "SoilRating"=>39.2149353202108, "MostLimitingFactor"=>"Soil", "Subfactors"=>"MD"}
# create a new set of arrays for processing
percentArray = Array.new
classArray = Array.new
classSubclassArray = Array.new
# populate arrays with valid values 
if drainageFactorHash['PerDecim'] != 0 then
percentArray.push(drainageFactorHash['Percent'])
classArray.push(drainageFactorHash['Class'])
classSubclassArray.push(drainageFactorHash['Class'].to_s + drainageFactorHash['Subfactors'])
end
if dominantFactorHash['PerDecim'] != 0 then
percentArray.push(dominantFactorHash['Percent'])
classArray.push(dominantFactorHash['Class'])
classSubclassArray.push(dominantFactorHash['Class'].to_s + dominantFactorHash['Subfactors'])
end
if dissimilarFactorHash['PerDecim'] != 0 then
percentArray.push(dissimilarFactorHash['Percent'])
classArray.push(dissimilarFactorHash['Class'])
classSubclassArray.push(dissimilarFactorHash['Class'].to_s + dissimilarFactorHash['Subfactors'])
end
# combine categories where class and subclass are identical
if classSubclassArray.uniq.size < classSubclassArray.size then
newclassSubclassArray = classSubclassArray.uniq
newpercentArray = Array.new(newclassSubclassArray.size,0)
newclassArray = Array.new(newclassSubclassArray.size, nil)
for i in 0...newclassSubclassArray.size do
for k in 0...classSubclassArray.size do
if newclassSubclassArray[i] == classSubclassArray[k] then
newpercentArray[i] += percentArray[k]
newclassArray[i] = classArray[k]
end
end
end
#revert array names
percentArray = newpercentArray
classArray = newclassArray
classSubclassArray = newclassSubclassArray
end

# TRY #2
drainageFactorHash = {"PerDecim"=>2, "ClimateRating"=>54, "remainingSubfactorArray"=>[], "Percent"=>20, "PrimarySubfactor"=>nil, "Class"=>3, "LandscapeRating"=>0, "SoilRating"=>0, "MostLimitingFactor"=>"Soil", "Subfactors"=>"AH"}
dominantFactorHash = {"PerDecim"=>7, "ClimateRating"=>54, "remainingSubfactorArray"=>[["H", 54.3822716736]], "Percent"=>70, "PrimarySubfactor"=>"A", "Class"=>5, "LandscapeRating"=>89.3333334, "SoilRating"=>61.7704915924883, "MostLimitingFactor"=>"Climate", "Subfactors"=>"AH"}
dissimilarFactorHash = {"PerDecim"=>1, "ClimateRating"=>54, "remainingSubfactorArray"=>[["D", 24.0485]], "Percent"=>10, "PrimarySubfactor"=>"M", "Class"=>4, "LandscapeRating"=>89.3333334, "SoilRating"=>39.2149353202108, "MostLimitingFactor"=>"Soil", "Subfactors"=>"MD"}
# create a new set of arrays for processing
my_array = [drainageFactorHash,dominantFactorHash,dissimilarFactorHash]
# get rid of zero perdecim 
my_array.delete_if{|x| x["PerDecim"]==0}
#add combined class rating to each hash
my_array.map {|x| x['Rating'] = x['Class'].to_s + x['Subfactors']}
# combine categories where class and subclass are identical
completeRatingArray = my_array.map {|x| x['Rating']}
if completeRatingArray.uniq.size < completeRatingArray.size 
uniqueRatingArray = completeRatingArray.uniq.map { |x| {:rating => x, :perdecim=> 0, :order=> 0} }
my_array.each do |rating|
uniqueRatingArray.each do |x|
if x[:rating] == rating["Rating"] then x[:perdecim] += rating["PerDecim"] end
end
end
else
uniqueRatingArray = my_array.map { |x| {:rating => x["Rating"], :perdecim=> x["PerDecim"], :order=> 0} }
end
# present the highest percent first
# if subclass the same and percent the same, present the best class first
# if class and proportion are the same, present the fewest subclasses first
# if class and proportion and number of subclasses are the same, present in alphabetical order
uniqueRatingArray.each {|e| e[:order] = (10 - e[:perdecim]).to_s + e[:rating][0,1] + e[:rating].size.to_s + e[:rating]}
uniqueRatingArray.sort {|hash_a,hash_b| hash_a[:order] <=> hash_b[:order]}


# OTHER CRAP

yy = completeRatingArray.map { |x| {:rating => x, :percent=> 0} }
 
total_invoice = bills.inject() {|result, element| result + element}
 
newclassSubclassArray = [drainageFactorHash['Class'].to_s + drainageFactorHash['Subfactors'], dominantFactorHash['Class'].to_s + dominantFactorHash['Subfactors'], dissimilarFactorHash['Class'].to_s + dissimilarFactorHash['Subfactors']].uniq

my_array = [drainageFactorHash,dominantFactorHash,dissimilarFactorHash]
my_array.sort {|hash_a,hash_b| hash_a["Percent"] <=> hash_b["Percent"]}.reverse


# FROM THE WEB
my_array = [{:hits => 90, :submit_date => 1.day.ago},{:hits => 100, :submit_date => 1.day.ago},{:hits => 80, :submit_date => Time.now}]
#Sorts the array by hits Ascending
my_array.sort {|hash_a,hash_b| hash_a[:hits] <=> hash_b[:hits]}
#Reverse the array for Descending
my_array.sort {|hash_a,hash_b| hash_a[:hits] <=> hash_b[:hits]}.reverse!
