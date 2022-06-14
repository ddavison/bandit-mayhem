# frozen_string_literal: true

require 'yaml'
require 'symbolized'

module BanditMayhem
  class Settings
    module_function

    private
    # save the settings to the settings.yml file
    def save_settings
      File.open('settings.yml', 'w') { |f| YAML.dump(@settings, f) }
    end
  end
end
