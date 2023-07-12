# frozen_string_literal: true

module BanditMayhem
  class Inventory < Array
    # If the inventory includes a specific item
    def include?(obj)
      return super(obj) unless obj.is_a? Item

      select do |item|
        item.name == obj.name
      end
    end

    # If the inventory includes an instance of a specific item
    # @param [Class,String] item the item to find
    # @return [Boolean] true if an item of this type exists
    def has_a?(item)
      clazz = item
      clazz = BanditMayhem::Items.const_get(item.classify) if item.is_a? String

      select do |inventory_item|
        return true if inventory_item.instance_of?(clazz)
      end

      false
    end
  end
end
