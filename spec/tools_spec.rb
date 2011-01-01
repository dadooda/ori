require File.join(File.dirname(__FILE__), "spec_helper")

describe "::ORI::Tools" do
  mod = ::ORI::Tools

  describe ".ansi" do
    meth = :ansi

    it "returns empty string if no attrs are given" do
      mod.send(meth).should == ""
    end

    it "refuses to take unknown attributes" do
      proc do
        mod.send(meth, :kaka)
      end.should raise_error(ArgumentError)
    end

    it "generally works" do
      mod.send(meth, :red).should == "\e[31m"
      mod.send(meth, :red, :on_green).should == "\e[31;42m"
    end
  end # .ansi

  describe ".get_methods" do
    meth = :get_methods

    it "allows to fetch own methods only" do
      ar = mod.send(meth, ::Sample::BasicInheritance::Son, :inspector_arg => false)
      ##p "ar", ar
      h = Hash[*ar.flatten(1)]
      ##p "h", h

      h["public_instance_methods"].should == ["son_public"]
      h["protected_instance_methods"].should == ["son_protected"]
      h["private_instance_methods"].should == ["son_private"]
      h["public_methods"].should include("son_public_singleton", "papa_public_singleton", "grandpa_public_singleton")
      h["protected_methods"].should include("son_protected_singleton", "papa_protected_singleton", "grandpa_protected_singleton")
      h["private_methods"].should include("son_private_singleton", "papa_private_singleton", "grandpa_private_singleton")
    end

    it "supports MAV mode" do
      ar = mod.send(meth, ::Sample::BasicInheritance::Son, :to_mav => true)
      ##p "ar", ar
      ar.should include(["son_public", "#", :public], ["son_protected", "#", :protected], ["son_private", "#", :private])
      ar.should include(["son_public_singleton", "::", :public], ["son_protected_singleton", "::", :protected], ["son_private_singleton", "::", :private])
      ar.should include(["papa_public", "#", :public], ["papa_protected", "#", :protected], ["papa_private", "#", :private])
      ar.should include(["papa_public_singleton", "::", :public], ["papa_protected_singleton", "::", :protected], ["papa_private_singleton", "::", :private])

      ar = mod.send(meth, ::Sample::BasicExtension::OtherMo, :to_mav => true)
      ar.should include(["public_meth", "::", :public], ["protected_meth", "::", :protected], ["private_meth", "::", :private])

      ar = mod.send(meth, ::Sample::BasicExtension::Klass, :to_mav => true)
      ar.should include(["public_meth", "::", :public], ["protected_meth", "::", :protected], ["private_meth", "::", :private])
    end
  end # .get_methods

  describe ".get_module_name" do
    meth = :get_module_name

    it "works for normal classes and modules" do
      mod.send(meth, Kernel).should == "Kernel"
      mod.send(meth, String).should == "String"
    end

    it "works for class singletons" do
      klass = class << String; self; end
      mod.send(meth, klass).should == "String"
    end

    it "works for module singletons" do
      klass = class << Enumerable; self; end
      mod.send(meth, klass).should == "Enumerable"
    end

    it "works for instance singletons" do
      klass = class << "kk"; self; end
      mod.send(meth, klass).should == "String"

      klass = class << []; self; end
      mod.send(meth, klass).should == "Array"

      klass = class << (class << []; self; end); self; end
      mod.send(meth, klass).should == "Class"
    end

    it "works for namespaced names" do
      klass = class << ::Sample::BasicExtension::Mo; self; end
      mod.send(meth, klass).should == "Sample::BasicExtension::Mo"

      klass = class << ::Sample::BasicExtension::Klass; self; end
      mod.send(meth, klass).should == "Sample::BasicExtension::Klass"

      klass = class << ::Sample::BasicExtension::Klass.new; self; end
      mod.send(meth, klass).should == "Sample::BasicExtension::Klass"
    end
  end # .get_module_name

  describe ".shell_escape" do
    meth = :shell_escape

    it "generally works" do
      mod.send(meth, "").should == "''"
      mod.send(meth, "one two").should == "one\\ two"
      mod.send(meth, "one\ntwo").should == "one'\n'two"
      mod.send(meth, "Kernel#`").should == "Kernel\\#\\`"
    end
  end # .shell_escape
end # ::ORI::Tools
