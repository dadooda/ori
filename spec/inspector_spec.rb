require File.join(File.dirname(__FILE__), "spec_helper")

# Rules of method inspection, formulated as spec samples.
#
# NOTES:
# * DO NOT sort arrays to compare them with each other. Instead use array arithmetic.
# * Try NOT to touch method `methods`. ORI doesn't actually use it.
# * Test concrete inspectors thoroughly: `public_methods`, `protected_methods`, etc.
# * Sort from more public to less public: public -- protected -- private.

obj_subjects = [
	nil,
	false,
	5,
	"kaka",
	Time.now,
]

class_subjects = [
  Array,
  Fixnum,
  String,
]

module_subjects = [
  Enumerable,
  Kernel,
]

cm_subjects = class_subjects + module_subjects
all_subjects = obj_subjects + cm_subjects

describe "{Class|Module}#instance_methods" do
	it "does not intersect #private_instance_methods" do
		(cm_subjects).each do |subj|
			(subj.instance_methods & subj.private_instance_methods).should == []
		end
	end

	it "is fully contained in (#public_instance_methods + #protected_instance_methods)" do
		(cm_subjects).each do |subj|
      (subj.instance_methods - (subj.public_instance_methods + subj.protected_instance_methods)).should == []
		end
	end
end

describe "anything#methods" do
	it "is fully contained in (#public_methods + #protected_methods)" do
		all_subjects.each do |subj|
      (subj.methods - (subj.public_methods + subj.protected_methods)).should == []
		end
	end
end

describe "{Class|Module}#singleton_methods" do
  it "is fully contained in (#public_methods + #protected_methods + #private_methods)" do
		cm_subjects.each do |subj|
      (subj.singleton_methods - (subj.public_methods + subj.protected_methods + subj.private_methods)).should == []
    end
  end
end

describe "Module#singleton_methods" do
  it "is fully containted in #public_methods" do
    module_subjects.each do |subj|
      (subj.singleton_methods - subj.public_methods).should == []
    end
  end

  it "does not intersect with #protected_methods or #private_methods)" do
    module_subjects.each do |subj|
      (subj.singleton_methods & (subj.protected_methods + subj.private_methods)).should == []
    end
  end
end
