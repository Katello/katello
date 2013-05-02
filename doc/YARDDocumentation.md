# YARD documentation

## Browsing

There are several options


-   start Katello server and click on the link in the UI footer or go directly to
    {http://path.to.katello/a_prefix/yard/docs/katello/frames}
-   run standalone server `yard server --reload` and go to {http://localhost:8808}

*Note: if any of the above fails try to run `bundle exec yard doc --no-cache` first.*

-   generate documentation statically

    -   run `yard doc` in `katello/src`
    -   `open katello/src/yardoc/index.html`
    -   `yarddoc` directory is in `.gitignore`


Enable gem `yard-activerecord` in `bundler.d/development.rb` to have attributes and associations of ActiveRecord
documented. *Note: It'll be permanently added later when gem is published and rpm packaged.*

## Basics

-   YARD is set to [Markdown syntax](http://daringfireball.net/projects/markdown/syntax#html) by default.
    Files without extension and code documentation will us it. It can be overridden by different file extension.
-   Consider reading [Getting started](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md) guide
    to get familiar with YARD features.
-   There is a [cheat-sheet](https://gist.github.com/1827484) available.
-   [Tag list](http://rubydoc.info/docs/yard/file/docs/Tags.md#List_of_Available_Tags) is also very useful

### Other tips

-   Markdown is indented by 4 spaces. 2 space indentation also works but only sometimes, it's better to use 4 to avoid
    trouble.

        -   list1

                a block of code

        -   list2
        -   list3

            -   list3.1
            -   list3.2

        -   list4

-   If there is a method which is should be private but it cannot be because its accessed by another object,
    It's useful to mark it with [@api private](http://rubydoc.info/docs/yard/file/docs/Tags.md#api)
    tag to indicate that it should not be used outside of a library where it's defined.
    Follow {Glue::Foreman::User::ClassMethods#disable_foreman_orchestration!} to see the result.
-   Tag [@option](http://rubydoc.info/docs/yard/file/docs/Tags.md#option) is very useful to document what options a
    method uses, because options are not specified
    in the method signature. Options are usually hidden somewhere in the method body.

## What to document

-   Internal APIs should be documented, like: {Notifications}, {Resources::AbstractModel}. Other parts don't need
    documentation if they are self-documenting/readable enough.
-   Create namespaces to group classes to a meaningful whole.

    -   If there is a documentation you would like to write and you do not have a place to put it, consider to create a
        namespace (module) before creating a guide in `doc` directory.

-   High level overviews belong to /doc directory. Look at
    [include:](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md#Embedding_Docstrings__include_____) directive
    to save you some typing.

# Reducing amount of needed documentation

## Small pieces and self-documentation

The smallest pieces should be self-documented. It will reduce amount of needed documentation. Also the smallest pieces
are changed often so if they are self-documenting there is no problem with outdated documentation.

### Variables

-   All variables should have proper descriptive names (long name always better than a shortcut), e.g.:

        user     # instance of User
        user_id  # an_user.id
        users    # array of Users
        user_ids # array of Integers, user ids

  `user` and `user_id` should not be mixed it often leads to wrong assumptions about variable content/type.

### Methods

-   A method should do one thing (Single responsibility principle).
-   Body should be short and readable, it should not take more than a minute or two to understand.
-   Method name describes (documents) what it does. (long name is always better than a shortcut)
-   If method has to many parameters consider using Hash options.
-   If method violates these guidelines it should be split in smaller methods, which gives the smaller chunks a name
    and description what it does.

### Code

-   use various Ruby syntax features to document what it does and to make it more readable
-   functional style is usually more readable and less error prone
-   don't forget to document *why* code does what it does. (It is not much useful when code is clear in what it does
    but a reader does not have a clue why there is that bloody `if` condition for some corner case.)

#### Some examples

-   iterations

        user_ids = []
        users.each { |u| user_ids << u.id }
        # would be better written functionally to avoid side-effects (changing content of user_ids variable)
        user_ids = users.inject([]) { |ids, user| ids.push user.id }

-   object construction

        user          = User.new
        user.name     = 'John Dow'
        user.password = 'password'
        # would be better as
        user = User.new.tap do |user|
          user.name     = 'John Dow'
          user.password = 'password'
        end
        # because it optically separates user creation from rest of the code, reader can skip this quickly
        # if he isn't interested in this part of code.

-   if and case as expression

        if params[:organization_id]
          organization_id = params[:organization_id]
        else
          case a_model
          when User
            organization_id = a_model.default_organization.id
          when Organization
            organization_id = a_model.id
          end
        end
        # could be written as
        organization_id = params[:organization_id] || case a_model
                                                      when User
                                                        a_model.default_organization.id
                                                      when Organization
                                                        a_model.id
                                                      else
                                                        raise ArgumentError
                                                      end
        # starts with `organization_id =` so reader immediately knows what the block of code is about
        # functional style
        # do not forget to raise on unexpected values
        # same style is useful for if conditions
        a_variable = if true
                       'this is true'
                     else
                       'this is false'
                     end

#### [Ruby style guide](https://github.com/styleguide/ruby) should not be forgotten

Exceptions from the guide:

-   documentation section, we do not use Tomdoc
-   `and` and `or` can be used for code flow control which is theirs true purpose, never in conditions
-   `unless` with `else` can be used where the first part is much shorter

        unless a_test
          return 'an_error_message'
        else
          # ... long
        end


## Other random thoughts

-   If a class starts to have a lot of methods its useful to create helper classes accessible via one method
    from original class, good example is {Notifications::Notifier} accessible by
    {Notifications::ControllerHelper#notify} method. Before It was implement as a helper module and
    included to controller.
-   If an API is being written it should not only be documented but also have generous amount of argument, type checks
    (raise errors) to ensure that the API is used properly by developers.
