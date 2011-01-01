require File.join(File.dirname(__FILE__), "spec_helper")

describe "::ORI::Request" do
  klass = ::ORI::Request

  it "generally works" do
    # NOTE: Order is: self, method, list, error. Thinnest first, fattest last. Then errors.

    r = klass.parse()
    r.self?.should == true
    r.glm_options[:objs].should == []

    ###

    r = klass.parse(:puts)
    r.method?.should == true
    r.glm_options[:all].should == true
    "puts".should match r.glm_options[:re]
    ##p "r.glm_options", r.glm_options

    r = klass.parse("#puts")
    r.method?.should == true
    r.glm_options[:all].should == true
    "puts".should match r.glm_options[:re]
    r.glm_options[:access].should == "#"

    r = klass.parse("::puts")
    r.method?.should == true
    r.glm_options[:all].should == true
    "puts".should match r.glm_options[:re]
    r.glm_options[:access].should == "::"

    ###

    r = klass.parse(/kk/)
    r.list?.should == true
    r.glm_options[:objs].should == []
    r.glm_options[:re].should == /kk/

    r = klass.parse(/kk/, :all, :own)
    r.glm_options[:all].should == true
    r.glm_options[:own].should == true
    r.glm_options[:objs].should == []
    r.glm_options[:re].should == /kk/

    ###

    r = klass.parse(//, :join => 1)
    r.list?.should == true
    r.glm_options.should_not have_key(:join)
    r.glm_options[:objs].should == [1]
    r.glm_options[:re].should == //

    r = klass.parse(//, :join => [1])
    r.list?.should == true
    r.glm_options.should_not have_key(:join)
    r.glm_options[:objs].should == [1]
    r.glm_options[:re].should == //

    r = klass.parse(//, :join => [1, [2]])
    r.list?.should == true
    r.glm_options.should_not have_key(:join)
    r.glm_options[:objs].should == [1, [2]]
    r.glm_options[:re].should == //

    ###

    r = klass.parse(5678)
    r.error?.should == true
    r.message.should match /5678/
  end
end
