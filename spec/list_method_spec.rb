require File.join(File.dirname(__FILE__), "spec_helper")

describe "::ORI::ListMethod" do
  klass = ::ORI::ListMethod

  describe "#access" do
    meth = :access

    it "generally works" do
      inputs = []
      inputs << [{:obj => ::Sample::BasicInheritance::Son, :method_name => "grandpa_protected", :inspector => "protected_instance_methods"}, "#"]
      inputs << [{:obj => ::Sample::BasicInheritance::Son, :method_name => "grandpa_protected_singleton", :inspector => "protected_methods"}, "::"]
      inputs.each do |attrs, expected|
        r = klass.new(attrs)
        ##p "r", r
        r.send(meth).should == expected
      end
    end
  end

  describe "#format" do
    meth = :format

    it "generally works" do
      inputs = []
      inputs << [{:obj => 5, :method_name => "%", :inspector => "public_methods"}, [/\bFixnum#%/]]
      inputs << [{:obj => 5, :method_name => "between?", :inspector => "public_methods"}, [/\bFixnum\b/, /\bComparable\b/, /#between\?/]]
      inputs << [{:obj => 5, :method_name => "puts", :inspector => "private_methods"}, [/\bFixnum\b/, /\bKernel\b/, /private/]]
      inputs << [{:obj => nil, :method_name => "to_s", :inspector => "public_methods"}, [/\bNilClass#to_s/]]
      inputs << [{:obj => Hash, :method_name => "<", :inspector => "public_methods"}, [/\bHash\b/, /\bModule\b/, /</]]
      inputs << [{:obj => [], :method_name => "&", :inspector => "public_methods"}, [/\bArray#&/]]
      inputs << [{:obj => Kernel, :method_name => "puts", :inspector => "public_methods"}, [/\bKernel::puts/]]
      inputs << [{:obj => ::Sample::BasicExtension::OtherMo, :method_name => "public_meth", :inspector => "public_methods"}, [/\bSample::BasicExtension::OtherMo\b/, /\bSample::BasicExtension::Mo\b/, /::public_meth/]]
      inputs << [{:obj => ::Sample::BasicExtension::OtherMo, :method_name => "protected_meth", :inspector => "protected_methods"}, [/\bSample::BasicExtension::OtherMo\b/, /\bSample::BasicExtension::Mo\b/, /::protected_meth/]]
      inputs << [{:obj => ::Sample::BasicExtension::OtherMo, :method_name => "private_meth", :inspector => "private_methods"}, [/\bSample::BasicExtension::OtherMo\b/, /\bSample::BasicExtension::Mo\b/, /::private_meth/]]

      inputs.each do |attrs, checks|
        r = klass.new(attrs)
        ##p "r", r
        checks.each do |re|
          ##p "re", re
          r.send(meth, :color => false).should match re
        end
      end
    end

    it "supports colored and plain output" do
      inputs = []
      inputs << {:obj => 5, :method_name => "%", :inspector => "public_methods"}
      inputs << {:obj => 5, :method_name => "between?", :inspector => "public_methods"}
      inputs << {:obj => 5, :method_name => "puts", :inspector => "private_methods"}
      inputs << {:obj => nil, :method_name => "to_s", :inspector => "public_methods"}
      inputs << {:obj => Hash, :method_name => "<", :inspector => "public_methods"}
      inputs << {:obj => [], :method_name => "&", :inspector => "public_methods"}
      inputs << {:obj => Kernel, :method_name => "puts", :inspector => "public_methods"}

      inputs.each do |attrs|
        r = klass.new(attrs)
        ##p "r", r
        r.send(meth, :color => true).should match Regexp.new(Regexp.escape(attrs[:method_name]))
        r.send(meth, :color => true).should match Regexp.new(Regexp.escape("\e"))
        r.send(meth, :color => false).should match Regexp.new(Regexp.escape(attrs[:method_name]))
        r.send(meth, :color => false).should_not match Regexp.new(Regexp.escape("\e"))
      end
    end
  end # #format

  describe "#own?" do
    meth = :own?

    it "generally works" do
      inputs = []
      inputs << [{:obj => 5, :method_name => "%", :inspector => "public_methods"}, true]
      inputs << [{:obj => 5, :method_name => "between?", :inspector => "public_methods"}, false]
      inputs << [{:obj => Kernel, :method_name => "puts", :inspector => "public_methods"}, true]
      inputs << [{:obj => Kernel, :method_name => "dup", :inspector => "public_instance_methods"}, true]

      inputs.each do |attrs, expected|
        r = klass.new(attrs)
        ##p "r", r
        r.send(meth).should == expected
      end
    end
  end # #own?

  describe "#ri_topics" do
    meth = :ri_topics

    include HelperMethods

    it "generally works" do
      r = glm(5, "#is_a?")
      r.ri_topics.should include ["Fixnum", "#", "is_a?"]
      r.ri_topics.should include ["Object", "#", "is_a?"]

      r = glm(Hash, "#[]")
      r.ri_topics.should include ["Hash", "#", "[]"]

      r = glm(Sample::BasicInheritance::Son, "grandpa_public")
      r.ri_topics.should include ["Sample::BasicInheritance::Son", "#", "grandpa_public"]
      r.ri_topics.should include ["Sample::BasicInheritance::Grandpa", "#", "grandpa_public"]

      r = glm(Sample::BasicInheritance::Son, "grandpa_public_singleton")
      r.ri_topics.should include ["Sample::BasicInheritance::Son", "::", "grandpa_public_singleton"]
      r.ri_topics.should include ["Sample::BasicInheritance::Papa", "::", "grandpa_public_singleton"]
      r.ri_topics.should include ["Sample::BasicInheritance::Grandpa", "::", "grandpa_public_singleton"]

      r = glm(Sample::BasicExtension::Klass, "public_meth")
      r.ri_topics.should include ["Sample::BasicExtension::Klass", "::", "public_meth"]
      r.ri_topics.should include ["Sample::BasicExtension::Mo", "#", "public_meth"]
    end

    it "does not contain duplicates" do
      r = glm(Module, "#public")
      r.ri_topics.should == r.ri_topics.uniq
    end
  end # #ri_topics
end
