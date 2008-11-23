class Admin::UsersController < ApplicationController
  before_filter :login_required
  require_role :admin
  before_filter :find_user, :only => [:show, :edit, :update, :register, :activate, :suspend, :unsuspend, :destroy, :purge]

  # GET /admin/users
  # GET /admin/users.xml
  def index
    criteria = params[:search] ||  { :conditions => { :login => "#{current_user.login}" } }
    @search = User.new_search(criteria)
    @users, @users_count = @search.all, @search.count
  end

  # GET /admin/users/1
  # GET /admin/users/1.xml
  def show
    render :action => "edit"
  end

  # GET /admin/users/new
  # GET /admin/users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /admin/users/1/edit
  def edit
    @roles = Role.find(:all, :order => :name)
  end

  # POST /admin/users
  # POST /admin/users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = t("admin.users.create.success_msg")
        format.html { redirect_to edit_admin_user_path(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.xml
  def update
    @roles = Role.find(:all, :order => :name)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.role_ids = params[:user][:role_ids]
        @user.save!

        flash[:notice] = t("admin.users.update.success_msg")
        format.html { redirect_to edit_admin_user_path(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def register
    @user.register!
    flash[:notice] = "User (#{@user.login}) was registered"
  rescue  Exception => e
    flash[:error] = e.message
  ensure
    redirect_to edit_admin_user_url(@user)
  end

  def activate
    @user.activate!
    flash[:notice] = "User (#{@user.login}) was activated"
  rescue  Exception => e
    flash[:error] = e.message
  ensure
    redirect_to edit_admin_user_url(@user)
  end

  def suspend
    @user.suspend!
    flash[:notice] = "User (#{@user.login}) was suspended"
  rescue  Exception => e
    flash[:error] = e.message
  ensure
    redirect_to edit_admin_user_url(@user)
  end

  def unsuspend
    @user.unsuspend!
    flash[:notice] = "User (#{@user.login}) was unsuspended"
  rescue  Exception => e
    flash[:error] = e.message
  ensure
    redirect_to edit_admin_user_url(@user)
  end

  def destroy
    @user.delete!
    flash[:notice] = "User (#{@user.login}) was destroyed"
  rescue  Exception => e
    flash[:error] = e.message
  ensure
    redirect_to edit_admin_user_url(@user)
  end

  def purge
    @user.destroy
    flash[:notice] = "User (#{@user.login}) was purged"
    redirect_to admin_users_url
  rescue  Exception => e
    flash[:error] = e.message
    redirect_to edit_admin_user_url(@user)
  end

  protected

  def find_user
    @user = User.find(params[:id])
  end
end
