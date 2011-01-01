module ORI
  # Propose config defaults based on OS and environment.
  class AutoConfig    #:nodoc:
    # Value of <tt>RbConfig::Config["host_os"]</tt>.
    #
    #   linux-gnu
    #   mswin32
    #   cygwin
    attr_reader :host_os

    def initialize(attrs = {})
      attrs.each {|k, v| send("#{k}=", v)}
      clear_cache
    end

    #--------------------------------------- Accessors and pseudo-accessors

    def has_less?
      @cache[:has_less] ||= begin
        require_host_os
        !!@host_os.match(/cygwin|darwin|freebsd|gnu|linux/i)
      end
    end

    def host_os=(s)
      @host_os = s
      clear_cache
    end

    def unix?
      @cache[:is_unix] ||= begin
        require_host_os
        !!@host_os.match(/cygwin|darwin|freebsd|gnu|linux|sunos|solaris/i)
      end
    end

    def windows?
      @cache[:is_windows] ||= begin
        require_host_os
        !!@host_os.match(/mswin|windows/i)
      end
    end

    #--------------------------------------- Defaults

    def color
      @cache[:color] ||= unix?? true : false
    end

    def frontend
      @cache[:frontend] ||= unix?? "ri -T -f ansi %s" : "ri -T %s"
    end

    def pager
      @cache[:pager] ||= has_less?? "less -R" : "more"
    end

    def shell_escape
      @cache[:shell_escape] ||= if unix?
        :unix
      elsif windows?
        :windows
      else
        nil
      end
    end

    private

    def clear_cache
      @cache = {}
    end

    def require_host_os
      raise "`host_os` is not set" if not @host_os
    end
  end
end
