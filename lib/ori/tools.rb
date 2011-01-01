module ORI
  # Generic tools.
  module Tools    #:nodoc:
    ANSI_ATTRS = {
      :reset       => 0,
      :bold        => 1,
      :underscore  => 4,
      :underline   => 4,
      :blink       => 5,
      :reverse     => 7,
      :concealed   => 8,
      :black       => 30,
      :red         => 31,
      :green       => 32,
      :yellow      => 33,
      :blue        => 34,
      :magenta     => 35,
      :cyan        => 36,
      :white       => 37,
      :on_black    => 40,
      :on_red      => 41,
      :on_green    => 42,
      :on_yellow   => 43,
      :on_blue     => 44,
      :on_magenta  => 45,
      :on_cyan     => 46,
      :on_white    => 47,
    }

    # Default inspectors for <tt>get_methods</tt>.
    GET_METHODS_INSPECTORS = [
      :private_instance_methods,
      :protected_instance_methods,
      :public_instance_methods,
      :private_methods,
      :protected_methods,
      :public_methods,
    ]

    # Build an ANSI sequence.
    #
    #   ansi()              # => ""
    #   ansi(:red)          # => "\e[31m"
    #   ansi(:red, :bold)   # => "\e[31;1m"
    #   puts "Hello, #{ansi(:bold)}user#{ansi(:reset)}"
    def self.ansi(*attrs)
      codes = attrs.map {|attr| ANSI_ATTRS[attr.to_sym] or raise ArgumentError, "Unknown attribute #{attr.inspect}"}
      codes.empty?? "" : "\e[#{codes.join(';')}m"
    end

    # Inspect an object with various inspectors.
    # Options:
    #
    #   :inspectors => []         # Array of inspectors, e.g. [:public_instance_methods].
    #   :inspector_arg => T|F     # Arg to pass to inspector. Default is <tt>true</tt>
    #   :to_mav => T|F            # Post-transform list into [method_name, access, visibility] ("MAV"). Default is <tt>false</tt>.
    #
    # Examples:
    #
    #   get_methods(obj)
    #   # => [[inspector, [methods]], [inspector, [methods]], ...]
    #   get_methods(obj, :to_mav => true)
    #   # => [[method_name, access, visibility], [method_name, access, visibility], ...]
    def self.get_methods(obj, options = {})
      options = options.dup
      o = {}
      o[k = :inspectors] = (v = options.delete(k)).nil?? GET_METHODS_INSPECTORS : v
      o[k = :inspector_arg] = (v = options.delete(k)).nil?? true : v
      o[k = :to_mav] = (v = options.delete(k)).nil?? false : v
      raise ArgumentError, "Unknown option(s): #{options.inspect}" if not options.empty?

      out = []

      o[:inspectors].each do |inspector|
        next if not obj.respond_to? inspector
        out << [inspector.to_s, obj.send(inspector, o[:inspector_arg]).sort.map(&:to_s)]
      end

      if o[:to_mav]
        mav = []

        is_module = obj.is_a? Module

        out.each do |inspector, methods|
          ##puts "-- inspector-#{inspector.inspect}"
          access = (is_module and not inspector.match /instance/) ? "::" : "#"

          visibility = if inspector.match /private/
            :private
          elsif inspector.match /protected/
            :protected
          else
            :public
          end

          methods.each do |method_name|
            mav << [method_name, access, visibility]
          end
        end

        out = mav.uniq    # NOTE: Dupes are possible, e.g. when custom inspectors are given.
      end

      out
    end

    # Return name of a module, even a "nameless" one.
    def self.get_module_name(mod)
      if mod.name.to_s.empty?
        if mat = mod.inspect.match(/#<Class:.*?\b(.+?)(?:>|:[0#])/)
          mat[1]
        end
      else
        mod.name
      end
    end

    # Escape string for use in Unix shell command.
    # Credits http://stackoverflow.com/questions/1306680/shellwords-shellescape-implementation-for-ruby-1-8.
    def self.shell_escape(s)
      # An empty argument will be skipped, so return empty quotes.
      return "''" if s.empty?

      s = s.dup

      # Process as a single byte sequence because not all shell
      # implementations are multibyte aware.
      s.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

      # A LF cannot be escaped with a backslash because a backslash + LF
      # combo is regarded as line continuation and simply ignored.
      s.gsub!(/\n/, "'\n'")

      s
    end

    # Escape string for use in Windows command. Word "shell" is used for similarity.
    def self.win_shell_escape(s)
      s
    end
  end # Tools
end # ORI
