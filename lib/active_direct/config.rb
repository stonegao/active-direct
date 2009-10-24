module ActiveDirect
  class Config
    cattr_accessor :method_config
    class << self
      def method_config
        @@method_config ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def has_model?(model)
        method_config.keys.include?(model)
      end

      def has_method?(model, method)
        methods_for(model).include?(method)
      end

      private

      def methods_for(model)
        method_config[model].map {|m| m['name']}
      end
      
    end
  end
end