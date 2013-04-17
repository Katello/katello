#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Experimental
  class KatelloFormBuilder < ActionView::Helpers::FormBuilder

    delegate :content_tag, :tag, :to => :@template

    %w(text_field text_area select file_field).each do |m|
      define_method m do |name, *args|
        base(name, *args) { super(name, *args) }
      end
    end

    def field(name, *args, &block)
      base(name, *args, &block)
    end

    # Support for rendering jquery.jeditable fields.
    # Instead of writing complete html code for the field and the label
    # it allows to use 'editable' form helper.
    #
    # @example usage
    #   kt_form_for @record, :data_url => record_path(@record) do |form|
    #     form.editable :name, :label => _("Name:")
    #   end
    #
    #   kt_form_for @record do |form|
    #     form.editable :name, :data_url => record_path_1(@record)
    #     form.editable :surname, :data_url => record_path_2(@record)
    #   end
    #
    #   kt_form_for @record, :data_url => record_path(@record) do |form|
    #     form.editable :name do
    #       # Some custom value
    #     end
    #   end
    #
    # @param [Hash] options
    # @option options [String] :label label text
    # @option options [true,false] :editable boolean flag, switches possibility to edit the field
    # @option options [String] :class additional css class
    # @option options [String] :help help string
    # @option options [String] :type editable type, eg. edit_textarea, edit_number. Default is edit_panel_element
    # @option options [Hash] :tag  options passed directly to the element
    def editable(name, options)
      options.symbolize_keys!
      options[:editable] = true if options[:editable].nil?
      options[:type] ||= "edit_panel_element"

      tag_options = {}
      tag_options[:name] = "%s[%s]" % [@object_name, name.to_s]
      tag_options[:'data-url'] = options[:'data-url'] || options[:data_url] || @options[:data_url]
      tag_options.update(options[:tag]) if options.key? :tag

      css_class = "%s " % options[:class].to_s
      css_class += "editable %s" % options[:type].to_s if options[:editable]
      css_class.strip!

      field_options = {}
      field_options[:label] = options[:label]
      field_options[:help] = options[:help]
      field_options[:label_help] = options[:label_help]
      field_options[:input_wrapper] = {}
      field_options[:input_wrapper][:class] = css_class
      field_options[:input_wrapper][:tag_options] = tag_options

      base(name, field_options) do
        if block_given?
          yield
        else
          @object.send(name)
        end
      end
    end

    def submit(*args)
      options = args.extract_options!
      options.symbolize_keys!
      options[:tabindex] ||= tabindex
      options[:class] ||= []
      options[:class] << "button primary"
      args.push options

      content_tag :div, :class => "control-group buttons" do
        content_tag :div, :class => "input" do
          super
        end
      end
    end

    def tabindex
      @tabindex ||= @options[:tabindex] || 0
      @tabindex += 1
    end

    private

    def base(name, *args)
      options = args.extract_options!
      options.symbolize_keys!
      options[:grid] ||= [2, 5]
      unless options[:grid].is_a?(Array) && options[:grid].size == 2
        raise ArgumentError, "#{name}[grid]: expecting array of size 2"
      end

      # check if user added some class for wrappers and add grid and align classes
      [:label_wrapper, :input_wrapper].each_with_index do |wrapper, i|
        options[wrapper] ||= {}
        unless options[wrapper][:class].is_a?(Array)
          options[wrapper][:class] = (options[wrapper][:class] || '').split
        end
      end
      
      options[:label_wrapper][:class] |= ['label']
      options[:input_wrapper][:class] |= ['input']
      options[:tabindex] ||= tabindex
      options[:wrapper] ||= {}
      options[:size] ||= '30'

      content_tag :div, :id => options[:wrapper][:id], :class => "control-group" do
        @template.concat label_wrapper(options) { field_label(name, options) }
        @template.concat input_wrapper(options) { yield if block_given? }
      end

    end

    def label_wrapper(options)
      tag_options = options[:label_wrapper][:tag_options] || {}
      tag_options.merge!({:class => options[:label_wrapper][:class]})

      content_tag(:div, tag_options) { yield }
    end

    def input_wrapper(options)
      tag_options = options[:input_wrapper][:tag_options] || {}
      tag_options.merge!({:class => options[:input_wrapper][:class]})

      if options[:help]
        content_tag(:div, tag_options ) do 
          yield +
          content_tag(:i, '', :class => 'details-icon', 'data-help' => options[:help])
        end
      elsif options[:note]
        content_tag(:div, tag_options ) do 
          yield +
          content_tag(:span, options[:note], :class => 'note')
        end
      else
        content_tag(:div, tag_options ) { yield }
      end
    end

    def field_label(name, options)
      required = object.class.validators_on(name).any? do|v|
        v.kind_of? ActiveModel::Validations::PresenceValidator
      end

      label_content = label(name, options[:label], :class => ("required" if required))
      return label_content if options[:label_help].nil?

      help_content = content_tag(:i, '', :class => 'details_icon-grey tipsify', 'title' => options[:label_help])
      return help_content + label_content
    end

    def objectify_options(options)
      super.except(:label, :label_wrapper, :input_wrapper, :grid, :wrapper)
    end

  end
end
