module Katello
  module RepositoriesHelper
    def gpg_keys_edit
      keys = {}

      GpgKey.readable(current_organization).each do |key|
        keys[key.id] = key.name
      end

      keys[""] = ""
      keys["selected"] = @repository.gpg_key_id || ""
      return keys.to_json
    end

    def gpg_keys
      GpgKey.readable(current_organization)
    end
  end
end
