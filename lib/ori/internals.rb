module ORI
  # Tools used internally by ORI.
  module Internals    #:nodoc:
    GLM_ALL_ACCESSES = ["::", "#"]
    GLM_ALL_VISIBILITIES = [:public, :protected, :private]

    # Error message for the user. Sometimes it's CAUSED by the user, sometimes it's influenced by him.
    class UserError < Exception   #:nodoc:
    end    

    # Non-destructive break request.
    class Break < Exception   #:nodoc:
    end

    # Apply smart filters on array of <tt>ListMethod</tt>. Return filtered array.
    def self.apply_smart_filters(obj, list_methods)
      # Filters.
      #
      # * Filters return false if record is "bad". Any other return result means that record is "good".
      filters = []

      # Hide all methods starting with "_ori_".
      filters << proc do |r|
        if r.method_name.match /\A_ori_/
          false
        end
      end

      # Obj is not Kernel.
      if (obj != Kernel rescue false)
        filters << proc do |r|
          # Chop off Kernel's non-public methods.
          if r.owner == Kernel and not r.public?
            false
          end
        end
      end

      # Obj is an object.
      if not obj.is_a? Module
        filters << proc do |r|
          # Chop off non-public methods.
          if not r.public?
            false
          end
        end
      end

      # Obj is a module or a class.
      if obj.is_a? Module
        filters << proc do |r|
          # Chop off others' private instance methods.
          # NOTE: We shouldn't chop private singleton methods since they are callable from the context of our class. See Sample::BasicExtension::Klass.
          if not r.own? and r.private? and r.instance?
            false
          end
        end
      end

      # Go! If any filter rejects the record, it's rejected.
      list_methods.reject do |r|
        filters.any? {|f| f.call(r) == false}
      end
    end

    # Process interactive choice.
    # Return chosen item or <tt>nil</tt>.
    #
    #   choice [
    #     ["wan", 1.0],
    #     ["tew", 2.0],
    #     ["free", 3.0],
    #   ]
    #
    # Options:
    #
    #   :colorize_labels => T|F   # Default is true.
    #   :item_indent => "  "      # Default is "  ".
    #   :prompt => ">"            # Default is ">>".
    #   :title => "my title"      # Dialog title. Default is nil (no title).
    #
    #   :on_abort => obj          # Result to return on abort (Ctrl-C). Default is nil.
    #   :on_skip => obj           # Treat empty input as skip action. Default is nil.
    def self.choice(items, options = {})
      raise ArgumentError, "At least 1 item required" if items.size < 1

      options = options.dup
      o = {}

      o[k = :colorize_labels] = (v = options.delete(k)).nil?? true : v
      o[k = :item_indent] = (v = options.delete(k)).nil?? "  " : v
      o[k = :prompt] = (v = options.delete(k)).nil?? ">>" : v
      o[k = :title] = options.delete(k)

      o[k = :on_abort] = options.delete(k)
      o[k = :on_skip] = options.delete(k)

      raise ArgumentError, "Unknown option(s): #{options.inspect}" if not options.empty?

      # Convert `items` into an informative hash.
      hitems = []
      items.each_with_index do |item, i|
        hitems << {
          :index => (i + 1).to_s,     # Convert to string here, which eliminates the need to do String -> Integer after input.
          :label => item[0],
          :value => item[1],
        }
      end

      ### Begin dialog. ###

      if not (s = o[:title].to_s).empty?
        puts colorize([:choice, :title], s, [:reset])
        puts
      end

      # Print items.
      index_nchars = hitems.size.to_s.size
      hitems.each do |h|
        puts colorize(*[
          [
            o[:item_indent],
           [:choice, :index], "%*d" % [index_nchars, h[:index]],
           " ",
          ],
          (o[:colorize_labels] ? [[:choice, :label], h[:label]] : [h[:label]]),
          [[:reset]],
        ].flatten(1))
      end
      puts

      # Read input.

      # Catch INT for a while.
      old_sigint = trap("INT") do
        puts "\nAborted"
        return o[:on_abort]
      end

      # WARNING: Return result of `while` is return result of method.
      while true
        print colorize([:choice, :prompt], o[:prompt], " ", [:reset])

        input = gets.strip
        if input.empty?
          if o[:on_skip]
            break o[:on_skip]
          else
            next
          end
        end

        # Something has been input.
        found = hitems.find {|h| h[:index] == input}
        break found[:value] if found

        puts colorize([:message, :error], "Invalid input", [:reset])
      end # while true
    ensure
      # NOTE: `old_sigint` is literally declared above, so it always exists here no matter when we gain control.
      if not old_sigint.nil?
        trap("INT", &old_sigint)
      end
    end # choice

    # Same as <tt>ORI::Colorize.colorize</tt>, but this one produces
    # plain output if color is turned off in <tt>ORI.conf</tt>.
    def self.colorize(*args)
      Colorize.colorize *args.reject {|v| v.is_a? Array and not ::ORI.conf.color}
    end

    # Colorize a MAM (module-access-method) array.
    #
    #   colorize_mam(["Kernel", "#", "dup"])
    def self.colorize_mam(mam)
      colorize(*[
        [:mam, :module_name], mam[0],
        [:mam, :access], mam[1],
        [:mam, :method_name], mam[2],
        [:reset],
      ])
    end

    # Stuff a ready-made "<subject>.ri " command into Readline history if last request had an argument.
    def self.do_history
      # `cmd` is actually THIS command being executed.
      cmd = Readline::HISTORY.to_a.last
      if prefix = get_ri_arg_prefix(cmd)
        Readline::HISTORY.pop
        Readline::HISTORY.push "#{prefix} "
        Readline::HISTORY.push cmd
      end
    end

    # Fetch ListMethods from one or more objects (<tt>:obj => ...</tt>) and optionally filter them.
    # Options:
    #
    #   :access => "#"            # "#" or "::".
    #   :all => true|false        # Show all methods. Default is `false`.
    #   :fullre => Regexp         # Full record filter.
    #   :objs => Array            # Array of objects to fetch methods of. Must be specified.
    #   :own => true|false        # Show own methods only.
    #   :re => Regexp             # Method name filter.
    #   :visibility => :protected # Symbol or [Symbol, Symbol, ...].
    def self.get_list_methods(options = {})
      options = options.dup
      o = {}

      o[k = :access] = if v = options.delete(k); v.to_s; end
      o[k = :all] = (v = options.delete(k)).nil?? false : v
      o[k = :fullre] = options.delete(k)
      o[k = :objs] = options.delete(k)
      o[k = :own] = (v = options.delete(k)).nil?? false : v
      o[k = :re] = options.delete(k)
      o[k = :visibility] = options.delete(k)
      raise ArgumentError, "Unknown option(s): #{options.inspect}" if not options.empty?

      k = :access; raise ArgumentError, "options[#{k.inspect}] must be in #{GLM_ALL_ACCESSES.inspect}, #{o[k].inspect} given" if o[k] and not GLM_ALL_ACCESSES.include? o[k]
      k = :fullre; raise ArgumentError, "options[#{k.inspect}] must be Regexp, #{o[k].class} given" if o[k] and not o[k].is_a? Regexp

      k = :objs
      raise ArgumentError, "options[#{k.inspect}] must be set" if not o[k]
      raise ArgumentError, "options[#{k.inspect}] must be Array, #{o[k].class} given" if o[k] and not o[k].is_a? Array

      k = :re; raise ArgumentError, "options[#{k.inspect}] must be Regexp, #{o[k].class} given" if o[k] and not o[k].is_a? Regexp

      if o[k = :visibility]
        o[k] = [o[k]].flatten
        o[k].each do |v|
          raise ArgumentError, "options[#{k.inspect}] must be in #{GLM_ALL_VISIBILITIES.inspect}, #{v.inspect} given" if not GLM_ALL_VISIBILITIES.include? v
        end
      end

      # NOTE: `:all` and `:own` are NOT mutually exclusive. They are mutually confusive. :)

      # Build per-obj lists.
      per_obj = o[:objs].uniq.map do |obj|
        ar = []

        Tools.get_methods(obj).each do |inspector, methods|
          ar += methods.map {|method_name| ListMethod.new(:obj => obj, :inspector => inspector, :method_name => method_name)}
        end

        # Filter by access if requested.
        ar.reject! {|r| r.access != o[:access]} if o[:access]

        # Filter by visibility if requested.
        ar.reject! {|r| o[:visibility].none? {|vis| r.visibility == vis}} if o[:visibility]

        # Leave only own methods if requested.
        ar.reject! {|r| not r.own?} if o[:own]

        # Apply RE if requested.
        ar.reject! {|r| not r.match(o[:re])} if o[:re]

        # Apply full RE if requested
        ar.reject! {|r| not r.fullmatch(o[:fullre])} if o[:fullre]

        # Apply smart filters if requested.
        ar = apply_smart_filters(obj, ar) if not o[:all]

        # Important, return `ar` from block.
        ar
      end # o[:objs].each

      out = per_obj.flatten(1)
      ##p "out.size", out.size

      # Chop off duplicates.
      out.uniq!

      # DO NOT sort by default. If required for visual listing, that's caller's responsibility!
      #out.sort!

      out
    end

    # Used in <tt>do_history</tt>.
    # Get prefix of the last "subject.ri args" command.
    # Return everything before " args" or <tt>nil</tt> if command didn't have arguments.
    def self.get_ri_arg_prefix(cmd)
      if (mat = cmd.match /\A(\s*.+?\.ri)\s+\S/)
        mat[1]
      end
    end

    # Return local library instance.
    def self.library
      @lib ||= Library.new

      # Update sensitive attrs on every call.
      @lib.frontend = ::ORI.conf.frontend
      @lib.shell_escape = ::ORI.conf.shell_escape

      @lib
    end

    # Show content in a configured pager.
    #
    #   pager do |f|
    #     f.puts "Hello, world!"
    #   end
    def self.pager(&block)
      IO.popen(::ORI.conf.pager, "w", &block)
    end

    # Do main job.
    def self.ri(obj, *args)
      # Most of the time return nil, for list modes return number of items. Could be useful. Don't return `false` on error, that's confusing.
      out = nil

      begin
        # Build request.
        req = ::ORI::Request.parse(*args)
        raise UserError, "Bad request: #{req.message}" if req.error?
        ##IrbHacks.break req

        # List request.
        #
        #   Klass.ri //
        if req.list?
          begin
            req.glm_options[:objs].unshift(obj)
            list_methods = get_list_methods(req.glm_options).sort
          rescue ArgumentError => e
            raise UserError, "Bad request: #{e.message}"
          end
          raise UserError, "No methods found" if list_methods.size < 1

          # Display.
          pager do |f|
            f.puts list_methods.map {|r| r.format(:color => ::ORI.conf.color)}
          end

          out = list_methods.size
          raise Break
        end # if req.list?

        # Class or method request. Particular ri article should be displayed.
        #
        #   Klass.ri
        #   Klass.ri :meth
        mam_topics = if req.self?
          [[Tools.get_module_name(obj.is_a?(Module) ? obj : obj.class)]]
        elsif req.method?
          begin
            req.glm_options[:objs].unshift(obj)
            list_methods = get_list_methods(req.glm_options)
          rescue ArgumentError => e
            raise UserError, "Bad request: #{e.message}"
          end
          raise UserError, "No methods found" if list_methods.size < 1

          # Collect topics.
          # NOTE: `uniq` is important. Take `Module#public` as an example.
          list_methods.map {|r| r.ri_topics}.flatten(1).uniq
        else
          raise "Unrecognized request kind #{req.kind.inspect}, SE"
        end # mam_topics =

        # Lookup topics. Display progress -- 1 character per lookup.
        print colorize([:message, :action], "Looking up topics [", [:reset], mam_topics.map {|ar| colorize_mam(ar)}.join(", "), [:message, :action], "] ", [:reset])

        found = []
        mam_topics.each do |mam|
          topic = mam.join
          content = library.lookup(topic)
          if content
            print "o"
            found << {
              :topic => colorize_mam(mam),
              :content => content,
            }
          else
            print "."
          end
        end
        puts

        raise UserError, "No articles found" if found.size < 1

        # Decide which article to show.
        content = if found.size == 1
          found.first[:content]
        else
          items = found.map {|h| ["#{h[:topic]} (#{h[:content].size}b)", h[:content]]}
          choice(items, {
            :colorize_labels => false,
            :title => "More than 1 article found",
            :on_skip => items.first[1],
          })
        end

        # Handle abort.
        raise Break if not content

        # Display.
        pager do |f|
          f.puts content
        end
      rescue UserError => e
        puts colorize([:message, :error], e.message, [:reset])

        out = nil
      rescue Break
      end

      out
    end
  end # Internals
end # ORI
