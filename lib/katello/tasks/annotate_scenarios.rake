require "#{Katello::Engine.root}/test/support/annotation_support"
namespace :katello do
  ANNOTATION_DIR = "#{Katello::Engine.root}/test/scenarios/annotations/".freeze
  CASSETTE_DIR = "#{Katello::Engine.root}/test/fixtures/vcr_cassettes/scenarios/".freeze
  OUTPUT_DIR = "#{Rails.root}/tmp/".freeze

  desc "Find scenario test recoreded requests that are unannotated"
  task :find_unannotated_requests => ["environment"] do
    any_failed = false
    Katello::Annotations::AnnotationFile.load_annotations(ANNOTATION_DIR).each do |annotation_file|
      vcr_requests = Katello::Annotations::VcrRequest.load_requests("#{CASSETTE_DIR}/#{annotation_file.cassette_name}")
      matched_annotations, unmatched_annotations, unmatched_requests = annotation_file.matchup_requests(vcr_requests)
      missing_documentation = matched_annotations.select { |annotation| annotation.documented? }

      if unmatched_annotations.any? || unmatched_requests.any? || missing_documentation.any?
        puts ""
        puts annotation_file.name
        puts "Unmatched Annotations:"
        unmatched_annotations.map { |annotation| puts annotation.details }

        puts "Unmatched requests:"
        puts unmatched_requests.map { |request| request.generate_template }.to_yaml

        puts "Undocumented requests:"
        puts missing_documentation.map { |annotation| annotation.requests.first.generate_template }.to_yaml
        any_failed = true
      end
    end
    fail "At least one unmatched annotation or request found." if any_failed
  end

  desc "Generate annotated request documentation suitable for theforeman.org"
  task :create_annotated_output => ["environment"] do
    filename = "#{OUTPUT_DIR}/annotations.md"
    writer = Katello::Annotations::AnnotationWriter.new(filename)

    Katello::Annotations::AnnotationFile.load_annotations(ANNOTATION_DIR).each do |annotation_file|
      vcr_requests = Katello::Annotations::VcrRequest.load_requests("#{CASSETTE_DIR}/#{annotation_file.cassette_name}")
      matched_annotations, _unmatched_annotations, _unmatched_requests = annotation_file.matchup_requests(vcr_requests)

      writer.write(annotation_file.name, matched_annotations)
    end
    writer.close
    puts "Annotations saved to #{filename}"
  end
end
