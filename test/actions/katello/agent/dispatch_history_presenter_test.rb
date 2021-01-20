require 'katello_test_helper'

module Actions
  module Katello
    module Agent
      class DispatchHistoryPresenterTest < ActiveSupport::TestCase
        let(:content_type) { "rpm" }
        let(:action_type) { @action_type || :content_install }
        let(:dispatch_history) { stub(status: @status) }
        let(:presenter) { Actions::Katello::Agent::DispatchHistoryPresenter.new(dispatch_history, action_type) }

        def test_humanized_output_packages
          @status = {
            content_type => {
              "details" => {
                "resolved" => [
                  {"name" => "emacs", "qname" => "1:emacs-23.1-21.el6_2.3.x86_64", "epoch" => "1", "version" => "23.1", "release" => "21.el6_2.3", "arch" => "x86_64", "repoid" => "eng-Server"}
                ],
                "deps" => [
                  {"name" => "libXmu", "qname" => "libXmu-1.1.1-2.el6.x86_64", "epoch" => "0", "version" => "1.1.1", "release" => "2.el6", "arch" => "x86_64", "repoid" => "eng-Server"},
                  {"name" => "libXaw", "qname" => "libXaw-1.0.11-2.el6.x86_64", "epoch" => "0", "version" => "1.0.11", "release" => "2.el6", "arch" => "x86_64", "repoid" => "eng-Server"},
                  {"name" => "libotf", "qname" => "libotf-0.9.9-3.1.el6.x86_64", "epoch" => "0", "version" => "0.9.9", "release" => "3.1.el6", "arch" => "x86_64", "repoid" => "eng-Server"}
                ]
              },
              "succeeded" => true
            }
          }

          assert_equal presenter.humanized_output, <<~OUTPUT.chomp
            1:emacs-23.1-21.el6_2.3.x86_64
            libXaw-1.0.11-2.el6.x86_64
            libXmu-1.1.1-2.el6.x86_64
            libotf-0.9.9-3.1.el6.x86_64
          OUTPUT
        end

        def test_humanized_output_message
          @status = {
            content_type => {
              "details" => {
                "message" => "Got into trouble"
              },
              "succeeded" => false
            }
          }

          assert_equal "Got into trouble", presenter.humanized_output
        end

        def test_humanized_output_install_no_packages
          @status = {
            content_type => {
              "details" => {
              }
            }
          }

          assert_equal 'No new packages installed', presenter.humanized_output
        end

        def test_humanized_output_uninstall_no_packages
          @action_type = :content_uninstall
          @status = {
            content_type => {
              "details" => {
                "resolved" => [],
                "deps" => [],
                "succeeded" => true
              }
            }
          }

          assert_equal 'No packages removed', presenter.humanized_output
        end

        def test_error_messages
          @status = {
            content_type => {
              "details" => {
                "message" => "Got into trouble"
              },
              "succeeded" => false
            }
          }

          assert_equal ["Got into trouble"], presenter.error_messages
        end
      end
    end
  end
end
