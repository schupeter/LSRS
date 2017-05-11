#!/usr/local/bin/ruby
# Script to dump out climate data from MySQL so it can be imported into Redis

puts "Hello"

Dir.chdir("/development/data/climate/")
#get libraries
require 'fileutils'
require "yaml"
require "/production/sites/sislsrs/app/helpers/libxml-helper"
require "/production/sites/sislsrs/app/models/ogc/wps1"
require "/production/sites/sislsrs/app/models/ogc/lsrs_gdas"
require "open-uri"
require "builder"
require 'active_record'
require 'dbf'
require "/production/sites/sislsrs/app/helpers/dbf-helper"
require "/production/sites/sislsrs/app/models/ogc/gdas2dbf"
