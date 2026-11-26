module Katello
  class ErrataListPresenter < HostCountsPresenter
    def package_nvreas
      details.package_nvreas(id)
    end

    def module_streams
      details.module_streams(id)
    end
  end
end
