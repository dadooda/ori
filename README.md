Object-Oriented RI for IRB Console
==================================

Introduction
------------

Finding documentation for Ruby gems and libraries is often time-consuming.
ORI addresses this issue by bringing RI documentation right to your IRB console in a **simple**, **consistent** and truly **object-oriented** way.

If you're too lazy to read this README, [watch this screencast](http://www.screencast-o-matic.com/watch/cXVVYuXpH) instead.


Setup
-----

    $ gem sources --add http://rubygems.org
    $ gem install ori

Add to your `~/.irbrc`:

    require "rubygems"
    require "ori"


Setup in RVM
------------

If you're using [RVM](http://rvm.beginrescueend.com/) (Ruby Version Manager), install the gem into `global` gemset of Rubies you're actively using:

    $ rvm 1.9.2
    $ rvm gemset use global
    $ gem install ori


Requirements
------------

It is recommended that you have Ruby >= **1.8.7** and RDoc >= **2.5.3**. Issue reports for older versions will, most probably, be ignored.


Usage
-----

All commands listed below are assumed to be typed in IRB. Example:

    $ irb
    irb> Array.ri

### Request RI on a Class ##

    Array.ri
    String.ri
    [].ri
    "".ri
    5.ri

So that's fairly straightforward -- grab a class or class instance and call <tt>ri</tt> on it:

    obj = SomeKlass.new
    obj.ri

### Request RI on a Method ###

    String.ri :upcase
    "".ri :upcase
    [].ri :sort
    Hash.ri :[]
    Hash.ri "::[]"
    Hash.ri "#[]"

### Request Interactive Method List ###

    # Regular expression argument denotes list request.
    String.ri //
    "".ri //

    # Show method names matching a regular expression.
    "".ri /case/
    "".ri /^to_/
    [].ri /sort/
    {}.ri /each/

    # Show ALL methods, including those private of Kernel.
    Hash.ri //, :all => true
    Hash.ri //, :all

    # Show class methods or instance methods only.
    Module.ri //, :access => "::"
    Module.ri //, :access => "#"

    # Show own methods only.
    Time.ri //, :own => true
    Time.ri //, :own

    # Specify visibility: public, protected or private.
    Module.ri //, :visibility => :private
    Module.ri //, :visibility => [:public, :protected]

    # Filter fully formatted name by given regexp.
    Module, //, :fullre => /\(Object\)::/

    # Combine options.
    Module.ri //, :fullre => /\(Object\)::/, :access => "::", :visibility => :private

### Request Interactive Method List for More Than 1 Object at Once ###

By using the <tt>:join</tt> option it's possible to fetch methods for more
than 1 object at once. Value of <tt>:join</tt> (which can be an object or an array)
is joined with the original receiver, and then a combined set is queried.

    # List all division-related methods from numeric classes.
    Fixnum.ri /div/, :join => [Float, Rational]
    5.ri /div/, :join => [5.0, 5.to_r]

    # List all ActiveSupport extensions to numeric classes.
    5.ri //, :join => [5.0, 5.to_r], :fullre => /ActiveSupport/

    # Query entire Rails family for methods having the word "javascript".
    rails_modules = ObjectSpace.each_object(Module).select {|mod| mod.to_s.match /Active|Action/}
    "".ri /javascript/, :join => rails_modules


Configuration
-------------

You can configure ORI via `ORI.conf` object. By default it's autoconfigured based on your OS and environment.

    # Enable color.
    ORI.conf.color = true

    # RI frontend command to use. <tt>%s</tt> is replaced with sought topic.
    ORI.conf.frontend = "ri -T -f ansi %s"

    # Paging program to use.
    ORI.conf.pager = "less -R"


Compatibility
-------------

Prior to publication, ORI gem has been thoroughly tested on:

* Ruby 1.9.2-p0 under Linux with RVM
* Ruby 1.8.7-p302 under Linux with RVM
* Ruby 1.8.7-p72 under Cygwin
* Ruby 1.8.7-p72 under 32-bit Windows Vista


Copyright
---------

Copyright &copy; 2011 Alex Fortuna.

Licensed under the MIT License.


Feedback
--------

Send bug reports, suggestions and criticisms through [project's page on GitHub](http://github.com/dadooda/ori).
