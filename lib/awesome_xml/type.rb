# frozen_string_literal: true

# This class converts types passed in as arguments to `.node` method calls to a
# type class. Either native or user-defined.
module AwesomeXML
  module Type
    NATIVE_TYPE_CLASSES = {
      text: AwesomeXML::Text,
      integer: AwesomeXML::Integer,
      float: AwesomeXML::Float,
      duration: AwesomeXML::Duration
    }.freeze

    # Takes a type (Symbol, String or Class) passed in from a `.node` method call and the
    # name of the class it was called in. The latter is needed to correctly assign the namespace
    # if the type is given in String form. Returns a class, either one of the native `AwesomeXML`
    # types or a user-defined class. Raises an exception if `type` is given as a Symbol, but
    # does not represent one of the native types.
    def self.for(type, class_name)
      case type
      when Symbol
        NATIVE_TYPE_CLASSES[type] || fail(UnknownNodeType.new(type))
      when String
        [class_name, type].join('::').constantize
      when Class
        type
      end
    end

    # An excception of this type is raised if `type` is given as a Symbol to `.for`, but does not
    # represent one of the native `AwesomeXML` types.
    class UnknownNodeType < StandardError
      def initialize(type)
        super("Cannot create node with unknown node type '#{type}'.")
      end
    end
  end
end
