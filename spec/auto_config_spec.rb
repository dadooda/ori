require File.join(File.dirname(__FILE__), "spec_helper")

describe "::ORI::AutoConfig" do
  klass = ::ORI::AutoConfig

  it "requires host_os most of the time" do
    r = klass.new
    proc {r.has_less?}.should raise_error
    proc {r.unix?}.should raise_error
    proc {r.windows?}.should raise_error

    proc {r.color}.should raise_error
    proc {r.frontend}.should raise_error
    proc {r.pager}.should raise_error
    proc {r.shell_escape}.should raise_error
  end

  it "generally works" do
    r = klass.new(:host_os => "mswin32")
    r.has_less?.should == false
    r.unix?.should == false
    r.windows?.should == true

    r = klass.new(:host_os => "cygwin")
    r.has_less?.should == true
    r.color.should == true

    r = klass.new(:host_os => "linux-gnu")
    r.has_less?.should == true
    r.color.should == true
    r.frontend.should match /ansi/
  end
end
