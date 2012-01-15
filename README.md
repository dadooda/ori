Object-oriented `ri` for IRB console
====================================


* [Introduction](#introduction)
* [Setup](#setup)
  * [Regular setup](#regular_setup)
  * [RVM setup](#rvm_setup)
  * [Rails 3.x+Bundler setup](#rails_3_bundler_setup)
* [Local project doc setup](#local_project_doc_setup)
* [Configuration](#configuration)
* [Compatibility](#compatibility)
* [Copyright](#copyright)
* [Feedback](#feedback)


<a name="introduction" /> Introduction
--------------------------------------

Finding documentation for Ruby gems and libraries is often time-consuming.
ORI addresses this issue by bringing `ri` documentation right to your IRB console in a **simple**, **consistent** and truly **object-oriented** way.

If you're too lazy to read this README, [watch this screencast](http://www.screencast-o-matic.com/watch/cXVVYuXpH) instead.


<a name="setup" /> Setup
------------------------

[Click here](#usage) to skip the boring setup part and see live examples right away.

### Pre-setup (test your environment)

1. Check your Ruby version. Should be at least **1.8.7**.

    ~~~
    $ ruby -v
    ruby 1.9.2p290 (2011-07-09 revision 32553) [i686-linux]
    ~~~

2. Check your `ri` version. Should be at least version **2.5**:

    ~~~
    $ ri --version
    ri 2.5.8
    ~~~

3. Check if core `ri` documentation is available:

    ~~~
    $ ri Array.each
    ~~~

    You should see the doc article. If you see `Nothing known about Array`, **you are missing the core `ri` documentation**. To set it up, please follow the steps from [README_RI_CORE](/dadooda/ori/blob/master/README_RI_CORE.md).


### <a name="regular_setup" /> Regular setup ###

Install the gem:

~~~
$ gem sources --add http://rubygems.org
$ gem install ori
~~~

Add to your `~/.irbrc`:

~~~
require "rubygems"
require "ori"
~~~

Test:

~~~
$ irb
irb> Array.ri //
irb> Array.ri :each
~~~


### <a name="rvm_setup" /> RVM setup ###

Under Ruby Version Manager ([RVM](http://rvm.beginrescueend.com/)), install the gem into `global` gemset of Ruby versions you're using:

~~~
$ rvm 1.9.2
$ rvm gemset use global
$ gem install ori
~~~

Add to your `~/.irbrc`:

~~~
require "rubygems"
require "ori"
~~~

Test:

~~~
$ irb
irb> Array.ri //
irb> Array.ri :each
~~~


### <a name="rails_3_bundler_setup" /> Rails 3.x+Bundler setup ###

Start by stepping into your Rails project directory:

~~~
$ cd myrailsproject
~~~

Tell Bundler to include the `rdoc` gem in `:development` environment. Add to your `Gemfile`:

~~~
group :development do
  gem "rdoc"
end
~~~

Test:

~~~
$ ri Array.each
$ bundle exec ri Array.each
~~~

You should see the doc article in **both** cases.

And finally:

~~~
$ rails console
>> Array.ri :each
~~~

#### Further important Bundler information ####

At the moment of this writing (2012-01-09) `bundle install` installs gems without `ri` documentation and it's not possible to change this behavior.

It means that you need to **manually re-install** the gems for which you need `ri` documentation. Example:

~~~
$ rails console
>> ActiveRecord::Base.ri :validate
No articles found
~~~

The above means that Rails components have been installed via `bundle install` and have no `ri` documentation. Let's fix it:

~~~
$ grep rails Gemfile
gem "rails", "3.0.7"
$ gem install rails -v 3.0.7
~~~

Rails gems are now re-installed, let's try again:

~~~
$ rails console
>> ActiveRecord::Base.ri :validate
ActiveModel::Validations::ClassMethods#validate

(from gem activemodel-3.0.7)
------------------------------------------------------------------------------
  validate(*args, &block)

------------------------------------------------------------------------------

Adds a validation method or block to the class. This is useful when overriding
the validate instance method becomes too unwieldy and you're looking
for more descriptive declaration of your validations.
...
~~~

Seems to work now.


<a name="local_project_doc_setup" /> Local project doc setup
------------------------------------------------------------

With a small hack it is possible to generate your local project's (Rails or not) `ri` documentation and make it available to ORI.

To do it, add to your `~/.irbrc`:

~~~
# Local doc hack. To generate project's doc, do a:
#
#   $ rdoc --ri -o doc/ri -O
if File.directory?(path = "doc/ri")
  ORI.conf.frontend.gsub!("%s", "-d #{path} %s")
end
~~~

Now step into your project's directory and generate the doc, like the comment says:

~~~
$ rdoc --ri -o doc/ri -O
~~~

Now fire up the console and enjoy instant documentation on your classes and methods:

~~~
$ rails console
>> MyKlass.ri
>> MyKlass.ri :some_method
~~~


<a name="usage" /> Usage
------------------------

All commands listed below are assumed to be typed in IRB. Example:

~~~
$ irb
irb> Array.ri
~~~

### Request `ri` on a class ###

It's fairly straightforward -- grab a class or class instance and call `ri` on it:

~~~
Array.ri
String.ri
[].ri
"".ri
ar = Array.new
ar.ri
~~~

### Request `ri` on a method ###

~~~
String.ri :upcase
"".ri :upcase
[].ri :each
Hash.ri :[]
Hash.ri "::[]"
Hash.ri "#[]"
~~~

### Request interactive method list ###

Interactive method list lets you explore the particular class or object by listing the methods it actually has. This powerful feature is my personal favorite. Try it once and you'll like it, too.

~~~
# Regular expression argument denotes list request.
String.ri //
"".ri //

# Show method names matching a regular expression.
"".ri /case/
"".ri /^to_/
[].ri /sort/
{}.ri /each/

# Show own methods only.
Time.ri //, :own => true
Time.ri //, :own

# Show ALL methods, including those private of Kernel.
Hash.ri //, :all => true
Hash.ri //, :all

# Show class methods or instance methods only.
Module.ri //, :access => "::"
Module.ri //, :access => "#"

# Specify visibility: public, protected or private.
Module.ri //, :visibility => :private
Module.ri //, :visibility => [:public, :protected]

# Filter fully formatted name by given regexp.
Module.ri //, :fullre => /\(Object\)::/

# Combine options.
Module.ri //, :fullre => /\(Object\)::/, :access => "::", :visibility => :private
~~~

### Request interactive method list for more than 1 object at once ###

By using the `:join` option it's possible to fetch methods for more
than 1 object at once. Value of `:join` (which can be an object or an array)
is joined with the original receiver, and then a combined set is queried.

~~~
# List all division-related methods from numeric classes.
Fixnum.ri /div/, :join => [Float, Rational]
5.ri /div/, :join => [5.0, 5.to_r]

# List all ActiveSupport extensions to numeric classes.
5.ri //, :join => [5.0, 5.to_r], :fullre => /ActiveSupport/

# Query entire Rails family for methods having the word "javascript".
rails_modules = ObjectSpace.each_object(Module).select {|mod| mod.to_s.match /Active|Action/}
"".ri /javascript/, :join => rails_modules
~~~


<a name="configuration" /> Configuration
----------------------------------------

You can configure ORI via `ORI.conf` object. By default it's autoconfigured based on your OS and environment.

    # Enable color.
    ORI.conf.color = true

    # RI frontend command to use. `%s` is replaced with sought topic.
    ORI.conf.frontend = "ri -T -f ansi %s"

    # Paging program to use.
    ORI.conf.pager = "less -R"


<a name="compatibility" /> Compatibility
----------------------------------------

Tested to run on:

* Ruby 1.9.3-p0, Linux, RVM
* Ruby 1.9.2-p290, Linux, RVM
* Ruby 1.9.2-p0, Linux, RVM
* Ruby 1.8.7-p352, Linux, RVM
* Ruby 1.8.7-p302, Linux, RVM
* Ruby 1.8.7-p72, Windows, Cygwin
* Ruby 1.8.7-p72, Windows

Compatibility issue reports will be greatly appreciated.


<a name="copyright" /> Copyright
--------------------------------

Copyright &copy; 2011-2012 Alex Fortuna.

Licensed under the MIT License.


<a name="feedback" /> Feedback
------------------------------

Send bug reports, suggestions and criticisms through [project's page on GitHub](http://github.com/dadooda/ori).
