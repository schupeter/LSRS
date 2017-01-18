# return results 
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
xml.LSRS do
  xml.PolyId(@polyId)
  if @data == "climate" then
    xml.Climate do
      xml.PPE(@table[0].ppe)
      xml.GDD(@table[0].gdd)
      xml.EGDD(@table[0].egdd)
      xml.GSL(@table[0].gsl)
      xml.CHU(@table[0].chu)
      xml.ESM(@table[0].esm)
      xml.EFM(@table[0].efm)
      xml.EFF(@table[0].eff)
      xml.RHI(@table[0].rhi)
      xml.CANHM(@table[0].canhm)
    end #Climate
  end
  if @data == "landscape" then
    xml.Landscape do
      xml.ErosivityRegion(@table[0].ErosivityRegion)
      #xml.Pattern("0")
      #xml.FloodingFrequency("1")
      #xml.InundationPeriod("1")
    end
  end
end # 
