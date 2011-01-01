require File.join(File.dirname(__FILE__), "spec_helper")

describe "::ORI::Tools" do
  mod = ::ORI::Colorize

  describe ".colorize" do
    meth = :colorize

    it "generally works" do
      mod.send(meth, "the quick ", "brown fox").should == "the quick brown fox"
      mod.send(meth, [:message, :error], "the message", [:reset]).should(match(/the message/) && match(/\e\[0m/))     # NOTE: () and && are to satisfy Ruby 1.8.
    end
  end

  describe ".seq" do
    meth = :seq

    it "generally works" do
      mod.send(meth, :reset).should == "\e[0m"

      proc do
        mod.send(meth, :kaka)
      end.should raise_error ArgumentError
    end
  end # .seq
end
