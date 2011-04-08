require 'spec_helper'

describe ProjectsController do
  include Devise::TestHelpers
  before (:each) do
    @user = Factory.create(:user)
    sign_in @user
  end

  context 'GET on new' do
    before(:each) { get :new }
    it 'assigns a new project record' do
      assigns(:project).should be_a_new(Project)
    end
    it 'responds with success' do
      response.code.should eq('200')
    end
    it('creates a new project with default tasks') do
      assigns(:project).tasks.should_not be_empty
    end
  end
  
  context 'POST on create' do
    before(:each) do
       project_attributes = Factory.attributes_for(:project)
       project_state_attributes = Factory.attributes_for(:project_state)
       post :create, :project => project_attributes.merge(
        { :project_state_attributes => project_state_attributes })
    end
    it('responds with a redirect') { response.code.should eq('302') }
    it('creates a new project') { assigns(:project).should_not be_a_new_record }
  end

  context 'POST on create with project with associated task' do
    before(:each) do
      @project = Factory.attributes_for(:project).merge(
          { :tasks_attributes => [{:name => "First task", :inactive => false }],
            :project_state_attributes => { :name => "Test state" }})
      post :create, :project => @project
    end
    it('responds with a redirect') { response.code.should eq('302') }
    it('creates a new project') { assigns(:project).should_not be_a_new_record }
    it('creates a new project with associated task') do
      Project.find_by_shortname(@project[:shortname]).tasks.should_not be_empty
    end
  end

  context 'Find existing project' do
    before(:each) do
      @project = Factory(:project)
    end

    context 'GET on edit' do
      before(:each) { get :edit, :id => @project.id }
      it('responds with success') { response.code.should eq('200') }
    end
    context 'GET on index' do
      before(:each) { get :index }
      it('responds with success') { response.code.should eq('200') }
      it('assigns projects') { assigns(:projects).should eq([@project]) }
    end
  end

end
