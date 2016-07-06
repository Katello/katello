module Katello
  module PackagesHelper
    def format_changelog_changes(changes)
      h(changes).gsub(/\n/, "<br>").html_safe
    end

    def format_changelog_date(date)
      format_time(DateTime.strptime(date.to_s, "%s").to_date, format: :long)
    end

    # This method will format the package details provided using a format
    # similar to what is used in an rpm spec.  For example:
    #   package-a
    #   package-b = 1.2.0
    #   package-c = 9:1.2.0
    #   package-d >= 9:1.2.0-3
    #
    # where, the operator, epoch (e.g. 9), version (e.g 1.2.0) and
    # release (e.g. 3) are optional
    def format_package_details(package)
      package_details = package[:name]

      unless package[:flags].blank?
        package_details = [package_details, package_operator(package[:flags]), ''].join(' ')
        package_details += package[:epoch] + ':' unless package[:epoch].blank?
        package_details += package[:version] unless package[:version].blank?
        package_details += '-' + package[:release] unless package[:release].blank?
      end

      package_details
    end

    def package_operator(flag)
      case flag
      when 'EQ'
        '='
      when 'LT'
        '<'
      when 'LE'
        '<='
      when 'GT'
        '>'
      when 'GE'
        '>='
      end
    end

    def changelog_changes(changes)
      if (lines = changes.split(/\n/)).length > 10
        previewed_changelog(lines)
      else
        format_changelog_changes(changes)
      end
    end

    def previewed_changelog(lines)
      html = format_changelog_changes(lines[0, 10].join("\n"))
      html += content_tag "p" do
        more_lines = number_with_delimiter(lines.length - 10)
        link_to((_("Show %s more line(s)") % more_lines), "", class: "show-more-changelog")
      end
      html + content_tag("div", :class => "more-changelog") do
        format_changelog_changes(lines[10..-1].join("\n"))
      end
    end
  end
end
