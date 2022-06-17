# frozen_string_literal: true

require 'symbolized'

module BanditMayhem
  module Attributable
    AttributeError = Class.new(RuntimeError)

    def self.included(base)
      base.class_eval do
        def self.inherited(clazz)
          attributes.each do |attr, value|
            clazz.class_eval { attribute attr, value }
          end

          super
        end

        # Attributable entity
        #
        # @param [Symbol] name the name of the attribute
        # @param [Any] default_value the value defaulted
        def self.attribute(name, default_value = nil)
          @attributes ||= {}

          attr_writer name

          define_method(name) do
            instance_variable_get("@#{name}") ||
              instance_variable_set("@#{name}", default_value)
          end

          @attributes[name] = default_value
        end

        def self.attributes
          @attributes
        end

        # All declared attributes
        #
        # @return [Hash]
        def attributes
          self.class.attributes
        end

        # All current and calculated attributes
        #
        # @return [Hash]
        def current_attributes
          attributes.each_key.each_with_object({}) do |key, h|
            h[key] = public_send(key)
          end
        end

        # Merge new attributes into existing attributes or create new attributes
        # @param [Hash] new_attributes the new attributes to merge
        def merge_attributes(new_attributes)
          new_attributes = new_attributes.current_attributes if new_attributes.is_a?(Attributable)

          new_attributes.deep_symbolize_keys!

          raise AttributeError, 'No attributes exist. Have you defined any for this class?' if attributes.nil?

          extraneous_attrs = []

          new_attributes.each do |new_attribute, value|
            if attributes.has_key?(new_attribute)
              public_send("#{new_attribute}=", value)
            else
              extraneous_attrs << new_attribute
            end
          end

          warn "skipping attribute(s) `#{extraneous_attrs.join(',')}` for #{self.class} as it is/they are not specified for this class." if extraneous_attrs.any?
        end

        # Return an attribute by means of a symbol index
        def [](attr)
          public_send(attr)
        end
      end
    end
  end
end
