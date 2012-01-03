module IndexedModel

  def self.included(base)
    base.class_eval do

      if !Rails.env.test?
        include Tire::Model::Search
        include Tire::Model::Callbacks
        index_name AppConfig.elastic_index + '_' +  self.name.downcase
      else
        #stub mapping
        def self.mapping
        end
      end
      cattr_accessor :class_index_options


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


  def to_indexed_json

    to_ret = {}
    attrs = attributes.keys.collect{|key| key.to_sym}
    attrs += self.lazy_attributes if self.respond_to?(:lazy_attributes)
    
    if self.class.class_index_options[:json]
      options = self.class.class_index_options[:json]
      if options[:only]
        attrs = options[:only]
      elsif options[:except]
        attrs -= options[:except]
      end
    end
    
    (attrs).each{|attr|
      to_ret[attr] = self.send(attr)
    }

    if self.class.class_index_options[:extended_json]
      to_ret.merge!(self.send(self.class.class_index_options[:extended_json]))
    end
        
    to_ret.to_json
  end

end
