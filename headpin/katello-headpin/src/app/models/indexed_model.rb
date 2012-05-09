require "util/search"

module IndexedModel

  def self.included(base)
    base.class_eval do


        cattr_accessor :class_index_options
        def self.display_attributes
          self.class_index_options[:display_attrs].sort{|a,b| a.to_s <=> b.to_s}
        end


      if !Rails.env.test?
        include Tire::Model::Search
        include Tire::Model::Callbacks
        index_name AppConfig.elastic_index + '_' +  self.base_class.name.downcase

        #Shared analyzers.  If you need a model-specific analyzer for some reason,
        #  we'll need to refactor this to support that.
        settings :analysis => {
                    "analyzer" => Katello::Search.custom_analzyers
                  }

        def self.index_import list
          self.index.import(list)
        end

      else
        #stub mapping
        def self.mapping *args
        end
        def self.index_import list
        end
      end

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
    attrs += self.lazy_attributes if self.respond_to?(:lazy_attributes)

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
