# encoding: UTF-8

require 'ripper'

if ENV['RAILS_ENV'] != 'build' # ok
  require_relative 'katello_test_helper'
else
  # if we are in build environment of RPM we have only the bare minimum
  warn 'loading minimal test environment'
  require 'minitest/autorun'
  require 'rails'
  require 'minitest/rails'
end

class SourceCodeTest < ActiveSupport::TestCase
  class SourceCode
    include Minitest::Assertions
    attr_reader :files
    attr_accessor :assertions

    # @param [Array<Regexp>] ignores
    def initialize(pattern, *ignores)
      @pattern = pattern || fail
      root     = File.expand_path File.join(File.dirname(__FILE__), '..')
      @files   = Dir.glob("#{root}/#{pattern}").select { |path| ignores.all? { |i| path !~ i } }
      self.assertions = 0
    end

    def each_file(&it)
      return to_enum :each_file unless it
      files.each { |file_path| it[File.read(file_path), file_path] }
    end

    def each_line(&it)
      return to_enum :each_line unless it
      each_file do |content, file_path|
        content.each_line.each_with_index { |line, line_number| it[line, line_number + 1, file_path] }
      end
    end

    def check_lines(message = nil, &condition)
      bad_lines = each_line.map do |line, line_number, file_path|
        [line, line_number, file_path] unless condition.call line
      end
      bad_lines.compact!

      assert_empty bad_lines,
             "#{message + "\n" if message}check lines:\n" + bad_lines.
                 map { |line, line_number, file_path| ' - %s:%d: %s' % [file_path, line_number, line.strip] }.
                 join("\n")
    end

    def fail_on_ruby_keyword(message = nil, &condition)
      bad_tokens = each_file.collect do |file, file_path|
        lexed_file = Ripper.lex(file)
        bad_tokens_in_file = []
        lexed_file.each_with_index do |entry, index|
          bad_tokens_in_file << [file_path, entry[0][0], entry[0][1]] if condition.call(lexed_file, index, entry)
        end
        bad_tokens_in_file.compact
      end
      bad_tokens.flatten!(1)

      bad_tokens.map! do |file_path, line_no, column_no|
        " - %s: [%d, %d]" % [file_path, line_no, column_no]
      end
      assert_empty bad_tokens, "#{message + "\n" if message}" + bad_tokens.join("\n")
    end

    def self.token_is_keyword?(str, lex, index, token)
      token[1] == :on_kw && token[2] == str && lex[index - 1][1] != :on_symbeg
    end
  end

  describe 'best practices' do
    it 'does not use ENV variables' do
      SourceCode.
          new('**/*.rb',
              %r{db/seeds\.rb},
              %r{config/(application|boot)\.rb},
              %r{engines/bastion/test/test_helper\.rb},
              %r{test/support/vcr\.rb},
              %r{app/services/katello/authentication/client_authentication\.rb},
              %r{lib/util/puppet\.rb})
    end
  end

  describe 'gettext' do
    it 'does not use interpolation or multiple anonymous placeholders' do
      doc = <<~DOC
        Interpolation example:
          _("This is a malformed string with \#{interpolated_variable} within")
          # should be _("This is a malformed string with %s within") % interpolated_variable
        Multiple anonymous placeholders:
          _("This is a malformed string with %s, and another %s") % [var1, var2]
          # should be _("This is a malformed string with %{var1}, and another %{var2}") %
          #              {:var1 => var1, :var2 => var2}
      DOC
      SourceCode.
          new('**/*.{rb}',
              %r{foreman/.*},
              %r{script/check-gettext\.rb},
              %r{engines/bastion_katello/node_modules},
              %r{node_modules/},
              %r{test/source_code_test\.rb}).
          check_lines doc do |line|
        line.scan(/_\((".*?"|'.*?')\)/).all? do |match|
          gettext_str = match.first
          gettext_str !~ /#\{.*?\}/ && gettext_str.scan(/%[a-z]/).size <= 1
        end
      end
    end
  end
end
