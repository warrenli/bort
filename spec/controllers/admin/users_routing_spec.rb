require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/users", :action => "index").should == "/admin/users"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/users", :action => "new").should == "/admin/users/new"
    end
  
    it "should map #create" do
      route_for(:controller => "admin/users", :action => "create").should == "/admin/users"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/users", :action => "show", :id => 1).should == "/admin/users/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/users", :action => "edit", :id => 1).should == "/admin/users/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/users", :action => "update", :id => 1).should == "/admin/users/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/users", :action => "destroy", :id => 1).should == "/admin/users/1"
    end

    it "should map #register" do
      route_for(:controller => "admin/users", :action => "register", :id => 1).should == "/admin/users/1/register"
    end

    it "should map #activate" do
      route_for(:controller => "admin/users", :action => "activate", :id => 1).should == "/admin/users/1/activate"
    end

    it "should map #suspend" do
      route_for(:controller => "admin/users", :action => "suspend", :id => 1).should == "/admin/users/1/suspend"
    end

    it "should map #unsuspend" do
      route_for(:controller => "admin/users", :action => "unsuspend", :id => 1).should == "/admin/users/1/unsuspend"
    end

    it "should map #purge" do
      route_for(:controller => "admin/users", :action => "purge", :id => 1).should == "/admin/users/1/purge"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/users").should == {:controller => "admin/users", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/users/new").should == {:controller => "admin/users", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/users").should == {:controller => "admin/users", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/users/1").should == {:controller => "admin/users", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/users/1/edit").should == {:controller => "admin/users", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/users/1").should == {:controller => "admin/users", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/users/1").should == {:controller => "admin/users", :action => "destroy", :id => "1"}
    end

    it "should generate params for #register" do
      params_from(:put, "/admin/users/1/register").should == {:controller => "admin/users", :action => "register", :id => "1"}
    end

    it "should generate params for #activate" do
      params_from(:put, "/admin/users/1/activate").should == {:controller => "admin/users", :action => "activate", :id => "1"}
    end

    it "should generate params for #suspend" do
      params_from(:put, "/admin/users/1/suspend").should == {:controller => "admin/users", :action => "suspend", :id => "1"}
    end

    it "should generate params for #unsuspend" do
      params_from(:put, "/admin/users/1/unsuspend").should == {:controller => "admin/users", :action => "unsuspend", :id => "1"}
    end

    it "should generate params for #purge" do
      params_from(:delete, "/admin/users/1/purge").should == {:controller => "admin/users", :action => "purge", :id => "1"}
    end
  end
end
