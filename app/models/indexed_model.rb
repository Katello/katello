module IndexedModel

  def self.included(base)
    base.class_eval do
      include Tire::Model::Search
      include Tire::Model::Callbacks

      cattr_accessor :class_index_options

      index_name AppConfig.elastic_index

      def self.index_options options={}
          self.class_index_options = options
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
