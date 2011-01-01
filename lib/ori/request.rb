module ORI
  # <tt>something.ri [something]</tt> request logic.
  #
  # NOTE: This class DOES NOT validate particular options to be passed to <tt>get_list_methods</tt>.
  class Request   #:nodoc:
    class ParseError < Exception    #:nodoc:
    end

    # Options for <tt>Internals::get_list_methods</tt>.
    attr_accessor :glm_options

    # <tt>:self</tt>, <tt>:list</tt>, <tt>:method</tt> or <tt>:error</tt>.
    attr_accessor :kind

    # Message. E.g. for <tt>:error</tt> kind this is the message for the user.
    attr_accessor :message

    def initialize(attrs = {})
      @glm_options = {}
      attrs.each {|k, v| send("#{k}=", v)}
    end

    def error?
      @kind == :error
    end

    def list?
      @kind == :list
    end

    def method?
      @kind == :method
    end

    def self?
      @kind == :self
    end

    #---------------------------------------

    # Parse arguments into a new <tt>Request</tt> object.
    #
    #   parse()
    #   parse(//)
    #   parse(//, :all)
    #   parse(//, :all => true, :access => "#")
    #   parse(:puts)
    #   parse("#puts")
    #   parse("::puts")
    def self.parse(*args)
      r = new(:glm_options => {:objs => []})

      begin
        if args.size < 1
          #   Fixnum.ri
          #   5.ri
          r.kind = :self
        else
          # At least 1 argument is present.
          arg1 = args.shift

          case arg1
          when Symbol, String
            #   ri :meth
            #   ri "#meth"
            #   ri "::meth"
            r.kind = :method
            if args.size > 0
              raise ParseError, "Unexpected arguments after #{arg1.inspect}"
            end

            # This is important -- look through all available methods.
            r.glm_options[:all] = true

            method_name = if arg1.to_s.match /\A(::|#)(.+)\z/
              r.glm_options[:access] = $1
              $2
            else
              arg1.to_s
            end

            r.glm_options[:re] = /\A#{Regexp.escape(method_name)}\z/

          when Regexp
            #   ri //
            #   ri //, :all
            #   ri /kk/, :option => value etc.
            r.kind = :list
            r.glm_options[:re] = arg1
            args.each do |arg|
              if arg.is_a? Hash
                if arg.has_key?(k = :join)
                  r.glm_options[:objs] += [arg.delete(k)].flatten(1)
                end

                r.glm_options.merge! arg
              elsif [String, Symbol].include? arg.class
                r.glm_options.merge! arg.to_sym => true
              else
                raise ParseError, "Unsupported argument #{arg.inspect}"
              end
            end

            # Don't bother making `objs` unique, we're just the request parser.

          else
            raise ParseError, "Unsupported argument #{arg1.inspect}"
          end # case arg1
        end # if args.size < 1
      rescue ParseError => e
        r.kind = :error
        r.message = e.message
      end

      r
    end
  end
end
