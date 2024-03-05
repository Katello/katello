module Katello
  module SubscriptionMailerHelper
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def report_url
      base_url = report_data_report_template_path(@report_template.id, job_id: @provider_job_id)
      "#{Setting[:foreman_url]}#{base_url}"
    end

    def report_link
      link_to _("View a report of the affected hosts"), report_url
    end

    def start_report_task(days_from_now)
      @report_template = ReportTemplate.find_by(name: "Subscription - General Report")
      template_input_id = @report_template.template_inputs.find_by_name("Days from Now").id.to_s
      params = { format: 'csv', template_id: @report_template.id, input_values: { template_input_id => { value: days_from_now} } }
      composer = ReportComposer.new(params)
      @provider_job_id = composer.schedule_rendering.provider_job_id
    end
  end
end
