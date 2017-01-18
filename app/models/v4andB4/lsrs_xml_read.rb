class LsrsXml
  def LsrsXml.readClimate(xml)
    polygonData = Lsrs_climate_input_class.new
    polygonData.PPE = xml.search("//LSRS/Climate/PPE").first.content.to_f
    polygonData.GDD = xml.search("//LSRS/Climate/GDD").first.content.to_f
    polygonData.EGDD = xml.search("//LSRS/Climate/EGDD").first.content.to_f
    polygonData.GSL = xml.search("//LSRS/Climate/GSL").first.content.to_f
    polygonData.CHU = xml.search("//LSRS/Climate/CHU").first.content.to_f
    polygonData.ESM = xml.search("//LSRS/Climate/ESM").first.content.to_f
    polygonData.EFM = xml.search("//LSRS/Climate/EFM").first.content.to_f
    polygonData.EFF = xml.search("//LSRS/Climate/EFF").first.content.to_f
    polygonData.RHI = xml.search("//LSRS/Climate/RHI").first.content.to_f
    polygonData.CANHM = xml.search("//LSRS/Climate/CANHM").first.content.to_f
    return polygonData
  end
  
  def LsrsXml.readLandscape(xml)
    polygonData = LsrsLandscapeInputClass.new
    polygonData.ErosivityRegion = xml.search("//LSRS/Landscape/ErosivityRegion").first.content
    #polygonData.Pattern = xml.search("//LSRS/Landscape/Pattern").first.content
    #polygonData.FloodingFrequency = xml.search("//LSRS/Landscape/FloodingFrequency").first.content
    #polygonData.InundationPeriod = xml.search("//LSRS/Landscape/InundationPeriod").first.content
    return polygonData
  end

end