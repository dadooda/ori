require "set"

module ORI
  # ri lookup library.
  class Library   #:nodoc:
    # Mask of ri command to fetch content. Example:
    #
    #   ri -T -f ansi %s
    attr_accessor :frontend

    # Shell escape mode. <tt>:unix</tt> or <tt>:windows</tt>.
    attr_accessor :shell_escape

    def initialize(attrs = {})
      @cache = {}
      attrs.each {|k, v| send("#{k}=", v)}
    end

    # Lookup an article.
    #
    #   lookup("Kernel#puts")     # => content or nil.
    def lookup(topic)
      if @cache.has_key? topic
        @cache[topic]
      else
        require_frontend

        etopic = case @shell_escape
        when :unix
          Tools.shell_escape(topic)
        when :windows
          Tools.win_shell_escape(topic)
        else
          topic
        end

        cmd = @frontend % etopic
        ##p "cmd", cmd
        content = `#{cmd} 2>&1`
        ##p "content", content

        # NOTES:
        # * Windows' ri always returns 0 even if article is not found. Work around it with a hack.
        # * Unix's ri sometimes returns 0 when it offers suggestions. Try `ri Object#is_ax?`.
        @cache[topic] = if $?.exitstatus != 0 or content.lines.count < 4
          nil
        else
          content
        end
      end
    end

    protected

    def require_frontend
      raise "`frontend` is not set" if not @frontend
    end
  end # Library
end # ORI
