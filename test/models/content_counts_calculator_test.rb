require 'katello_test_helper'

module Katello
  class ContentCountsCalculator < ActiveSupport::TestCase
    let(:repositories_data) do
      [{
        "display_name"=>"rpm repo 1",
        "notes"=>{"_repo-type"=>"rpm-repo"},
        "content_unit_counts"=>{
          "package_group"=>2,
          "rpm"=>32,
          "erratum"=>4
        },
        "id"=>"rpm-repo-1"
      }, {
        "display_name"=>"rpm repo 2",
        "notes"=>{"_repo-type"=>"rpm-repo"},
        "content_unit_counts"=>{
          "package_group"=>3,
          "rpm"=>6,
          "erratum"=>1
        },
        "id"=>"rpm-repo-2"
      }, {
        "display_name"=>"docker repo",
        "notes"=>{"_repo-type"=>"docker-repo"},
        "content_unit_counts"=>{
          "docker_image" => 5
        },
        "id"=>"docker-repo"
      }, {
        "display_name"=>"puppet repo 1",
        "notes"=>{"_repo-type"=>"puppet-repo"},
        "content_unit_counts"=>{
          "puppet_module" => 1
        },
        "id"=>"puppet-repo-1"
      }, {
        "display_name"=>"puppet repo 2",
        "notes"=>{"_repo-type"=>"puppet-repo"},
        "content_unit_counts"=>{
          "puppet_module" => 2
        },
        "id"=>"puppet-repo-2"
      }]
    end

    test 'count calculation' do
      calculator = Katello::Pulp::ContentCountsCalculator.new(repositories_data)
      expected_counts = {
        :yum_repositories => 2,
        :packages => 38,
        :package_groups => 5,
        :errata => 5,
        :puppet_repositories => 2,
        :puppet_modules => 3,
        :docker_repositories => 1,
        :docker_images => 5
      }

      assert_equal expected_counts, calculator.calculate
    end

    test 'return zero counts for empty repos' do
      calculator = Katello::Pulp::ContentCountsCalculator.new([])
      expected_counts = {
        :yum_repositories => 0,
        :packages => 0,
        :package_groups => 0,
        :errata => 0,
        :puppet_repositories => 0,
        :puppet_modules => 0,
        :docker_repositories => 0,
        :docker_images => 0
      }

      assert_equal expected_counts, calculator.calculate
    end
  end
end
