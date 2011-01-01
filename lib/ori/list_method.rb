module ORI
  # Our method representation suitable for listing.
  class ListMethod    #:nodoc:
    OWN_MARKER = ["~", " "]

    # Object. Can be anything, including <em>nil</em>.
    attr_reader :obj

    attr_reader :method_name
    attr_reader :inspector

    def initialize(attrs = {})
      attrs.each {|k, v| send("#{k}=", v)} 
      clear_cache
    end

    #--------------------------------------- Accessors and pseudo accessors

    # Return method access substring: "::" or "#".
    def access
      # NOTE: It is *WRONG* to rely on Ruby's `inspect` to handle things because
      #       it doesn't work for cases when singleton methods are included from modules.
      @cache[:access] ||= (module? and not inspector.match /instance/) ? "::" : "#"
    end

    def inspector=(s)
      @inspector = s.to_s
      clear_cache
    end

    def instance?
      access == "#"
    end

    def method_name=(s)
      @method_name = s.to_s
      clear_cache
    end

    # Fetch method object.
    def method_object
      require_valid

      @cache[:method_object] ||= if @inspector.match /instance/
        @obj._ori_instance_method(@method_name)
      else
        @obj._ori_method(@method_name)
      end
    end

    def module?
      @cache[:is_module] ||= begin
        require_obj
        @obj.is_a? Module
      end
    end

    def obj=(obj)
      @obj = obj
      @obj_present = true
      clear_cache
    end

    def obj_module
      @cache[:obj_module] ||= obj.is_a?(Module) ? obj : obj.class
    end

    def obj_module_name
      @cache[:obj_module_name] ||= Tools.get_module_name(obj_module)
    end

    def owner
      @cache[:owner] ||= method_object.owner
    end

    # Get, if possible, <tt>obj</tt> singleton class.
    # Some objects, e.g. <tt>Fixnum</tt> instances, don't have a singleton class.
    def obj_singleton_class
      @cache[:obj_singleton] ||= begin
        class << obj    #:nodoc:
          self
        end
      rescue
        nil
      end
    end

    # Return <tt>true</tt> if method is natively owned by <tt>obj</tt> class.
    def own?
      @cache[:is_own] ||= begin
        require_valid
        owner == obj_module || owner == obj_singleton_class
      end
    end

    def owner_name
      @cache[:owner_name] ||= Tools.get_module_name(owner)
    end

    def private?
      visibility == :private
    end

    def protected?
      visibility == :protected
    end

    def public?
      visibility == :public
    end

    def singleton?
      access == "::"
    end

    # Return visibility: <tt>:public</tt>, <tt>:protected</tt>, <tt>:private</tt>.
    def visibility
      @cache[:visibility] ||= begin
        require_valid

        if @inspector.match /private/
          :private
        elsif @inspector.match /protected/
          :protected
        else
          :public
        end
      end
    end

    #---------------------------------------

    # Format self into a string.
    # Options:
    #
    #   :color => true|false
    def format(options = {})
      options = options.dup
      o = {}
      o[k = :color] = (v = options.delete(k)).nil?? true : v
      raise ArgumentError, "Unknown option(s): #{options.inspect}" if not options.empty?

      require_valid

      Colorize.colorize *[
        (own?? [[:list_method, :own_marker], OWN_MARKER[0]] : [[:list_method, :not_own_marker], OWN_MARKER[1]]),
        [[:list_method, :obj_module_name], obj_module_name],
        ([[:list_method, :owner_name], "(#{owner_name})"] if not own?),
        [[:list_method, :access], access],
        [[:list_method, :name], method_name],
        ([[:list_method, :visibility], " [#{visibility}]"] if not public?),
        [[:reset]],
      ].compact.flatten(1).reject {|v| v.is_a? Array and not o[:color]}
    end

    # Match entire formatted record against RE.
    def fullmatch(re)
      format(:color => false).match(re)
    end

    # Match method name against RE.
    def match(re)
      @method_name.match(re)
    end

    # Quick format. No options, no hashes, no checks.
    def qformat
      #"#{owner_name}#{access}#{@method_name} [#{visibility}]"        # Before multi-obj support.
      "#{obj_module_name}#{access}#{@method_name} [#{visibility}]"
    end

    def ri_topics
      @cache[:ri_topics] ||= begin
        require_valid

        # Build "hierarchy methods". Single record is:
        #
        #   ["Kernel", "#", "dup"]
        hmethods = []

        # Always stuff self in front of the line regardless of if we have method or not.
        hmethods << [obj_module_name, access, method_name]

        ancestors = []
        ancestors += obj_module.ancestors
        ancestors += obj_singleton_class.ancestors if obj_singleton_class     # E.g. when module extends class.

        ancestors.each do |mod|
          mav = Tools.get_methods(mod, :inspector_arg => false, :to_mav => true)
          ##p "mav", mav
          found = mav.select {|method_name,| method_name == self.method_name}
          ##p "found", found
          found.each do |method_name, access|
            hmethods << [Tools.get_module_name(mod), access, method_name]
          end
        end

        # Misdoc hack -- stuff Object#meth lookup if Kernel#meth is present. For methods like Kernel#is_a?.
        if (found = hmethods.find {|mod, access| [mod, access] == ["Kernel", "#"]}) and not hmethods.find {|mod,| mod == "Object"}
          hmethods << ["Object", "#", found.last]
        end

        hmethods.uniq
      end
    end

    def valid?
      [
        @obj_present,
        @method_name,
        @inspector,
      ].all?
    end

    #---------------------------------------

    # Support <tt>Enumerable#sort</tt>.
    def <=>(other)
      [@method_name, access, obj_module_name] <=> [other.method_name, other.access, obj_module_name]
    end

    # Support <tt>Array#uniq</tt>.
    def hash
      @cache[:hash] ||= qformat.hash
    end

    # Support <tt>Array#uniq</tt>.
    def eql?(other)
      hash == other.hash
    end

    #---------------------------------------
    private

    def clear_cache
      @cache = {}
    end

    def require_obj
      raise "`obj` is not set" if not @obj_present
    end

    def require_valid
      raise "Object is not valid" if not valid?
    end
  end # ListMethod
end
