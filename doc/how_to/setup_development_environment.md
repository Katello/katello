Setting Up a Development Environment
====================================

This is a guide to help you setup some tools for developing Katello; many of
them are optional. This guide does **NOT** cover how to setup the app or a
working copy of the code.

## Operating System

We generally recommend either the latest version of RHEL6 or Fedora. Fedora
tends to have the newest tools for development while RHEL is more stable
(<strong>Hint:</strong> everyone except @mccun934 uses Fedora). 

If you don't want to install Fedora on your desktop (boo!) then you can use
your favorite VM solution to run katello. We even have some solutions to help
you out with that like [kvizer](https://github.com/pitr-ch/kvizer). 


## Generating a key

First, you should generate an ssh key. This will be used for a few different
things. To generate a key, open a termianl and run the following.

```
ssh-keygen
```

We recommend using the default location, etc. For a passphrase, it's up to you.


## Github

* First go to http://github.com and create an account if you don't have one.
* Now go to a prompt and output your new public key:

```
cat ~/.ssh/id_rsa.pub
```

* Copy the entire string including `ssh-rsa` and your `username@box`.
* Go to https://github.com/settings/ssh and create a new key called "Work" (or
  whatever you want to name it) and copy in your key.

## Creating your katello forks

In order to develop katello, you're going to need a fork. The main two
repositories you'll need are katello and katello-cli. Once you're logged into
Github, visit the following links and select "Fork". If you see multiple
options like @yourname and @Katello, select @yourname.

* https://github.com/katello/katello
* https://github.com/katello/katello-cli


## Setting up your local copy

In order to develop code for Katello, you will need a local copy of our source
code. We have a few different repos but this will cover how to setup our main
code repository, katello. You could however repeat this process for our other
repositories like katello-cli by simply substituting `katello` for
`katello-cli`.

First open up a terminal and `cd` into a folder in which you want to keep your
local fork of katello. Next run the following command to check out your fork.

```
git clone --recursive git@github.com:<your github name>/katello.git
```

Now you should have a new directory in your folder called `katello`. Go ahead
and cd into that directory (`cd katello`). Now we recommend adding the main
Katello repo to your git configuration and we recommend calling it `upstream`.

```
git remote add upstream git://github.com/Katello/katello.git
```

To confirm that everything is setup correctly, you can run `git remote -v` and
you should see something like this:

```
origin  git@github.com:<your github name>/katello.git (fetch)
origin  git@github.com:<your github name>/katello.git (push)
upstream  git://github.com/Katello/katello.git (fetch)
upstream  git://github.com/Katello/katello.git (push)
```

At this point, you can proceed to [our development setup
instructions](https://fedorahosted.org/katello/wiki/DevelopmentSetup) to get
the Katello application and its dependencies installed and running.


## rvm

Ruby version manager (or rvm) is a tool for managing ruby versions and gems.
It's not strictly essential but we find that it makes developing much easier.
To install rvm, go to https://rvm.io/ and find the install line (it should
start with `curl`) and paste it into a terminal. Here's that line although it
may not be up-to-date:

```
\curl -L https://get.rvm.io | bash -s stable --ruby=1.9.3
```

You'll notice that this also installs Ruby 1.9.3. The latest version of Ruby is
2.0.0 but currently on Katello we're using 1.9.3.


## tig

One thing that helps with working in vim is being able to visualize commits,
code changes, etc. For this, there is a great command line tool called tig. To
install it, open a terminal and type in:

```
sudo yum install tig
```

Then to run it, simply run `tig`.


## KVM

VMs are essential for developing Katello. If you are using Fedora on your
desktop, then you can use the awesome virtualization solution, KVM.

To install KVM and other virtualization packages, install the virtualization package group.

```
sudo yum install @virtualization
```

Now you can create VMs by selecting the Virtual Machine Manager program from
the main menu or you can start it from the terminal with `sudo virt-manager`.

## IDE

Everyone on Katello has their own favorite IDE (and their opinions which is
best) but some of the most popular options are below.

* [**RubyMine**](https://www.jetbrains.com/ruby/) - GUI editor based on Eclipse. Has a nice intuitive graphical interface. Very easy to learn. We have licenses which are available upon request.
* [**vim**](http://www.vim.org/) - a non-graphical text editor. Has a very tough learning curve but can be much more powerful than GUI editors once mastered. It is highly customizable and has a variety of plugins that give you all the features that all other modern text editors have. It also supports a variety of languages including Ruby, Python, etc.
* [**Emacs**](https://www.gnu.org/software/emacs/) - much like vim, Emacs is a non-graphical text editor. It is also powerful and has a tough learning curve. It also uses Elisp which is handy for people who know Lisp.  Like vim, Emacs supports a variety of languages.
* [**Sublime Text 2**](http://www.sublimetext.com/2) - a GUI editor that supports a variety of languages like Ruby, Python, etc. It's highly customizable and has a lot of plugins. It's not free but it does has a never-ending evaluation period.