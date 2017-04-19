#!/usr/local/bin/ruby
# Script to test lsrs_cron functions

    #get libraries
    require 'fileutils'
    require "yaml"
    require "/production/sites/sislsrs/app/helpers/libxml-helper"
    require "/production/sites/sislsrs/app/models/ogc/wps1"
    require "/production/sites/sislsrs/app/models/ogc/lsrs_gdas"
    require "open-uri"
    require "builder"
    require 'active_record'

lsrsURL = "http://lsrs.soilinfo.ca/lsrs/service?FrameworkName=dss_v3_on&PolyId=OND001008442&ClimateTable=Slc_v3r0_canada_climate1961x90nlwis&CROP=alfalfa&MANAGEMENT=basic&RESPONSE=Rate"

response = open(lsrsURL).read().to_libxml_doc.root

poly_id = response.search("//Row/K").first.content

puts response