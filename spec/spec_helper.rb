# Library files.
require File.join(File.dirname(__FILE__), "../lib/ori")

# Samples.
Dir[File.join(File.dirname(__FILE__), "../samples/**/*.rb")].each {|fn| require fn}

module HelperMethods
  # Quickly fetch ONE named ListMethod of <tt>obj</tt>.
  #
  #   glm(Hash, "::[]")
  #   glm(Hash, "#[]")
  def glm(obj, method_name)
    req = ::ORI::Request.parse(method_name)
    raise ArgumentError, "glm: Not a method request" if not req.method?

    req.glm_options[:objs].unshift(obj)
    ar = ::ORI::Internals.get_list_methods(req.glm_options)
    if ar.size < 1
      raise "glm: No methods found"
    elsif ar.size > 1
      raise "glm: #{ar.size} methods found, please be more specific"
    end

    ar[0]
  end
end
