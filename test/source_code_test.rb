#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require_relative 'minitest_helper'

class SourceCodeTest < MiniTest::Rails::ActiveSupport::TestCase

  # @param [Array<Regexp>] ignored_files
  def check_code_lines(message = nil, ignored_files = [], &condition)
    lines = Dir.glob("#{Rails.root}/**/*.rb").inject([]) do |lines, file_path|
      next lines if ignored_files.any? { |m| file_path =~ m }

      lines + IO.foreach(file_path).each_with_index.map do |line, line_number|
        "#{file_path}:#{line_number + 1}" unless condition.call line
      end.compact
    end
    assert lines.empty?, "#{message + "\n" if message}check lines:\n" + lines.map { |l| '    - ' + l }.join("\n")
  end

  it 'does not have trailing whitespaces' do
    check_code_lines { |line| line.empty? || line !~ /\s+\s$/ }
  end

  it 'does not use rescue Exception => e' do # ok
    check_code_lines(<<-DOC) { |line| (line !~ /rescue +Exception/) ? true : line =~ /#\s?ok/ }
always rescue specific exception or at least `rescue => e` which equals to `rescue StandardError => e`
see http://stackoverflow.com/questions/10048173/why-is-it-bad-style-to-rescue-exception-e-in-ruby
    DOC
  end

  it 'does not use ENV variables' do
    doc = <<-DOC
Katello.config or Katello.early_config should be always used instead of ENV variables, Katello.config is
the single entry point to configuration. ENV variables are processed there.
    DOC
    check_code_lines doc, [%r'config/(application|boot)\.rb',
                           %r'test/minitest_helper.rb', # TODO clean up minitest_helper
                           %r'lib/util/puppet\.rb'] do |line|
      (line !~ /ENV\[[^\]]+\]/) ? true : line =~ /#\s?ok/
    end
  end

  # TODO enable
  #it 'does not use general rescue => e' do
  #  check_code_lines do |line|
  #    (line !~ /rescue +Exception/) ? true : line =~ /#\s?ok/
  #  end
  #end

end
