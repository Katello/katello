object @resource

attributes :id, :errata_id, :title, :summary, :description, :status
attributes :version, :release, :updated, :_href, :issued, :pushcount
attributes :type, :severity, :solution, :rights, :from_str, :reboot_suggested
attributes :references, :sort
attributes :children

attribute :product_cp_ids => :product_ids
