module ORI
  module Extensions
    module Object
      # View RI pages on module, class, method. Interactively list receiver's methods.
      #
      # == Request RI on a Class
      #
      #   Array.ri
      #   String.ri
      #   [].ri
      #   "".ri
      #   5.ri
      #
      # So that's fairly straightforward -- grab a class or class instance and call <tt>ri</tt> on it:
      #
      #   obj = SomeKlass.new
      #   obj.ri
      #
      # == Request RI on a Method
      #
      #   String.ri :upcase
      #   "".ri :upcase
      #   [].ri :sort
      #   Hash.ri :[]
      #   Hash.ri "::[]"
      #   Hash.ri "#[]"
      #
      # == Request Interactive Method List
      #
      #   # Regular expression argument denotes list request.
      #   String.ri //
      #   "".ri //
      #
      #   # Show method names matching a regular expression.
      #   "".ri /case/
      #   "".ri /^to_/
      #   [].ri /sort/
      #   {}.ri /each/
      #
      #   # Show ALL methods, including those private of Kernel.
      #   Hash.ri //, :all => true
      #   Hash.ri //, :all
      #
      #   # Show class methods or instance methods only.
      #   Module.ri //, :access => "::"
      #   Module.ri //, :access => "#"
      #
      #   # Show own methods only.
      #   Time.ri //, :own => true
      #   Time.ri //, :own
      #
      #   # Specify visibility: public, protected or private.
      #   Module.ri //, :visibility => :private
      #   Module.ri //, :visibility => [:public, :protected]
      #
      #   # Filter fully formatted name by given regexp.
      #   Module.ri //, :fullre => /\(Object\)::/
      #
      #   # Combine options.
      #   Module.ri //, :fullre => /\(Object\)::/, :access => "::", :visibility => :private
      #
      # == Request Interactive Method List for More Than 1 Object at Once
      #
      # By using the <tt>:join</tt> option it's possible to fetch methods for more
      # than 1 object at once. Value of <tt>:join</tt> (which can be an object or an array)
      # is joined with the original receiver, and then a combined set is queried.
      #
      #   # List all division-related methods from numeric classes.
      #   Fixnum.ri /div/, :join => [Float, Rational]
      #   5.ri /div/, :join => [5.0, 5.to_r]
      #
      #   # List all ActiveSupport extensions to numeric classes.
      #   5.ri //, :join => [5.0, 5.to_r], :fullre => /ActiveSupport/
      #
      #   # Query entire Rails family for methods having the word "javascript".
      #   rails_modules = ObjectSpace.each_object(Module).select {|mod| mod.to_s.match /Active|Action/}
      #   "".ri /javascript/, :join => rails_modules
      def ri(*args)
        ::ORI::Internals.do_history
        ::ORI::Internals.ri(self, *args)
      end
    end
  end
end

class Object    #:nodoc:
  include ::ORI::Extensions::Object
end
