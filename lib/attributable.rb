# frozen_string_literal: true

require 'symbolized'

module BanditMayhem
  module Attributable
    AttributeError = Class.new(RuntimeError)

    def self.included(base)
      base.class_eval do
        attr_reader :errors

        def self.inherited(clazz)
          attributes.each do |attr, value|
            clazz.class_eval { attribute attr, value }
          end

          clazz.instance_variable_set(:@validations, validations)
          # clazz.instance_variable_set(:@attributes, attributes)

          super
        end

        # Attributable entity
        #
        # @param [Symbol] name the name of the attribute
        # @param [Any] default_value the value defaulted
        def self.attribute(name, default_value = nil, **validations)
          @attributes ||= {}
          @validations ||= {}

          attr_writer name

          define_method(name) do
            instance_variable_get("@#{name}") ||
              instance_variable_set("@#{name}", default_value)
          end

          @attributes[name] = default_value
          @validations[name] = validations if validations.any?
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

        def self.validations
          @validations
        end

        # All declared validations
        #
        # @return [Hash]
        def validations
          self.class.validations
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

          warn "skipping attribute(s) `#{extraneous_attrs.join(',')}` for #{self.class} as they are not specified for this class." if extraneous_attrs.any?
        end

        # Return an attribute by means of a symbol index
        def [](attr)
          public_send(attr)
        end

        def valid?
          @errors = []

          validations.each do |validation|
            attr, checks = validation

            checks.each do |check|
              c, v = check
              content = current_attributes[attr]

              case c
              when :required
                @errors << "#{attr} is required" if v == true && content.nil?
              when :type
                # check the data type
                @errors << "#{attr} is not a #{v}" unless content.is_a?(v)
              else
                raise AttributeError, "unknown validation #{c}"
              end
            end
          end

          @errors.none?
        end
      end
    end
  end
end
