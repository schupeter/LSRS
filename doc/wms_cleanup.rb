tmpDirName = "20100122t163103r4600"

directory = new
# MapDir and HtmDir are the same, but 
tmpMapDir = "/usr/local/httpd/lsrs/public/batch/results/" + tmpDirName
tmpHtmDir = "/usr/local/httpd/lsrs/public/batch/results/" + tmpDirName
tmpCgiDir = "/usr/local/httpd/lsrs/cgi-bin/" + tmpDirName

File.delete(tmpCgiDir + "/wms")
Dir.delete(tmpCgiDir)

File.delete(tmpMapDir + "/mapclient.html")
File.delete(tmpMapDir + "/mapfile.map")
File.delete(tmpMapDir + "/bc_okanagan_soil_v2x0.dbf")
File.delete(tmpMapDir + "/bc_okanagan_soil_v2x0.sbn")
File.delete(tmpMapDir + "/bc_okanagan_soil_v2x0.sbx")
File.delete(tmpMapDir + "/bc_okanagan_soil_v2x0.shp")
File.delete(tmpMapDir + "/bc_okanagan_soil_v2x0.shx")
File.delete(tmpMapDir + "/bc_okanagan_soil_v2x0.qix")
