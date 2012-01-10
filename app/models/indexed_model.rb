module IndexedModel

  def self.included(base)
    base.class_eval do
      if !Rails.env.test?
        include Tire::Model::Search
        include Tire::Model::Callbacks
        index_name AppConfig.elastic_index + '_' +  self.base_class.name.downcase

        def self.index_import list
          self.index.import(list)
        end

        def self.display_attributes
          self.class_index_options[:display_attrs]
        end



      else
        #stub mapping
        def self.mapping
        end
        def self.index_import list
        end
      end
      cattr_accessor :class_index_options


      ##
      #  :json  - normal to_json options,  :only or :except allowed
      #  :extended_json  - function to call to return a hash to merge into document
      #  :display_attrs  - list of attributes to display as searchable
      ##
      def self.index_options options={}
          self.class_index_options = options
      end


      def self.use_index_of(model)
        if !Rails.env.test?
          index_name model.index_name
          document_type model.document_type
        end
      end
    end
  end

  #mocked methods for testing
  if Rails.env.test?
    def update_index
    end

  end

  def indexed_attributes
    attrs = self.attributes.keys.collect{|key| key.to_sym}
    attrs += self.class.lazy_attributes if self.respond_to?(:lazy_attributes)

    if self.class.class_index_options[:json]
      options = self.class.class_index_options[:json]
      if options[:only]
        attrs = options[:only]
      elsif options[:except]
        attrs -= options[:except]
      end
    end
    attrs
  end

  def to_indexed_json
    to_ret = {}

    attrs = self.indexed_attributes

    (attrs).each{|attr|
      to_ret[attr] = self.send(attr)
    }

    if self.class.class_index_options[:extended_json]
      to_ret.merge!(self.send(self.class.class_index_options[:extended_json]))
    end

    to_ret.to_json
  end

end
