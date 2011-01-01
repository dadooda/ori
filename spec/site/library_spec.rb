require File.join(File.dirname(__FILE__), "spec_helper")

require "rbconfig"

describe "ORI::Library" do
  klass = ::ORI::Library

  # NOTES:
  # * We recreate object every time if we are not specifically testing caching.
  # * We rely upon AutoConfig to detect OS settings.

  autoconf = ::ORI::AutoConfig.new((k = "host_os") => RbConfig::CONFIG[k])
  fresh = klass.new({
    (k = :frontend) => autoconf.send(k),
    (k = :shell_escape) => autoconf.send(k),
  })
  ##p "fresh", fresh

  describe "#lookup" do
    meth = :lookup

    it "generally works" do
      r = fresh.dup
      r.lookup("Object#is_a?").should_not be_nil

      r = fresh.dup
      r.lookup("Object#is_kk?").should be_nil

      r = fresh.dup
      r.lookup("Object#kakamakaka").should be_nil
    end
  end
end
