# frozen_string_literal: true

module RuboCop
  module Cop
    module Katello
      # Flags variable, parameter, and method names that abbreviate
      # "content view environment" as "cve", which collides with the
      # security meaning of CVE (Common Vulnerabilities and Exposures).
      # Use "cvenv" instead.
      #
      # This only inspects identifiers (locals, ivars, method/block params,
      # method names) -- not string or symbol literals -- so it leaves
      # legitimate CVE-security code alone as long as that code lives
      # outside this cop's configured `Exclude` paths.
      #
      # @example
      #   # bad
      #   cve = content_facet.content_view_environments.first
      #   cve1, cve2 = ak.content_view_environments
      #
      #   # good
      #   cvenv = content_facet.content_view_environments.first
      #   cvenv1, cvenv2 = ak.content_view_environments
      class CveAbbreviation < Base
        MSG = '`%<name>s` abbreviates "content view environment" as "cve", which collides with the security ' \
              'meaning of CVE (Common Vulnerabilities and Exposures). Use "cvenv" instead, e.g. `%<suggestion>s`.'
        CVE_WORD = /\Acve(\d*)(s?)([?!]?)\z/i

        def on_lvasgn(node)
          check_name(node, node.children.first)
        end

        def on_ivasgn(node)
          check_name(node, node.children.first.to_s.delete('@').to_sym)
        end

        def on_def(node)
          check_name(node, node.method_name)
          check_args(node.arguments)
        end

        def on_defs(node)
          on_def(node)
        end

        def on_block(node)
          check_args(node.arguments)
        end

        def on_numblock(node)
          on_block(node)
        end

        private

        def check_args(args)
          args.each { |arg| check_name(arg, arg.children.first) }
        end

        def check_name(node, name)
          return unless name && banned?(name)

          add_offense(node, message: format(MSG, name: name, suggestion: suggest(name)))
        end

        def banned?(name)
          name.to_s.split('_').any? { |word| CVE_WORD.match?(word) }
        end

        def suggest(name)
          words = name.to_s.split('_').map { |word| rename_word(word) }
          words.join('_')
        end

        def rename_word(word)
          match = CVE_WORD.match(word)
          match ? "cvenv#{match[1]}#{match[2]}#{match[3]}" : word
        end
      end
    end
  end
end
