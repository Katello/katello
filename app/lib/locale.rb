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

module Locale

  def self.included(controller)
    controller.before_filter :set_locale_from_header
  end

  def set_locale_from_header
    set_locale parse_accept_locale
  end

  def set_locale locales
    locales = Array(locales)
    if User.current && User.current.default_locale
      I18n.locale = User.current.default_locale
    else
      I18n.locale = pick_available_locale locales
    end

    Rails.logger.debug "Setting locale: #{I18n.locale}"
  end
  module_function :set_locale

  # Look for match to list of locales specified in request. If not found, try matching just
  # first two letters. Finally, default to english if no matches at all.
  # eg. [en_US, en] would match en
  #
  # The method accept parameter = list of locales returned by parse_locale. Since the method is used
  # outside of the request context, we need to pass this data in as a parameter.
  def pick_available_locale locales
    locales = Array(locales)

    # Look for full match
    locales.each do |locale|
      return locale if Katello.config.available_locales.include? locale
    end

    # Look for match to first two letters
    locales.each do |locale|
      return locale[0..1] if Katello.config.available_locales.include? locale[0..1]
    end

    # Default to 'en'
    return 'en'
  end
  module_function :pick_available_locale

  # adapted from http_accept_lang gem, return list of browser locales
  def parse_accept_locale
    locale_lang = (request.env['HTTP_ACCEPT_LANGUAGE'] || '').split(/\s*,\s*/).collect do |l|
      l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
      l.split(';q=')
    end.sort do |x, y|
      raise "incorrect locale format" unless x.first =~ /^[a-z\-]+$/i
      y.last.to_f <=> x.last.to_f
    end.collect do |l|
      l.first.downcase.gsub(/-[a-z]+$/i) { |x| x.upcase }
    end
  end

end

