module ORI
  # Configuration object.
  class Config
    # Enable color. Example:
    #
    #   true
    attr_accessor :color

    # RI frontend command to use. <tt>%s</tt> is replaced with sought topic. Example:
    #
    #   ri -T -f ansi %s
    attr_accessor :frontend

    # Paging program to use. Examples:
    #
    #   less -R
    #   more
    attr_accessor :pager

    # Shell escape mode. <tt>:unix</tt> or <tt>:windows</tt>.
    attr_accessor :shell_escape

    def initialize(attrs = {})
      attrs.each {|k, v| send("#{k}=", v)}
    end
  end
end
