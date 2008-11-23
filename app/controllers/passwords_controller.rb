class PasswordsController < ApplicationController
  def new
    @password = Password.new
  end

  def create
    @password = Password.new(params[:password])
    @password.user = User.find_by_email(@password.email)
    
    if @password.save
      PasswordMailer.deliver_forgot_password(@password)
      flash[:notice] = t("passwords.create.success_msg", :your_email => "#{@password.email}")
      redirect_to :action => :new
    else
      flash[:error] = t("passwords.create.failed_msg")
      redirect_to :action => :new
      # render :action => :new
    end
  end

  def reset
    begin
      @user = Password.find(:first, :conditions => ['reset_code = ? and expiration_date > ?', params[:reset_code], Time.now]).user
    rescue
      flash[:notice] = t("passwords.reset.invalid_msg")
      redirect_to new_password_path
    end    
  end

  def update_after_forgetting
    @user = Password.find_by_reset_code(params[:reset_code]).user
    
    if @user.update_attributes(params[:user])
      flash[:notice] = t("passwords.update_after_forgetting.success_msg")
      redirect_to login_path
    else
      flash[:error] = t("passwords.update_after_forgetting.failed_msg")
      redirect_to :action => :reset, :reset_code => params[:reset_code]
    end
  end
=begin
  def update
    @password = Password.find(params[:id])

    if @password.update_attributes(params[:password])
      flash[:notice] = 'Password was successfully updated.'
      redirect_to(@password)
    else
      render :action => :edit
    end
  end
=end
end
