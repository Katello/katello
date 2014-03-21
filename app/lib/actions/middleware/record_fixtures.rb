#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Middleware
    class RecordFixtures < Dynflow::Middleware
      def run(*args)
        pass(*args)
      ensure
        dump(:input)
        dump(:output)
      end

      private

      def dump(variant)
        fail unless [:input, :output].include? variant
        File.write(log_file(variant), YAML.dump(action.send(variant)))
      end

      def log_base
        File.join(Rails.root, 'log', 'dynflow')
      end

      def log_subdirs
        action.class.name.underscore
      end

      def log_file(variant)
        dir = File.join(log_base, log_subdirs)
        FileUtils.mkdir_p(dir)
        timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L")
        return File.join(dir, "#{timestamp}-#{variant}.yaml")
      end
    end
  end
end
