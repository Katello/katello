module Katello
  module Authorization::Distributor
    extend ActiveSupport::Concern

    def readable?
      environment.distributors_readable?
    end

    def editable?
      environment.distributors_editable?
    end

    def deletable?
      environment.distributors_deletable?
    end

    module ClassMethods
      def readable(org)
        fail "scope requires an organization" if org.nil?
        if org.distributors_readable?
          where(:environment_id => org.kt_environment_ids) #list all distributors in an org
        else #just list for environments the user can access
          where("distributors.environment_id in (#{KTEnvironment.distributors_readable(org).select(:id).to_sql})")
        end
      end

      def any_readable?(org)
        org.distributors_readable? ||
            KTEnvironment.distributors_readable(org).count > 0
      end

      # TODO: these two functions are somewhat poorly written and need to be redone
      def any_deletable?(env, org)
        if env
          env.distributors_deletable?
        else
          org.distributors_deletable?
        end
      end

      def registerable?(env, org)
        (env || org).distributors_registerable?
      end
    end
  end
end
