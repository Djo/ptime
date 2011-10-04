require 'spec_helper'

describe "FactoryGirl" do

  it "has a valid user factory" do
    user=Factory.build(:user)
    user.should be_valid
  end

  it 'has a valid accounting factory' do
    accounting = Factory.build(:accounting)
    accounting.should be_valid
  end

  it "should not influence other project tests #1" do
    Factory(:project)
    assert_equal 1, Project.count
  end

  it "should not influence other project tests #2" do
    Factory(:project)
    assert_equal 1, Project.count
  end

  it "should not influence other entry tests #1" do
    Factory(:entry)
    assert_equal 1, Entry.count
  end

  it "should not influence other entry tests #2" do
    Factory(:entry)
    assert_equal 1, Entry.count
  end
end
