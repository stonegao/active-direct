module ActiveDirect
  module Initializer

    # NOTE : The following code was stealed from the awesome ThinkingSphinx lib :-)
    # 
    # Make sure all models are loaded - without reloading any that
    # ActiveRecord::Base is already aware of (otherwise we start to hit some
    # messy dependencies issues).
    def self.load_models
      return if defined?(Rails) && Rails.configuration.cache_classes

      self.model_directories.each do |base|
        Dir["#{base}**/*.rb"].each do |file|
          model_name = file.gsub(/^#{base}([\w_\/\\]+)\.rb/, '\1')

          next if model_name.nil?
          next if ::ActiveRecord::Base.send(:subclasses).detect { |model|
            model.name == model_name
          }

          begin
            model_name.camelize.constantize
          rescue LoadError
            model_name.gsub!(/.*[\/\\]/, '').nil? ? next : retry
          rescue NameError
            next
          rescue StandardError
            puts "Warning: Error loading #{file}"
          end
        end
      end
    end

    def self.model_directories
      if defined?(RAILS_ROOT)
        ["#{RAILS_ROOT}/app/models/"]
      else
        []
      end
    end

  end
end

if defined?(Rails) && Rails.configuration
  Rails.configuration.after_initialize do
    ActiveDirect::Initializer.load_models
  end
end
