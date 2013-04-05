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

if defined? String::INTERPOLATION_PATTERN and defined? String::INTERPOLATION_PATTERN_WITH_ESCAPE
  class String

    # see https://bugzilla.redhat.com/show_bug.cgi?id=830713
    #
    # related files:
    #   i18n-0.5.0/lib/i18n/core_ext/string/interpolate.rb:86
    #   fast_gettext-0.6.4/lib/fast_gettext/vendor/string.rb:18

    def _fast_gettext_old_format_m(args)
      if args.kind_of?(Hash)
        dup.gsub(INTERPOLATION_PATTERN_WITH_ESCAPE) do |match|
          if match == '%%'
            '%'
          else
            match =~ INTERPOLATION_PATTERN # this line is added to fill $1 and $2
            key = ($1 || $2).to_sym
            raise KeyError unless args.has_key?(key)
            $3 ? sprintf("%#{$3}", args[key]) : args[key]
          end
        end
      elsif self =~ INTERPOLATION_PATTERN
        raise ArgumentError.new('one hash required')
      else
        result = gsub(/%([{<])/, '%%\1')
        result.send :'interpolate_without_ruby_19_syntax', args
      end
    end
  end
end
