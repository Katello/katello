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

  def submit(*args)
    options = args.extract_options!
    options.symbolize_keys!
    options[:tabindex] ||= tabindex
    args.push options
    content_tag :div, :class => "grid_5 la prefix_2" do
      super
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
      options[wrapper][:class] |= ["grid_#{options[:grid][i]}", (i==0 ? "ra" : "la")]
    end
    options[:tabindex] ||= tabindex
    options[:wrapper] ||= {}
    options[:size] ||= '30'

    content_tag :fieldset, :id => options[:wrapper][:id] do
      @template.concat label_wrapper(options) { field_label(name, options) }
      @template.concat input_wrapper(options) { yield if block_given? }
    end

  end

  def label_wrapper(options)
    content_tag(:div, :class => options[:label_wrapper][:class]) { yield }
  end

  def input_wrapper(options)
    content_tag(:div, :class => options[:input_wrapper][:class]) { yield } +
    (content_tag(:i, '', :class => 'details-icon', 'data-help' => options[:help]) if options[:help])
  end

  def field_label(name, options)
    required = object.class.validators_on(name).any? do|v|
      v.kind_of? ActiveModel::Validations::PresenceValidator
    end
    label(name, options[:label], :class => ("required" if required))
  end

  def objectify_options(options)
    super.except(:label, :label_wrapper, :input_wrapper, :grid, :wrapper)
  end

end