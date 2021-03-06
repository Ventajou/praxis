module Praxis
  module BootloaderStages
    class PluginConfigLoad < Stage

      def execute
        application.plugins.each do |config_key, plugin|
          context = [plugin.class.name]
          value = plugin.load_config!
          object = plugin.config_attribute.load(value, context)

          if object
            application.config.send("#{config_key}=", object)
          end

          plugin.config = application.config.send("#{config_key}")
        end
      end

    end
  end
end
