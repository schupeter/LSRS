class LsrsFrameworksController < ApplicationController

  USER_ID, PASSWORD = "lsrs", "admin"
  before_filter :authenticate, :only => [ :new, :edit, :create, :update, :destroy ]

  def index
    @lsrs_frameworks = LsrsFramework.order('FrameworkURI')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lsrs_frameworks }
    end
  end

  # GET /LsrsFrameworks/1
  # GET /LsrsFrameworks/1.xml
  def show
    @lsrs_framework = LsrsFramework.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lsrs_framework }
    end
  end

  # GET /LsrsFrameworks/new
  def new
    @lsrs_framework = LsrsFramework.new
  end

  # GET /LsrsFrameworks/1/edit
  def edit
    @lsrs_framework = LsrsFramework.find(params[:id])
  end

  # POST /LsrsFrameworks
  # POST /LsrsFrameworks.xml
  def create
    @lsrs_framework = LsrsFramework.new(params[:lsrs_framework])

    respond_to do |format|
      if @lsrs_framework.save
        flash[:notice] = 'LsrsFramework was successfully created.'
        format.html { redirect_to(@lsrs_framework) }
        format.xml  { render :xml => @lsrs_framework, :status => :created, :location => @lsrs_framework }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lsrs_framework.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /LsrsFrameworks/1
  # PUT /LsrsFrameworks/1.xml
  def update
    @lsrs_framework = LsrsFramework.find(params[:id])

    respond_to do |format|
      if @lsrs_framework.update_attributes(params[:lsrs_framework])
        flash[:notice] = 'LsrsFramework was successfully updated.'
        format.html { redirect_to(@lsrs_framework) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lsrs_framework.errors, :status => :unprocessable_entity }
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
