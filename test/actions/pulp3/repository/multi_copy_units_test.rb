require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class MultiCopyUnitsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action_class) { ::Actions::Pulp3::Repository::MultiCopyUnits }
    let(:action) { create_action action_class }
    let(:source) { katello_repositories(:rhel_6_x86_64) }
    let(:erratum) { katello_errata(:security) }

    it 'returns each repository its own advisory href' do
      other = katello_repositories(:fedora_17_x86_64)

      hrefs = action.erratum_hrefs([source.id, other.id], [erratum.id])

      assert_equal ['fedora_17_x86_64_security_href', 'rhel6_security_href'], hrefs.sort
    end
  end
end
