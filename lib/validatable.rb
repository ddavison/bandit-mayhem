# frozen_string_literal: true

module BanditMayhem
  # Validatable
  module Validatable
    def self.included(clazz)
      clazz.class_eval do
        attr_reader :validations

        @validations = {}

        # Validates an attribute matches specific conditions
        def self.validates(attribute, **conditions)
          (@validations[attribute] ||= []) << conditions
        end
      end
    end

    def valid?
      self.class.validations.each do |validation|
        puts validation
      end
    end
  end
end
