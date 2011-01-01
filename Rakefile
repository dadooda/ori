require "rake/rdoctask"
require "yaml"

GEM_NAME = "ori"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = GEM_NAME
    gem.summary = "Object-Oriented RI for IRB Console"
    gem.description = "Object-Oriented RI for IRB Console"
    gem.email = "alex.r@askit.org"
    gem.homepage = "http://github.com/dadooda/ori"
    gem.authors = ["Alex Fortuna"]
    gem.files = FileList[
      "[A-Z]*",
      "*.gemspec",
      "lib/**/*.rb",
      "samples/**/*",
      "spec/**/*",
    ]
  end
rescue LoadError
  STDERR.puts "This gem requires Jeweler to be built"
end

desc "Rebuild gemspec and package"
task :rebuild => [:gemspec, :build, :readme]

desc "Push (publish) gem to RubyGems.org"
task :push do
  # Yet found no way to ask Jeweler forge a complete version string for us.
  vh = YAML.load(File.read("VERSION.yml"))
  version = [vh[:major], vh[:minor], vh[:patch], (if (v = vh[:build]); v; end)].compact.join(".")
  pkgfile = File.join("pkg", [GEM_NAME, "-", version, ".gem"].join)
  Kernel.system("gem", "push", pkgfile)
end

desc "Generate README.html"
task :readme do
  require "kramdown"

  doc = Kramdown::Document.new(File.read "README.md")

  fn = "README.html"
  puts "Writing '#{fn}'..."
  File.open(fn, "w") do |f|
    f.write(File.read "dev/head.html")
    f.write(doc.to_html)
  end
  puts ": ok"
end

desc "Generate rdoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "doc"
  #rdoc.title    = "ORI"
  #rdoc.options << "--line-numbers"   # No longer supported.
  rdoc.rdoc_files.include("lib/**/*.rb")
end 
