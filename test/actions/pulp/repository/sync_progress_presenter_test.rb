require 'katello_test_helper'

module ::Actions::Pulp::Repository
  class OstreePresenterTest < ::ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::PulpTask

    # rubocop:disable MethodLength
    def sync_task_result(pull_progress_details)
      {"state" => "running",
       "progress_report" =>
        {"ostree_web_importer" =>
          [{"num_success" => 1,
            "description" => "Create Local Repository",
            "step_type" => "import_create_repository",
            "items_total" => 1,
            "state" => "FINISHED",
            "error_details" => [],
            "details" => "",
            "num_failures" => 0,
            "step_id" => "f4e7db07-6fb1-4b38-9cd2-583c79754fbe",
            "num_processed" => 1},
           {"num_success" => 1,
            "description" => "Update Summary",
            "step_type" => "import_summary",
            "items_total" => 1,
            "state" => "FINISHED",
            "error_details" => [],
            "details" => "",
            "num_failures" => 0,
            "step_id" => "9533b1a8-bd61-4ff3-9ef8-695840a78aad",
            "num_processed" => 1},
           {"num_success" => 0,
            "description" => "Pull Remote Branches",
            "step_type" => "import_pull",
            "items_total" => 1,
            "state" => "IN_PROGRESS",
            "error_details" => [],
            "details" => pull_progress_details,
            "num_failures" => 0,
            "step_id" => "0b2b463c-80e3-4eff-8d69-44e87346f3c0",
            "num_processed" => 0},
           {"num_success" => 0,
            "description" => "Add Content Units",
            "step_type" => "import_add_unit",
            "items_total" => 1,
            "state" => "NOT_STARTED",
            "error_details" => [],
            "details" => "",
            "num_failures" => 0,
            "step_id" => "42aad729-398a-4f8a-b31c-2a098d172bca",
            "num_processed" => 0},
           {"num_success" => 0,
            "description" => "Clean",
            "step_type" => "import_clean",
            "items_total" => 1,
            "state" => "NOT_STARTED",
            "error_details" => [],
            "details" => "",
            "num_failures" => 0,
            "step_id" => "b65574c7-c969-4b1c-ac21-d2170a2c5153",
            "num_processed" => 0}]}}.with_indifferent_access
    end

    def test_humanized_detail
      ratio = "2222/33333"
      pull_progress_details = "fetching #{ratio} 15%"
      sync_task_result = sync_task_result(pull_progress_details)
      ::Actions::Pulp::Repository::Presenters::OstreePresenter.class_eval do
        def humanized_output
          humanized_details
        end
      end
      action = create_action(::Actions::Pulp::Repository::Sync)
      presenter = ::Actions::Pulp::Repository::Presenters::OstreePresenter.new(action)
      presenter.stubs(:sync_task).returns(sync_task_result)
      assert_includes presenter.humanized_output, ratio
    end
  end
end
