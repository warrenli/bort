class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :login_required, :only => [ :show, :edit, :update ]
  
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    if using_open_id?
      authenticate_with_open_id(params[:openid_url], :return_to => open_id_create_url, 
        :required => [:nickname, :email]) do |result, identity_url, registration|
        if result.successful?
          create_new_user(:identity_url => identity_url, :login => registration['nickname'], :email => registration['email'])
        else
          failed_creation(result.message || "Sorry, something went wrong")
        end
      end
    else
      create_new_user(params[:user])
    end
  end
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = t("users.activate.success_msg")
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = t("users.activate.missing_code_msg")
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = t("users.activate.error_msg")
      redirect_back_or_default(root_path)
    end
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = current_user
    redirect_to edit_user_url(@user)
  end

  # GET /users/1/edit
  def edit
    @user = current_user
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_user
    attribute = params[:attribute]
    # flash[:notice] = flash[:error] =""
    case attribute
      when "basic"
        if @user.update_attributes(params[:user])
          flash.now[:notice] = t("users.edit.update_success_msg")
        else
          flash.now[:error]  = t("users.edit.update_error_msg")
        end
      when "password"
        if User.authenticate(@user.login, params[:user][:current_password])
          if @user.update_attributes(params[:user])
            flash.now[:notice] = t("users.edit.change_passwd_ok_msg")
          else
            flash.now[:error] = t("users.edit.change_passwd_error_msg")
            # @user.errors.add_to_base("New password not valid")
          end
        else
          flash.now[:error] = t("users.edit.current_passwd_error_msg")
          @user.errors.add(:current_password, t("users.edit.invalid_msg"))
        end
    end
    respond_to do |format|
        format.html { render :action => "edit" }
        # format.html { redirect_to edit_user_url(@user) }
    end

  end

  protected
  
  def create_new_user(attributes)
    @user = User.new(attributes)
    if @user && @user.valid?
      if @user.not_using_openid?
        @user.register!
      else
        @user.register_openid!
      end
    end
    
    if @user.errors.empty?
      successful_creation(@user)
    else
      failed_creation
    end
  end
  
  def successful_creation(user)
    redirect_back_or_default(root_path)
    flash[:notice] = t("users.create.success_message")
    flash[:notice] << t("users.create.success_no_openid_msg") if @user.not_using_openid?
    flash[:notice] << t("users.create.success_openid_msg") unless @user.not_using_openid?
  end
  
  def failed_creation(message = t("users.create.failed_default_message"))
    flash[:error] = message
    render :action => :new
  end
end
