require File.join(File.dirname(__FILE__), "spec_helper")

# NOTE: When checking collection against the rule, it's wiser to use `all?`, `any?` and `none?` and ONE `should` at the end. It's about 2 times faster
#       than calling a `should` at every pass of an `each` loop.

describe "::ORI::Internals" do
  mod = ::ORI::Internals

  describe ".get_list_methods" do
    meth = :get_list_methods

    it "maintains uniqueness of output" do
      list1 = mod.send(meth, :objs => [1])
      list2 = mod.send(meth, :objs => [1, 1])
      (list2 - list1).should be_empty

      list1 = mod.send(meth, :objs => [Array])
      list2 = mod.send(meth, :objs => [Array, Array])
      (list2 - list1).should be_empty

      list1 = mod.send(meth, :objs => [1])
      list2 = mod.send(meth, :objs => [1, 2])
      (list2 - list1).should be_empty
    end

    it "requires :objs option to be an Array" do
      proc do
        mod.send(meth)
      end.should raise_error ArgumentError

      proc do
        mod.send(meth, :objs => 5)
      end.should raise_error ArgumentError
    end

    it "supports :access option" do
      proc do
        mod.send(meth, :objs => [5], :access => 1)
        mod.send(meth, :objs => [5], :access => "kk")
      end.should raise_error ArgumentError

      proc do
        mod.send(meth, :objs => [5], :access => "#")
        mod.send(meth, :objs => [5], :access => "::")
        mod.send(meth, :objs => [5], :access => :"#")
        mod.send(meth, :objs => [5], :access => :"::")
      end.should_not raise_error

      list_methods = mod.send(meth, :objs => [Time], :access => "::")
      list_methods.all? {|r| r.access == "::"}.should == true

      list_methods = mod.send(meth, :objs => [Time], :access => "#")
      list_methods.all? {|r| r.access == "#"}.should == true
    end

    it "supports `:fullre` option" do
      list_methods = mod.send(meth, :objs => [Module], :fullre => (re = /Object.*::/))
      ##re = /kk/   #DEBUG: Fail by hand.
      list_methods.all? do |r|
        ##p "r", r
        r.format(:color => false).match re
      end.should == true
    end

    it "supports `:own` option" do
      inputs = []
      inputs << 5
      inputs << []
      inputs << String
      inputs << Enumerable
      inputs << Array
      inputs << Class
      inputs << Module
      inputs << Object

      inputs.each do |obj|
        list_methods = mod.send(meth, :objs => [obj], :own => true)
        list_methods.all? do |r|
          ##p "r", r    # Uncomment if fails.
          r.own?
        end.should == true
      end

      list_methods = mod.send(meth, :objs => inputs, :own => true)
      list_methods.all? do |r|
        ##p "r", r    # Uncomment if fails.
        r.own?
      end.should == true
    end

    it "supports `:re` option" do
      list_methods = mod.send(meth, :objs => [Module], :re => (re = /pub/))
      ##re = /kk/   #DEBUG: Fail by hand.
      list_methods.all? do |r|
        ##p "r", r
        r.method_name.match re
      end.should == true
    end

    it "supports `:visibility` option" do
      list_methods = mod.send(meth, :objs => [::Sample::BasicInheritance::Son], :all => true, :visibility => :public)
      list_methods.all? do |r|
        ##p "r", r
        r.public?
      end.should == true

      list_methods = mod.send(meth, :objs => [::Sample::BasicInheritance::Son], :all => true, :visibility => :protected)
      list_methods.all? do |r|
        ##p "r", r
        r.protected?
      end.should == true

      list_methods = mod.send(meth, :objs => [::Sample::BasicInheritance::Son], :all => true, :visibility => :private)
      list_methods.all? do |r|
        ##p "r", r
        r.private?
      end.should == true
    end

    describe "filtering" do
      it "chops off all methods starting with '_ori_'" do
        inputs = [5, "", [], String, Enumerable, Array, Class, Module, Object]
        inputs.each do |obj|
          list_methods = mod.send(meth, :objs => [obj])
          list_methods.none? do |r|
            ##p "r", r    # Uncomment if fails.
            r.method_name.match /\A_ori_/
          end.should == true
        end

        list_methods = mod.send(meth, :objs => inputs)
        list_methods.none? do |r|
          ##p "r", r    # Uncomment if fails.
          r.method_name.match /\A_ori_/
        end.should == true
      end

      it "chops off non-public Kernel methods if `obj` is not Kernel" do
        inputs = [5, "", [], String, Enumerable, Array, Class, Module, Object]
        inputs.each do |obj|
          list_methods = mod.send(meth, :objs => [obj])
          list_methods.none? do |r|
            ##p "r", r    # Uncomment if fails.
            r.owner == Kernel and not r.public?
          end.should == true

          list_methods = mod.send(meth, :objs => inputs)
          list_methods.none? do |r|
            ##p "r", r    # Uncomment if fails.
            r.owner == Kernel and not r.public?
          end.should == true
        end
      end

      it "chops off non-public methods if `obj` is an object" do
        inputs = [5, "", []]
        inputs.each do |obj|
          list_methods = mod.send(meth, :objs => [obj])
          list_methods.none? do |r|
            ##p "r", r    # Uncomment if fails.
            not r.public?
          end.should == true
        end
      end

      it "chops off others' private instance methods if `obj` is a module or a class" do
        inputs = [String, Enumerable, Array, Class, Module, Object, ::Sample::BasicInheritance::Son]
        inputs.each do |obj|
          list_methods = mod.send(meth, :objs => [obj])
          list_methods.none? do |r|
            ##p "r", r    # Uncomment if fails.
            not r.own? and r.private? and r.instance?
          end.should == true
        end

        list_methods = mod.send(meth, :objs => inputs)
        list_methods.none? do |r|
          ##p "r", r    # Uncomment if fails.
          not r.own? and r.private? and r.instance?
        end.should == true
      end

      it "generally works for modules and classes" do
        list_methods = mod.send(meth, :objs => [::Sample::BasicInheritance::Son])
        list_methods.find {|r| r.method_name == "son_public"}.should_not be_nil
        list_methods.find {|r| r.method_name == "son_protected"}.should_not be_nil
        list_methods.find {|r| r.method_name == "son_private"}.should_not be_nil
        list_methods.find {|r| r.method_name == "papa_public"}.should_not be_nil
        list_methods.find {|r| r.method_name == "papa_protected"}.should_not be_nil
        list_methods.find {|r| r.method_name == "grandpa_public"}.should_not be_nil
        list_methods.find {|r| r.method_name == "grandpa_protected"}.should_not be_nil
        list_methods.find {|r| r.method_name == "papa_private"}.should be_nil
        list_methods.find {|r| r.method_name == "grandpa_private"}.should be_nil

        list_methods = mod.send(meth, :objs => [::Sample::BasicExtension::Klass])
        list_methods.find {|r| r.method_name == "public_meth"}.should_not be_nil
        list_methods.find {|r| r.method_name == "protected_meth"}.should_not be_nil
        list_methods.find {|r| r.method_name == "private_meth"}.should_not be_nil

        list_methods = mod.send(meth, :objs => [::Sample::BasicExtension::OtherMo])
        list_methods.find {|r| r.method_name == "public_meth"}.should_not be_nil
        list_methods.find {|r| r.method_name == "protected_meth"}.should_not be_nil
        list_methods.find {|r| r.method_name == "private_meth"}.should_not be_nil
      end
    end # filtering
  end # .get_list_methods

  describe ".get_ri_arg_prefix" do
    meth = :get_ri_arg_prefix

    it "generally works" do
      mod.send(meth, "kaka").should == nil
      mod.send(meth, "Object.ri").should == nil
      mod.send(meth, "  Object.ri   ").should == nil
      mod.send(meth, "Object.ri //").should == "Object.ri"
      mod.send(meth, "  Object.ri   :x").should == "  Object.ri"
    end
  end
end
