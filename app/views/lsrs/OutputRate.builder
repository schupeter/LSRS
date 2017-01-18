# return results 
#xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
xml.Row do
  xml.K(@polyId)
  xml.V(@lsrsRating)
end
if [1,2,3,4,5,6,7].include?(@lsrsRating[0]) then
  xml.text! "CSV:\n"
  for cmp in @lsrsArray do 
    xml.text! @polyId+","+@lsrsRating+","+cmp.cmp.to_s+","+cmp.percent.to_s+","+([@climate.Value,cmp.FinalSoilRating,cmp.LandscapeFinalRating].min.to_i.to_s)+","+([@climate.Rating,cmp.SoilClass,cmp.LandscapeClass].max.to_i.to_s)+","+@climate.Value.to_i.to_s+","+@climate.Rating.to_s+","+cmp.SoilName+","+cmp.FinalSoilRating.to_i.to_s+","+cmp.SoilClass.to_s+","+cmp.LandscapeFinalRating.to_i.to_s+","+cmp.LandscapeClass.to_s+"\n"
  end
end