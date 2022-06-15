# frozen_string_literal: true

# Start monkey patch of Object::String
class String
  # Classify a string
  # @example
  #   'test_class'.classify #=> TestClass
  # @example
  #   'testclass'.classify #=> Testclass
  def classify
    split('_').map(&:capitalize).join
  end

  # Underscore a multi-worded string
  # @example
  #   'TestClass'.underscore #=> 'test_class'
  # @example
  #   'Class'.underscore #=> 'class'
  # @example
  #   'Test Class'.underscore #=> 'test_class'
  def underscore
    chars.each_with_object(+'') do |c, str|
      str << '_' if c.match?(/[A-Z]/) && !str.size.zero?
      str << c.downcase unless c == ' '
    end
  end
end

