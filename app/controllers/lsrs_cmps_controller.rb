class LsrsCmpsController < ApplicationController

  USER_ID, PASSWORD = "lsrs", "admin"
  before_filter :authenticate, :only => [ :new, :edit, :create, :update, :destroy ]

  # GET /LsrsCmp
  # GET /LsrsCmp.xml
  def index
    @lsrs_cmp = LsrsCmp.order('WarehouseName')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lsrs_cmp }
    end
  end

  # GET /LsrsCmp/1
  # GET /LsrsCmp/1.xml
  def show
    @lsrs_cmp = LsrsCmp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lsrs_cmp }
    end
  end

  # GET /LsrsCmp/new
  # GET /LsrsCmp/new.xml
  def new
    @lsrs_cmp = LsrsCmp.new
    @record = LsrsCmp.first
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lsrs_cmp }
    end
  end

  # GET /LsrsCmp/1/edit
  def edit
    @lsrs_cmp = LsrsCmp.find(params[:id])
    @ClimateTableArray = Array.new
    @ClimateTableArray.push nil
    LsrsClimate.order('WarehouseName').each{|dataset| @ClimateTableArray.push dataset.WarehouseName}
    @NamesTableArray = Array.new
    LsrsSoil.order('SoilNamesTable').each{|dataset| @NamesTableArray.push dataset.SoilNamesTable}
    @LayersTableArray = Array.new
    LsrsSoil.order('SoilLayersTable').each{|dataset| @LayersTableArray.push dataset.SoilLayersTable}
  end

  # POST /LsrsCmp
  # POST /LsrsCmp.xml
  def create
    @lsrs_cmp = LsrsCmp.new(params[:lsrs_cmp])

    respond_to do |format|
      if @lsrs_cmp.save
        flash[:notice] = 'Lsrs_cmp was successfully created.'
        format.html { redirect_to(@lsrs_cmp) }
        format.xml  { render :xml => @lsrs_cmp, :status => :created, :location => @lsrs_cmp }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lsrs_cmp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /LsrsCmp/1
  # PUT /LsrsCmp/1.xml
  def update
    @lsrs_cmp = LsrsCmp.find(params[:id])

    respond_to do |format|
      if @lsrs_cmp.update_attributes(params[:lsrs_cmp])
        flash[:notice] = 'LsrsCmp was successfully updated.'
        format.html { redirect_to(@lsrs_cmp) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lsrs_cmp.errors, :status => :unprocessable_entity }
      end
    end
  end
=begin
  # DELETE /LsrsCmp/1
  # DELETE /LsrsCmp/1.xml
  def destroy
    @lsrs_cmp = LsrsCmp.find(params[:id])
    @lsrs_cmp.destroy

    respond_to do |format|
      format.html { redirect_to(lsrs_cmp_url) }
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
