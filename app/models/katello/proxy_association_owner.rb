module Katello
  module ProxyAssociationOwner
    def proxy_association_owner
      /(\d+)\.(\d+)\.(\d+)/ =~ Rails.version
      ((Regexp.last_match[1].to_i >= 4) || (Regexp.last_match[1].to_i == 3 && Regexp.last_match[2].to_i >= 1)) ? proxy_association.owner : proxy_owner
    end
  end
end
