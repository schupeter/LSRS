class LsrsSoilsController < ApplicationController

  USER_ID, PASSWORD = "lsrs", "admin"
  before_filter :authenticate, :only => [ :new, :edit, :create, :update, :destroy ]

  # GET /LsrsSoil
  # GET /LsrsSoil.xml
  def index
    @lsrs_soildata = LsrsSoil.order('SoilNamesTable')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lsrs_soildata }
    end
  end

  # GET /LsrsSoil/1
  # GET /LsrsSoil/1.xml
  def show
    @lsrs_soildata = LsrsSoil.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lsrs_soildata }
    end
  end

  # GET /LsrsSoil/new
  # GET /LsrsSoil/new.xml
  def new
    @lsrs_soildata = LsrsSoil.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lsrs_soildata }
    end
  end

  # GET /LsrsSoil/1/edit
  def edit
    @lsrs_soildata = LsrsSoil.find(params[:id])
  end

  # POST /LsrsSoil
  # POST /LsrsSoil.xml
  def create
    @lsrs_soildata = LsrsSoil.new(params[:lsrs_soildata])

    respond_to do |format|
      if @lsrs_soildata.save
        flash[:notice] = 'LsrsSoil was successfully created.'
        format.html { redirect_to(@lsrs_soildata) }
        format.xml  { render :xml => @lsrs_soildata, :status => :created, :location => @lsrs_soildata }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lsrs_soildata.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /LsrsSoil/1
  # PUT /LsrsSoil/1.xml
  def update
    @lsrs_soildata = LsrsSoil.find(params[:id])

    respond_to do |format|
      if @lsrs_soildata.update_attributes(params[:lsrs_soildata])
        flash[:notice] = 'LsrsSoil was successfully updated.'
        format.html { redirect_to(@lsrs_soildata) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lsrs_soildata.errors, :status => :unprocessable_entity }
      end
    end
  end

private
   def authenticate
      authenticate_or_request_with_http_basic do |id, password| 
          id == USER_ID && password == PASSWORD
      end
   end

end
