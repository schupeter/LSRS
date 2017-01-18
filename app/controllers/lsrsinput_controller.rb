class LsrsinputController < ApplicationController

  def service
    # initialize request parameters to prevent errors during subsequent testing
    @climateHash = Hash.new
#    @componentHash = Hash.new
    @soilHash = Hash.new
    @cropHash = Hash.new

    # standardize request parameters
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "POLY_ID"  
          @polyId = value
#          @climateHash.store("SL", value)
#          @componentHash.store("sl", value)
        when "DATA"
          @data = value
        when "TABLE_NAME"
          @tableName = value
      end # case
    end # params

    if !(defined? @polyId) then # request parameter missing, so return error
      @exceptionCode = "MissingParameterValue"
      @exceptionParameter = "POLY_ID"
      render :action => 'Error_response', :layout => false and return and exit 1
    end
    
    case @data 
      when "landscape" then @table = Slc_v3r0_canada_climate1961x90uvic.where(:poly_id=>@polyId)
      when "climate" then
        @tableMetadata = LsrsClimate.where(:WarehouseName=>@tableName)
        if (@tableMetadata.size == 0) then # request parameter missing, so return error
          @exceptionCode = "InvalidParameterValue"
          @exceptionParameter = "TABLE_NAME"
          @exceptionParameterValue = @tableName
          render :action => 'Error_response', :layout => false and return and exit 1
        end
        @table = eval(@tableMetadata[0].WarehouseName.capitalize).where(:poly_id=>@polyId)
      else
        @exceptionCode = "InvalidParameterValue"
        @exceptionParameter = "DATA"
        render :action => 'Error_response', :layout => false and return and exit 1
    end

    if (@table.size == 0) then # request parameter missing, so return error
      @exceptionCode = "InvalidParameterValue"
      @exceptionParameter = "POLY_ID"
      @exceptionParameterValue = @polyId
      render :action => 'Error_response', :layout => false and return and exit 1
    end

    render :action => 'List', :layout => false and return and exit 1
  end

  def Index
    render
  end
  
  def client
    @climateDatasets = LsrsClimate.all
    render
  end
end

