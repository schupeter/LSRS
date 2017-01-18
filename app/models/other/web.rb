class Web

  def self.get_ecozone(lat,long)
		Net::HTTP.get(URI("http://map.soilinfo.ca/cgi-bin/ecozones_v1?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&BBOX=#{long-0.5},#{lat-0.5},#{long+0.5},#{lat+0.5}&SRS=EPSG:4326&LAYERS=ecozones&STYLES=&FORMAT=image/png&TRANSPARENT=true&QUERY_LAYERS=ecozones&INFO_FORMAT=text/html&WIDTH=400&HEIGHT=300&X=200&Y=150"))
  end
  
  def self.get_ecoprovince(lat,long)
		Net::HTTP.get(URI("http://map.soilinfo.ca/cgi-bin/ecoprovinces_v1?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&BBOX=#{long-0.5},#{lat-0.5},#{long+0.5},#{lat+0.5}&SRS=EPSG:4326&LAYERS=ecoprovinces&STYLES=&FORMAT=image/png&TRANSPARENT=true&QUERY_LAYERS=ecoprovinces&INFO_FORMAT=text/html&WIDTH=400&HEIGHT=300&X=200&Y=150"))
  end

end
