class Soilname

  def Soilname.attributes(cmp, snf)
    cmp.SoilName = snf.soilname
    cmp.SoilCode = snf.soil_code
    cmp.Modifier = snf.modifier
    cmp.Profile = snf.profile
    cmp.Kind = snf.kind
    cmp.WaterTable = snf.watertbl
    cmp.RootRestrictingLayer = snf.rootrestri
    cmp.RestrictionType = snf.restr_type
    cmp.Drainage = snf.drainage
    cmp.PMtex1 = snf.pmtex1
    cmp.PMtex2 = snf.pmtex2
    cmp.PMtex3 = snf.pmtex3
    cmp.PMchem1 = snf.pmchem1
    cmp.PMchem2 = snf.pmchem2
    cmp.PMchem3 = snf.pmchem3
    cmp.Mdep1 = snf.mdep1
    cmp.Mdep2 = snf.mdep2
    cmp.Mdep3 = snf.mdep3
    cmp.Order3 = snf.order3
    cmp.SubGroup3 = snf.s_group3
    cmp.GreatGroup3 = snf.g_group3
    return cmp
  end

end

