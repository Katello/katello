module Katello
  module Concerns::AuditCommentExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      # to prevent PG::StringDataRightTruncation: ERROR:  value too long for type character varying(255)
      def truncate_audit_comment(long_comment)
        if long_comment.length > 255
          Rails.logger.info "Truncating audit comment: #{long_comment}"
          "#{long_comment[0..250]}..."
        else
          long_comment
        end
      end
    end
  end
end
