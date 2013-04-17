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

  def check_code_lines(message = nil, &condition)
    lines = Dir.glob("#{Rails.root}/**/*.rb").inject([]) do |lines, file_path|
      lines += IO.foreach(file_path).each_with_index.map do |line, line_number|
        "#{file_path}:#{line_number + 1}" unless condition.call line
      end.compact
      lines
    end
    assert lines.empty?, "#{message + "\n" if message}check lines:\n" + lines.map { |l| '    - ' + l }.join("\n")
  end

  it 'does not have trailing whitespaces' do
    check_code_lines { |line| line.empty? || line !~ /\s+\s$/ }
  end

end
