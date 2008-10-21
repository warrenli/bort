require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :users

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  
  it 'signs up user in pending state' do
    create_user
    assigns(:user).reload
    assigns(:user).should be_pending
  end

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end
  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  it 'activates user' do
    User.authenticate('aaron', 'monkey').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/login')
    flash[:notice].should_not be_nil
    flash[:error ].should     be_nil
    User.authenticate('aaron', 'monkey').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with bogus key' do
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
end

describe UsersController do
  describe "route generation" do
    it "should route users's 'index' action correctly" do
      route_for(:controller => 'users', :action => 'index').should == "/users"
    end
    
    it "should route users's 'new' action correctly" do
      route_for(:controller => 'users', :action => 'new').should == "/signup"
    end
    
    it "should route {:controller => 'users', :action => 'create'} correctly" do
      route_for(:controller => 'users', :action => 'create').should == "/register"
    end
    
    it "should route users's 'show' action correctly" do
      route_for(:controller => 'users', :action => 'show', :id => '1').should == "/users/1"
    end
    
    it "should route users's 'edit' action correctly" do
      route_for(:controller => 'users', :action => 'edit', :id => '1').should == "/users/1/edit"
    end
    
    it "should route users's 'update' action correctly" do
      route_for(:controller => 'users', :action => 'update', :id => '1').should == "/users/1"
    end
    
    it "should route users's 'destroy' action correctly" do
      route_for(:controller => 'users', :action => 'destroy', :id => '1').should == "/users/1"
    end

    it "should map #activate" do
      route_for(:controller => "users", :action => "activate", :activation_code => 1).should == "/activate/1"
    end
  end
  
  describe "route recognition" do
    it "should generate params for users's index action from GET /users" do
      params_from(:get, '/users').should == {:controller => 'users', :action => 'index'}
      params_from(:get, '/users.xml').should == {:controller => 'users', :action => 'index', :format => 'xml'}
      params_from(:get, '/users.json').should == {:controller => 'users', :action => 'index', :format => 'json'}
    end
    
    it "should generate params for users's new action from GET /users" do
      params_from(:get, '/users/new').should == {:controller => 'users', :action => 'new'}
      params_from(:get, '/users/new.xml').should == {:controller => 'users', :action => 'new', :format => 'xml'}
      params_from(:get, '/users/new.json').should == {:controller => 'users', :action => 'new', :format => 'json'}
    end
    
    it "should generate params for users's create action from POST /users" do
      params_from(:post, '/users').should == {:controller => 'users', :action => 'create'}
      params_from(:post, '/users.xml').should == {:controller => 'users', :action => 'create', :format => 'xml'}
      params_from(:post, '/users.json').should == {:controller => 'users', :action => 'create', :format => 'json'}
    end
    
    it "should generate params for users's show action from GET /users/1" do
      params_from(:get , '/users/1').should == {:controller => 'users', :action => 'show', :id => '1'}
      params_from(:get , '/users/1.xml').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'xml'}
      params_from(:get , '/users/1.json').should == {:controller => 'users', :action => 'show', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's edit action from GET /users/1/edit" do
      params_from(:get , '/users/1/edit').should == {:controller => 'users', :action => 'edit', :id => '1'}
    end
    
    it "should generate params {:controller => 'users', :action => update', :id => '1'} from PUT /users/1" do
      params_from(:put , '/users/1').should == {:controller => 'users', :action => 'update', :id => '1'}
      params_from(:put , '/users/1.xml').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'xml'}
      params_from(:put , '/users/1.json').should == {:controller => 'users', :action => 'update', :id => '1', :format => 'json'}
    end
    
    it "should generate params for users's destroy action from DELETE /users/1" do
      params_from(:delete, '/users/1').should == {:controller => 'users', :action => 'destroy', :id => '1'}
      params_from(:delete, '/users/1.xml').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'xml'}
      params_from(:delete, '/users/1.json').should == {:controller => 'users', :action => 'destroy', :id => '1', :format => 'json'}
    end

    it "should generate params for #activate" do
      params_from(:delete, "/activate/1").should == {:controller => "users", :action => "activate", :activation_code => "1"}
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    
    it "should route users_path() to /users" do
      users_path().should == "/users"
      formatted_users_path(:format => 'xml').should == "/users.xml"
      formatted_users_path(:format => 'json').should == "/users.json"
    end
    
    it "should route new_user_path() to /users/new" do
      new_user_path().should == "/users/new"
      formatted_new_user_path(:format => 'xml').should == "/users/new.xml"
      formatted_new_user_path(:format => 'json').should == "/users/new.json"
    end
    
    it "should route user_(:id => '1') to /users/1" do
      user_path(:id => '1').should == "/users/1"
      formatted_user_path(:id => '1', :format => 'xml').should == "/users/1.xml"
      formatted_user_path(:id => '1', :format => 'json').should == "/users/1.json"
    end
    
    it "should route edit_user_path(:id => '1') to /users/1/edit" do
      edit_user_path(:id => '1').should == "/users/1/edit"
    end
  end
  
end

describe UsersController do
  fixtures :users
  before(:each) do
    @quentin = users(:quentin)
    @basic_params = { :name => 'new name', :email => 'bort@bort.com', :identity_url => '' }
    @password_params = { :current_password => 'monkey', :password => 'password', :password_confirmation => 'password'}
  end

  describe "responding to GET show" do
    it "should be redirected if not login" do
      get :show, :id => @quentin.id
      response.should redirect_to('/session/new')
    end

    it "should be redirected if login" do
      login_as :quentin
      get :show, :id => @quentin.id
      response.should redirect_to(edit_user_url(@quentin))
    end
  end

  describe "responding to GET edit" do
    it "should be redirected if not login" do
      get :edit, :id => @quentin.id
      response.should redirect_to('/session/new')
    end

    it "should expose the requested user if login successful" do
      login_as :quentin
      get :edit, :id => @quentin.id
      assigns(:user).should == @quentin
      response.should be_success
    end
  end

  describe "responding to PUT update" do
    it "should be redirected if not login" do
      put :update, :user => @basic_params
      response.should redirect_to('/session/new')
    end

    describe "when changing basic information" do
      it "should be success for valid input" do
        login_as :quentin
        put :update, :user => @basic_params, :attribute => "basic"
        response.should be_success
        response.flash[:notice].should =~ /Basic Information was successfully updated./
      end

      it "should have an error because of missing email " do
        login_as :quentin
        put :update, :user => { :email => ''}, :attribute => "basic"
        response.should be_success
        response.flash[:error].should =~ /Please check your input./
      end
    end

    describe "when changing password" do
      it "should be success for valid password" do
        login_as :quentin
        put :update, :user => @password_params, :attribute => "password"
        response.should be_success
        response.flash[:notice].should =~ /Password was successfully updated./
      end

      it "should have an error because of not giving current password"do
        login_as :quentin
        put :update, :user => { :current_password => '' }, :attribute => "password"
        response.should be_success
        response.flash[:error].should =~ /Please enter your current password./
      end

      it "should have an error for invalid password" do
        login_as :quentin
        put :update, :user => { :current_password => 'monkey', :password => '123' }, :attribute => "password"
        response.should be_success
        response.flash[:error].should =~ /Invalid! Password not changed./
      end
    end
  end

end
