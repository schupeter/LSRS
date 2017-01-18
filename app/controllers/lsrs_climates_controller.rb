class LsrsClimatesController < ApplicationController

  USER_ID, PASSWORD = "lsrs", "admin"
  before_filter :authenticate, :only => [ :new, :edit, :create, :update, :destroy ]

  # GET /LsrsClimate
  # GET /LsrsClimate.xml
  def index
    @lsrs_climatedata = LsrsClimate.order('WarehouseName')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lsrs_climatedata }
    end
  end

  # GET /LsrsClimate/1
  # GET /LsrsClimate/1.xml
  def show
    @lsrs_climatedata = LsrsClimate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lsrs_climatedata }
    end
  end

  # GET /LsrsClimate/new
  # GET /LsrsClimate/new.xml
  def new
    @lsrs_climatedata = LsrsClimate.new
		@lsrs_climatedata.WarehouseName = "Test"
    @record = LsrsClimate.first
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lsrs_climatedata }
    end
  end

  # GET /LsrsClimate/1/edit
  def edit
    @lsrs_climatedata = LsrsClimate.find(params[:id])
  end

  # POST /LsrsClimate
  # POST /LsrsClimate.xml
  def create
    @lsrs_climatedata = LsrsClimate.new(params[:lsrs_climatedata])

    respond_to do |format|
      if @lsrs_climatedata.save
        flash[:notice] = 'Lsrs_climatedata was successfully created.'
        format.html { redirect_to(@lsrs_climatedata) }
        format.xml  { render :xml => @lsrs_climatedata, :status => :created, :location => @lsrs_climatedata }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lsrs_climatedata.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /LsrsClimate/1
  # PUT /LsrsClimate/1.xml
  def update
    @lsrs_climatedata = LsrsClimate.find(params[:id])

    respond_to do |format|
      if @lsrs_climatedata.update_attributes(params[:lsrs_climatedata])
        flash[:notice] = 'LsrsClimate was successfully updated.'
        format.html { redirect_to(@lsrs_climatedata) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lsrs_climatedata.errors, :status => :unprocessable_entity }
      end
    end
  end
=begin
  # DELETE /LsrsClimate/1
  # DELETE /LsrsClimate/1.xml
  def destroy
    @lsrs_climatedata = LsrsClimate.find(params[:id])
    @LsrsClimate.destroy

    respond_to do |format|
      format.html { redirect_to(Lsrs_climatedata_url) }
      format.xml  { head :ok }
    end
  end
=end
private
   def authenticate
      authenticate_or_request_with_http_basic do |id, password| 
          id == USER_ID && password == PASSWORD
      end
   end

end
