module BanditMayhem
  module Map
    # Point of Interest
    class Poi
      include Attributable
      include Interactable

      attribute :name
      attribute :x, required: true
      attribute :y, required: true
      attribute :type

      # Instantiate a new Point of Interest (POI)
      #
      # @param [Hash] poi_hash well-formed hash, probably from a map YAML file
      # @return [Poi]
      def initialize(poi_hash)
        merge_attributes poi_hash

        raise AttributeError, [errors, poi_hash] unless valid?
      end

      # Rune to draw on the Map
      def rune
        raise NotImplementedError, "#{self.class} does not implement #rune"
      end

      def interact_with(what)
        raise NotImplementedError, "#{self.class} does not implement #interact_with"
      end

      def to_s
        "(#{x}, #{y})"
      end
    end
  end
end
