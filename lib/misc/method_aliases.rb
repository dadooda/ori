# NOTE: RDoc looks ugly. Just remove it, that's internal stuff anyway.

# Retain access to <tt>instance_method</tt> by providing a prefixed alias to it.
class Module    #:nodoc:
  alias_method :_ori_instance_method, :instance_method
end

# Retain access to <tt>method</tt> by providing a prefixed alias to it.
class Object    #:nodoc:
  alias_method :_ori_method, :method
end
