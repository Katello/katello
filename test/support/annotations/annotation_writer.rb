module Katello
  module Annotations
    class AnnotationWriter
      def initialize(filename)
        @file = File.open(filename, 'w')
        @file.write(header_template)
      end

      def header_template
        File.read(File.dirname(__FILE__) + '/templates/header.erb')
      end

      def annotation_template
        File.read(File.dirname(__FILE__) + '/templates/annotation.erb')
      end

      def close
        @file.close
      end

      def write(name, matched_annotations)
        output = "# #{name}\n"
        matched_annotations.each_with_index do |annotation, count|
          output += ERB.new(annotation_template).result(binding)
        end
        @file.write(output)
      end

      def prettify_body(body)
        JSON.pretty_generate(JSON.parse(body))
      rescue JSON::ParserError
        body
      end
    end
  end
end
