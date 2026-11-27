require 'katello_test_helper'

module Actions::Katello::ContentViewVersion
  class IncrementalUpdateAdoptionTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::ContentViewVersion::IncrementalUpdate }
    let(:action) { create_action action_class }

    before do
      User.current = users(:admin)
    end

    describe 'Library version adoption' do
      let(:library_repo) { katello_repositories(:fedora_17_x86_64) }
      let(:base_repo) { katello_repositories(:fedora_17_x86_64_dev) }
      let(:rpm_one) { katello_rpms(:one) }
      let(:rpm_two) { katello_rpms(:two) }
      let(:rpm_three) { katello_rpms(:three) }
      let(:erratum) { katello_errata(:security) }

      before do
        # The base of an incremental update is a published copy, not a soft copy
        # of the library; adoption must not depend on that.
        base_repo.stubs(:soft_copy_of_library?).returns(false)
        library_repo.update!(:version_href => '/pulp/api/v3/repositories/rpm/rpm/library/versions/1/',
                             :publication_href => '/pulp/api/v3/publications/rpm/rpm/library/')
      end

      def content_index_with(units)
        index = ::Katello::ContentIndex.create!(:version_href => "/pulp/api/v3/repositories/rpm/rpm/#{SecureRandom.uuid}/versions/1/")
        units.each do |unit_class, class_units|
          association = unit_class.content_index_association_class
          class_units.each do |unit|
            association.create!(:content_index_id => index.id, unit_class.unit_id_field => unit.id)
          end
        end
        index
      end

      def point_repo_at(repo, units)
        index = content_index_with(units)
        repo.update!(:version_href => index.version_href, :content_index_id => index.id)
        index
      end

      def point_at(base_units, library_units)
        point_repo_at(base_repo, base_units)
        point_repo_at(library_repo, library_units)
      end

      def adoptable(content, sources: [base_repo], dep_solve: false, changed_root_ids: [base_repo.root_id])
        action.send(:adoptable_library_repos, [sources], changed_root_ids, content, dep_solve)
      end

      it 'does not prove roots the selection did not touch' do
        point_at({ ::Katello::Rpm => [rpm_one] }, { ::Katello::Rpm => [rpm_one, rpm_two] })

        assert_empty adoptable({ :package_ids => [rpm_two.id] }, :changed_root_ids => [])
      end

      it 'adopts the library version when the library only gained the requested units' do
        point_at({ ::Katello::Rpm => [rpm_one, rpm_two] }, { ::Katello::Rpm => [rpm_one, rpm_two, rpm_three] })

        assert_equal({ base_repo.root_id => library_repo },
                     adoptable({ :package_ids => [rpm_three.id] }))
      end

      it 'adopts when the selection names units the library does not hold' do
        point_at({ ::Katello::Rpm => [rpm_one] }, { ::Katello::Rpm => [rpm_one, rpm_two] })

        assert_equal({ base_repo.root_id => library_repo },
                     adoptable({ :package_ids => [rpm_two.id, rpm_three.id] }))
      end

      it 'does not adopt when the library has no publication to hand over' do
        point_at({ ::Katello::Rpm => [rpm_one] }, { ::Katello::Rpm => [rpm_one, rpm_two] })
        library_repo.update!(:publication_href => nil)

        assert_empty adoptable({ :package_ids => [rpm_two.id] })
      end

      it 'does not adopt when the library holds units the request did not name' do
        point_repo_at(base_repo, { ::Katello::Rpm => [rpm_one] })
        point_repo_at(library_repo, { ::Katello::Rpm => [rpm_one, rpm_two, rpm_three] })

        assert_empty adoptable({ :package_ids => [rpm_two.id] })
      end

      it 'does not adopt when the delta removes content' do
        point_repo_at(base_repo, { ::Katello::Rpm => [rpm_one, rpm_two] })
        point_repo_at(library_repo, { ::Katello::Rpm => [rpm_one] })

        assert_empty adoptable({ :package_ids => [rpm_three.id] })
      end

      it 'does not adopt when a unit type that must not grow did grow' do
        srpm = katello_srpms(:one)
        point_repo_at(base_repo, { ::Katello::Rpm => [rpm_one] })
        point_repo_at(library_repo, { ::Katello::Rpm => [rpm_one, rpm_two], ::Katello::Srpm => [srpm] })

        assert_empty adoptable({ :package_ids => [rpm_two.id] })
      end

      it 'does not adopt when the base already points at the library index' do
        index = content_index_with({ ::Katello::Rpm => [rpm_one] })
        base_repo.update!(:version_href => index.version_href, :content_index_id => index.id)
        library_repo.update!(:version_href => index.version_href, :content_index_id => index.id)

        assert_empty adoptable({ :package_ids => [rpm_one.id] })
      end

      it 'does not adopt through an index for another version' do
        point_at({ ::Katello::Rpm => [rpm_one] }, { ::Katello::Rpm => [rpm_one, rpm_two] })
        library_repo.update_columns(:version_href => '/pulp/api/v3/repositories/rpm/rpm/library/versions/2/')

        assert_empty adoptable({ :package_ids => [rpm_two.id] })
      end

      it 'pins the index of the version it reuses' do
        index = point_repo_at(library_repo, { ::Katello::Rpm => [rpm_one] })
        action.expects(:plan_action).with(::Actions::Katello::Repository::MetadataGenerate, base_repo,
                                          has_entries(:source_content_index_id => index.id))

        action.send(:plan_reuse, base_repo, library_repo)
      end

      it 'does not pin an index that does not match the version reused' do
        point_repo_at(library_repo, { ::Katello::Rpm => [rpm_one] })
        library_repo.update_columns(:version_href => '/pulp/api/v3/repositories/rpm/rpm/library/versions/2/')
        action.expects(:plan_action).with(::Actions::Katello::Repository::MetadataGenerate, base_repo,
                                          has_entries(:source_content_index_id => nil))

        action.send(:plan_reuse, base_repo, library_repo)
      end

      it 'does not adopt when dependency solving may pull unnamed units' do
        point_at({ ::Katello::Rpm => [rpm_one] }, { ::Katello::Rpm => [rpm_one, rpm_two] })

        assert_empty adoptable({ :package_ids => [rpm_two.id] }, :dep_solve => true)
      end

      it 'does not adopt when the base version draws from more than one repository' do
        point_at({ ::Katello::Rpm => [rpm_one] }, { ::Katello::Rpm => [rpm_one, rpm_two] })

        assert_empty adoptable({ :package_ids => [rpm_two.id] },
                               :sources => [base_repo, katello_repositories(:fedora_17_x86_64_dev_archive)])
      end

      it 'does not adopt when either side has no content index' do
        point_repo_at(base_repo, { ::Katello::Rpm => [rpm_one] })
        library_repo.update!(:content_index_id => nil)

        assert_empty adoptable({ :package_ids => [rpm_one.id] })
      end

      it 'adopts the library when the only addition is an advisory and its package' do
        advisory = katello_errata(:modular)
        package = katello_rpms(:modular_with_erratum_package)
        point_at({ ::Katello::Rpm => [rpm_one] },
                 { ::Katello::Rpm => [rpm_one, package], ::Katello::Erratum => [advisory] })

        adoptable_repos = adoptable({ :errata_ids => [advisory.errata_id] })

        assert_equal library_repo, adoptable_repos[base_repo.root_id]
      end

      it 'ignores an advisory package held only by another repository' do
        advisory = katello_errata(:modular)
        package = katello_rpms(:modular_with_erratum_package)
        decoy = ::Katello::Rpm.create!(:name => 'decoy', :pulp_id => 'decoy-uuid', :filename => package.filename,
                                       :epoch => 0, :version => '1', :release => '1', :arch => 'x86_64',
                                       :nvra => 'decoy-1-1.x86_64')
        ::Katello::RepositoryRpm.create!(:repository_id => katello_repositories(:rhel_6_x86_64).id, :rpm_id => decoy.id)
        point_at({ ::Katello::Rpm => [rpm_one] },
                 { ::Katello::Rpm => [rpm_one, package], ::Katello::Erratum => [advisory] })

        assert_equal library_repo, adoptable({ :errata_ids => [advisory.errata_id] })[base_repo.root_id]
      end

      it 'counts packages for advisories requested by numeric id' do
        advisory = katello_errata(:modular)
        package = katello_rpms(:modular_with_erratum_package)
        errata_ids = action.selected_unit_ids(:errata_ids => [advisory.id])[:errata_ids]

        assert_equal [package.id], action.send(:errata_package_ids, errata_ids)
      end
    end

    describe 'errata selections' do
      let(:erratum) { katello_errata(:security) }
      let(:holding_repo) { katello_repositories(:rhel_6_x86_64) }

      it 'resolves the selected errata to the roots and ids the proof uses' do
        roots = action.content_root_ids(:errata_ids => [erratum.errata_id])
        selected = action.selected_unit_ids(:errata_ids => [erratum.errata_id])

        assert_includes roots, holding_repo.root_id
        assert_equal [erratum.id], selected[:errata_ids]
      end

      it 'resolves Pulp ids to the same roots as database ids' do
        assert_includes action.content_root_ids(:errata_ids => [erratum.pulp_id]), holding_repo.root_id
      end
    end
  end
end
