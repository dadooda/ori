
Setting up core RI documentation for your version of Ruby
===========================================================


All versions, general procedure
-------------------------------

* Compile and install Ruby without ri/rdoc documentation.
* Install the latest `rdoc` gem before you install any other gems.
* Generate RI documentation using the latest `rdoc` gem.
* Test if RI documentation is installed correctly.


RVM
---

### 1.9.x ###

Install and select the new Ruby:

~~~
$ rvm install 1.9.3-p125
$ rvm 1.9.3-p125
~~~

Install the most recent `rdoc` gem:

~~~
$ rvm gemset use global
$ gem install rdoc
~~~

Generate RI documentation (takes a while):

~~~
$ cd ~/.rvm/src
$ rvm docs generate-ri
~~~

Test:

~~~
$ ri Array.each
~~~


### 1.8.x ###

Install and select the new Ruby:

~~~
$ rvm install 1.8.7-p358
$ rvm 1.8.7-p358
~~~

Install the most recent `rdoc` gem (for 1.8 you **must** do it):

~~~
$ rvm gemset use global
$ gem install rdoc
~~~

Generate RI documentation (takes a while):

~~~
$ cd ~/.rvm/src
$ rvm docs generate-ri
~~~

Test:

~~~
$ ri Array.each
~~~


Non-RVM, from source
--------------------

### 1.9.x ###

`rdoc` 2.5 shipped with Ruby 1.9 seems to do the job. No tweaking is required, just build and install:

~~~
$ make
$ make install
~~~

Test:

~~~
$ ri Array.each
~~~


### 1.8.x ###

If installed with `make install` by default, RI documentation will be generated in an outdated format, which is no longer supported. Please follow these steps to generate the documentation correctly.

Unpack source:

~~~
$ tar xjvf ruby-1.8.7-p352.tar.bz2
~~~

Build:

~~~
$ cd ruby-1.8.7-p352
$ ./configure
$ make
~~~

Install without doc:

~~~
$ make install-nodoc
~~~

Install the latest rdoc gem:

~~~
$ gem install rdoc
~~~

Now fix `Makefile` to use the new rdoc generator instead of the shipped one. Replace the line:

~~~
$(RUNRUBY) "$(srcdir)/bin/rdoc" --all --ri --op "$(RDOCOUT)" "$(srcdir)"
~~~

with:

~~~
rdoc --all --ri --op "$(RDOCOUT)" "$(srcdir)"
~~~

Generate and install the docs:

~~~
$ make install-doc
~~~

Test:

~~~
$ ri Array.each
~~~
