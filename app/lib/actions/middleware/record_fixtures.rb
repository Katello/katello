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
