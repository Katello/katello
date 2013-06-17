# Gem `praise`

`pry + raise = praise`

A small gem intercepting all `#raise` calls spawning `pry` sessions for investigation. There is
a runtime-editable config file to set ignore patterns for unwanted `#raise` calls. The gem targets
investigation of re-risen and masked-by-another exceptions.

-   Documentation: <http://blog.pitr.ch/praise>
-   Source: <https://github.com/pitr-ch/praise>
-   Blog: <http://blog.pitr.ch/blog/categories/praise/>

## Installation

1.  add `gem 'praise'` to `bundle.d/local.rb`
2.  add the following to `config/initializers/_local.rb`

        dir    = File.expand_path('..', __FILE__)
        Praise = PraiseImpl.
            new "#{dir}/ignored_exceptions.yml",
                true,
                -> level, message { Logging.logger['praise'].add Logging.level_num(level), message }

See [Documentation](http://blog.pitr.ch/praise) for more information about usage.
