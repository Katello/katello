module Katello
  class Api::V2::ContentViewFilterBulkRulesController < Api::V2::ApiController
    before_action :find_filter
    before_action :find_rule, :except => [:create]

    api :POST, "/content_view_filters/:content_view_filter_id/bulk",
        N_("Create a bunch of filter rules. The parameters included should be based upon the filter type.")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :data, Array, :of => [Hash], :desc => N_("hash for RPM bulkloads: \
                                                    [{'name': 'name', \
                                                    'version': 'version',\
                                                    'architecture': 'architecture'}]") do
      param :name, String, :desc => N_("package name"), :required => true
      param :version, String, :desc => N_("package version"), :required => false
      param :architecture, String, :desc => N_("package architecture"), :required => false
    end
    def create
      rule_clazz = ContentViewFilter.rule_class_for(@filter)
      _data = JSON.parse(params[:data].gsub("'", "\""))
      if _data.is_a?(Array) and _data.all? { |value| value['name'].length >= 1 and value['version'].length >= 1 }
        rules = _data.each.map do |bulk_rule|
          begin
            rule_clazz.create!([:filter => @filter, name: bulk_rule['name'],
                                                    version: bulk_rule['version'],
                                                    architecture: bulk_rule['architecture']])
          rescue
            # no need to abort if other rules can be created
          end
        end
      else
        fail HttpErrors::BadRequest, _("Parameter 'data' must be an array of hash: " \
                                       + "[{'name': 'name1', 'version': 'ver1', 'architecture': 'arch1'},"\
                                       + " {'name': 'name2', 'version': 'ver2', 'architecture': 'arch2'},"\
                                       + " ...]")
      end

      rules = rules.flatten.select{|v| v != nil}

      if not rules.any?
        fail HttpErrors::UnprocessableEntity, _("No rules has been created at all. They're supposed to be already created!!!")
      elsif rules.count != _data.count
        respond_for_index(:collection => {:results => rules,
                                          :error => true,
                                          :total => rules.length},
                          :template => 'index')
      else
        if rules.length == 1
          respond_for_create resource: rules.first
        else
          respond_for_index(:collection => {:results => rules,
                                            :total => rules.length},
                            :template => 'index')
        end
      end

    end

    api :GET, "/content_view_filters/:content_view_filter_id/rules/:id", N_("Show filter rule info")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :id, :number, :desc => N_("rule identifier"), :required => true
    def show
      respond :resource => @rule
    end

    api :DELETE, "/content_view_filters/:content_view_filter_id/bulk/rules/:id", N_("Delete a filter rule")
    param :content_view_filter_id, :number, :desc => N_("filter identifier"), :required => true
    param :id, :number, :desc => N_("rule identifier"), :required => true
    def destroy
      @rule.destroy
      respond_for_show :resource => @rule
    end

    private

    def find_filter
      @filter = ContentViewFilter.find(params[:content_view_filter_id])
    end

    def find_rule
      rule_clazz = ContentViewFilter.rule_class_for(@filter)
      @rule = rule_clazz.find(params[:id])
    end
    
  end
end
