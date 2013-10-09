Optional Gems
=============

Through the course of developing Katello, we've used a number of gems as
development tools that weren't absolutely necessary for developing Katello.
This document will walk you through how to use optional gems such as pry. In
this example, let's add pry-rails to our project to replace irb in `rails
console` with pry.

First, create a file in `bundler.d` called `local.rb`. In this file add the
following line:

```ruby
gem 'pry-rails'
```

Save the file, run `bundle`, and then `rails console`. Voilà! You've got pry
now in your rails console.


### List of Gems

Some optional gems we've found useful in developing Katello include:

* pry - better console than irb
* unicorn-rails - faster than thin
* hirb - outputs return values as nicely formatted tables
* awesome_print - color codes output and formats it nicely
* jist - post stuff to gist.github.com from the command line
* jazz_hands - pry and all the pry extensions (remote-pry, pry-debugger, etc)
  one could ever hope for
* guard - watch for changes to files and run different actions like tests