module Katello
  module Annotations
    class AnnotationFile
      attr_accessor :name, :annotations, :cassette_name

      def initialize(hash)
        self.name = hash['name']
        self.annotations = hash['annotations'].map { |annotation| MatchedAnnotation.new(annotation) }
        self.cassette_name = hash['cassette']
      end

      def matchup_requests(vcr_requests)
        annotations.each do |annotation|
          annotation.add_matches(vcr_requests)
          matched_vcr_requests = annotation.requests
          if matched_vcr_requests.any?
            vcr_requests -= matched_vcr_requests
            annotation.requests += matched_vcr_requests
          end
        end

        unmatched_annotations = annotations.select { |annotation| !annotation.matched? }
        matched_annotations = annotations.select { |annotation| annotation.matched? }
        [matched_annotations, unmatched_annotations, vcr_requests]
      end

      def self.load_annotations(directory)
        Dir["#{directory}/*.yaml"].map do |file|
          Annotations::AnnotationFile.new(YAML.load_file(file))
        rescue => e
          raise "Cannot read #{file}: #{e.message}"
        end
      end
    end
  end
end
