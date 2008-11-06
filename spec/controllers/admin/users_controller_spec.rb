require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do

#  def mock_user(stubs={})
#    @mock_user ||= mock_model(User, stubs)
#  end

  fixtures :users, :roles, :roles_users

  def do_login_as_admin
    login_as :quentin
    current_user.should be_instance_of(User)
    current_user.login.should == 'quentin'
    current_user.has_role?('admin').should be_true
  end

  def create_user(options = {})
    post :create, :user => { :login=>'test', :email=>'a@test.com',:name => 'test', :password=>'password',:password_confirmation=>'password' }.merge(options)
  end


  describe "responding to GET index" do
    it "should be redirected if not login" do
      get :index
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "should render index template if login as admin" do
      do_login_as_admin
      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:users].should_not be_nil
      assigns[:users].length.should == 1
      assigns[:users][0].login.should == "quentin"
    end

    it "should expose some users when searching with criteria :login_contains => 'quentin' " do
      do_login_as_admin
      get :index, :search => { :conditions => { :login_contains => "quentin" } }

      response.should be_success
      response.should render_template('index')
      assigns[:users].should_not be_nil
      assigns[:users].should be_all { |u| u.login =~ /quentin/}
    end

    it "should expose some users when searching with criteria :name_contains => 'quentin' " do
      do_login_as_admin
      get :index, :search => { :conditions => { :name_contains => "quentin" } }

      response.should be_success
      response.should render_template('index')
      assigns[:users].should_not be_nil
      assigns[:users].should be_all { |u| u.name =~ /quentin/}
    end

    it "should expose some users when searching with criteria :email_ends_with => 'quentin' " do
      do_login_as_admin
      get :index, :search => { :conditions => { :email_ends_with => "example.com" } }

      response.should be_success
      response.should render_template('index')
      assigns[:users].should_not be_nil
      assigns[:users].should be_all { |u| u.email =~ /example.com$/}
    end

    it "should expose one user when searching with criteria being :quentin " do
      do_login_as_admin
      get :index, :search => { :conditions => { :login_contains => "quentin",
                                                :name_contains => "quentin",
                                                :email_ends_with => "quentin@example.com" } }

      response.should be_success
      response.should render_template('index')
      assigns[:users].should_not be_nil
      assigns[:users].length.should == 1
      assigns[:users].should be_all { |u| u.login =~ /quentin/}
      assigns[:users].should be_all { |u| u.name =~ /quentin/}
      assigns[:users].should be_all { |u| u.email =~ /quentin@example.com$/}
    end
    
  end


  describe "responding to GET new" do
    it "should be redirected if not login" do
      get :new
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "should expose a new user as @user" do
      do_login_as_admin
      get :new
      response.should be_success
      response.should render_template('new')
      assigns[:user].should_not be_nil
    end
  end


  describe "responding to POST create" do
    it "should be redirected if not login" do
      create_user
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "with valid_params should expose a newly created user as @user" do
      do_login_as_admin
      create_user
      assigned_user = assigns(:user)
      assigned_user.state.should == "passive"
      response.flash[:notice].should =~ /successfully created/
      response.should redirect_to(edit_admin_user_url(assigned_user))
    end

    it "with invalid params should expose a newly created but unsaved user as @user" do
      do_login_as_admin
      create_user({:email=>""})
      assigned_user = assigns(:user)
      assigned_user.email.should == ""
      response.should render_template('new')
    end
  end


  describe "responding to GET show" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      get :show, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "should expose the requested user as @user" do
      do_login_as_admin
      target_user = users(:aaron)
      get :show, :id => target_user.id
      assigned_user = assigns(:user)
      response.should be_success
      response.should render_template('edit')
      assigns[:user].should equal(assigned_user)
    end
  end


  describe "responding to GET edit" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      get :edit, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "should expose the requested user as @user" do
      do_login_as_admin
      target_user = users(:aaron)
      get :edit, :id => target_user.id
      assigned_user = assigns(:user)
      response.should be_success
      response.should render_template('edit')
      assigns[:user].should equal(assigned_user)
    end
  end


  describe "responding to PUT update" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      put :update, :id => target_user.id, 
          :user => {:name => "tester2", :login => target_user.login, :email => target_user.email, :role_ids => []}
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "with valid params should successfully update the requested user" do
      target_user = users(:aaron)
      do_login_as_admin
      put :update, :id => target_user.id, 
          :user => {:name => "tester2", :login => target_user.login, :email => target_user.email, :role_ids => []}
      assigned_user = assigns(:user)
      assigned_user.name.should == "tester2"
      response.flash[:notice].should =~ /successfully updated/
      response.should redirect_to(edit_admin_user_url(assigned_user))
      response.should_not render_template('edit')
    end

    it "with invalid params should re-render the 'edit' template" do
      target_user = users(:aaron)
      do_login_as_admin
      put :update, :id => target_user.id, 
          :user => {:name => target_user.name, :login => target_user.login, :email => "", :role_ids => []}
      assigned_user = assigns(:user)
      assigned_user.email.should == ""
      response.should render_template('edit')
    end
  end



  describe "responding to register user" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      put :register, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "should become pending for new user with state = passive" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)
      target_user.state.should == 'passive'
      target_user.activation_code.should be_nil
      put :register, :id => target_user.id
      response.flash[:notice].should =~ /registered/
      assigned_user = assigns(:user)
      assigned_user.state.should == 'pending'
      assigned_user.activation_code.should_not be_nil
    end

    it "remain unchanged for user with state in (pending, active, suspended, deleted)" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)
      %w(pending active suspended deleted).each do |from_state|
        target_user.state = from_state
        target_user.save
        target_user.state.should == from_state
        put :register, :id => target_user.id
        response.flash[:error].should =~ /Event 'register' cannot transition from/
        assigned_user = assigns(:user)
        assigned_user.state.should == from_state
      end
    end
  end


  describe "responding to activate user" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      put :activate, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "should become active for user with state = pending" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)
      target_user.register!
      target_user.state.should == "pending"
      put :activate, :id => target_user.id
      response.flash[:notice].should =~ /activated/
      assigned_user = assigns(:user)
      assigned_user.state.should == 'active'
      assigned_user.activated_at.should_not be_nil
    end

    it "remain unchanged for user with state in (passive, active, suspended, deleted)" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)

      %w(passive active suspended deleted).each do |from_state|
        target_user.state = from_state
        target_user.save
        target_user.state.should == from_state
        put :activate, :id => target_user.id
        response.flash[:error].should =~ /Event 'activate' cannot transition from/
        assigned_user = assigns(:user)
        assigned_user.state.should == from_state
      end
    end
  end


  describe "responding to suspend/unsuspend user" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      put :suspend, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')

      put :unsuspend, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "remain unchanged for user with state = deleted" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)
      target_user.state = "deleted"
      target_user.save
      put :suspend, :id => target_user.id
      response.flash[:error].should =~ /Event 'suspend' cannot transition from/
      assigned_user = assigns(:user)
      assigned_user.state.should == "deleted"

      put :unsuspend, :id => target_user.id
      response.flash[:error].should =~ /Event 'unsuspend' cannot transition from/
      assigned_user = assigns(:user)
      assigned_user.state.should == "deleted"
    end

    it "for user with state in (passive, pending, active), should be suspended and resume its state after unsuspend" do
      do_login_as_admin

      # 1 state = passive
      create_user
      target_user = assigns(:user)
      target_user.state.should == "passive"

      put :suspend, :id => target_user.id
      response.flash[:notice].should =~ /suspended/
      assigned_user = assigns(:user)
      assigned_user.state.should == "suspended"

      put :unsuspend, :id => target_user.id
      response.flash[:notice].should =~ /unsuspended/
      assigned_user = assigns(:user)
      assigned_user.state.should == "passive"

      # 2 state = passive
      target_user.register!
      target_user.state.should == "pending"
      target_user.activation_code.should_not be_nil

      put :suspend, :id => target_user.id
      response.flash[:notice].should =~ /suspended/
      assigned_user = assigns(:user)
      assigned_user.state.should == "suspended"

      put :unsuspend, :id => target_user.id
      response.flash[:notice].should =~ /unsuspended/
      assigned_user = assigns(:user)
      assigned_user.state.should == "pending"

      # 3 state = active
      target_user.activate!
      target_user.state.should == "active"
      target_user.activated_at.should_not be_nil

      put :suspend, :id => target_user.id
      response.flash[:notice].should =~ /suspended/
      assigned_user = assigns(:user)
      assigned_user.state.should == "suspended"

      put :unsuspend, :id => target_user.id
      response.flash[:notice].should =~ /unsuspended/
      assigned_user = assigns(:user)
      assigned_user.state.should == "active"
    end
  end


  describe "responding to destroy user" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      put :destroy, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "remain unchanged if user is already deleted" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)
      put :destroy, :id => target_user.id
      assigned_user = assigns(:user)
      assigned_user.state.should == "deleted"
      put :destroy, :id => assigned_user.id
      response.flash[:error].should =~ /Event 'delete' cannot transition from/
    end

    it "should become deleted for user with state in (passive, pending, active, suspended)" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)
      %w(passive pending active suspended).each do |from_state|
        target_user.state = from_state
        target_user.save
        target_user.state.should == from_state
        put :destroy, :id => target_user.id
        response.flash[:notice].should =~ /destroyed/
        assigned_user = assigns(:user)
        assigned_user.state.should == "deleted"
      end
    end
  end


  describe "responding to purge user" do
    it "should be redirected if not login" do
      target_user = users(:aaron)
      delete :purge, :id => target_user.id
      response.should be_redirect
      response.should redirect_to('/session/new')
    end

    it "should be removed permanently" do
      do_login_as_admin
      create_user
      target_user = assigns(:user)
      delete :purge, :id => target_user.id
      response.flash[:notice].should =~ /purged/
      response.should redirect_to(admin_users_url)
      User.find_by_login("test").should be_nil
    end
  end

end
