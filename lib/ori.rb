require "rbconfig"

# TODO: Remove `File.dirname`, use `expand_path`. 
Dir[File.join(File.dirname(__FILE__), "**/*.rb")].each do |fn|
  require File.expand_path(fn)
end

# == Object-Oriented RI for IRB Console
#
# ORI brings RI documentation right to your IRB console in a simple, consistent and truly object-oriented way.
#
# To enable ORI add to your <tt>~/.irbrc</tt>:
#
#   require "rubygems"
#   require "ori"
#
# Quick test:
#
#   $ irb
#   irb> Array.ri
#
# You should see RI page on Array.
#
# See also:
#
# * ORI::Extensions::Object#ri
# * ORI::conf
module ORI
  # Get configuration object to query or set its values.
  # Note that default values are set automatically based on your OS and environment.
  #
  #   ORI.conf.color = true
  #   ORI.conf.frontend = "ri -T -f ansi %s"
  #   ORI.conf.pager = "less -R"
  #   ORI.conf.shell_escape = :unix
  #
  # See also: ORI::Config.
  def self.conf
    @conf ||= begin
      autoconf = AutoConfig.new((k = "host_os") => RbConfig::CONFIG[k])
      Config.new({
        (k = :color) => autoconf.send(k),
        (k = :frontend) => autoconf.send(k),
        (k = :pager) => autoconf.send(k),
        (k = :shell_escape) => autoconf.send(k),
      })
    end
  end
end
