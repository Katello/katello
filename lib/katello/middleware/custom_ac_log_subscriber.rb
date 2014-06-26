module Katello
  module Middleware
    class CustomAcLogSubscriber < ActionController::LogSubscriber
      INTERNAL_PARAMS = ActionController::LogSubscriber::INTERNAL_PARAMS

      def start_processing(event)
        return unless logger.info?

        if needs_filtering?(event)
          params = event.payload[:params]
          param_names_to_filter = parameter_names_to_filter_from_path(event)
          log_payload(event.payload, filter_params(params, param_names_to_filter))
        else
          super
        end
      end

      private

      def parameters_to_filter
        unless @filtered_parameters
          configs = Katello.config.logging.filter_parameters_by_path
          @filtered_parameters ||= configs ? configs.map{|fp| OpenStruct.new(fp)} : []
        end
        @filtered_parameters
      end

      def filter_params(params, names_to_filter)
        result = params.clone
        (result.keys & names_to_filter).each do |key|
          result[key] = "[FILTERED]"
        end
        result
      end

      def log_payload(payload, params)
        format  = payload[:format]
        format  = format.to_s.upcase if format.is_a?(Symbol)

        info "Processing by #{payload[:controller]}##{payload[:action]} as #{format}"
        info "  Parameters: #{params.inspect}" unless params.empty?
      end

      def parameter_names_to_filter_from_path(event)
        result = parameters_to_filter.find{ |p| event.payload[:path].include?(p.path) }
        result.names
      end

      def needs_filtering?(event)
        parameters_to_filter.any? do |p|
          event.payload[:path].include?(p.path) &&
            (event.payload[:params].keys & p.names).size > 0
        end
      end
    end
  end
end
