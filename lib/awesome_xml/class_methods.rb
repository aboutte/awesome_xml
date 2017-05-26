# frozen_string_literal: true

# A collection of class methods that will be available on classes that include `AwesomeXML`.
module AwesomeXML
  module ClassMethods
    attr_reader :context, :nodes, :public_nodes
    private :nodes, :public_nodes

    # Takes in a string representing an XML document. Initializes an instance of the class
    # the module was included in and calls `#parse` on it. See there for more info.
    def parse(xml)
      new(xml).parse
    end

    # Takes in a string representing an XPath and assigns it to the class variable `@@context`.
    # This sets the current context node for all nodes defined below it in the class this
    # module is included in.
    def set_context(xpath)
      @context ||= xpath
    end

    # Works just like `set_context`, but sets the current context node only for nodes defined
    # inside the block passed to this method.
    def with_context(xpath, &block)
      @local_context = xpath
      yield
      @local_context = nil
    end

    # Defines a method on your class returning a constant.
    def constant_node(name, value, options = {})
      attr_reader name.to_sym
      define_method("parse_#{name}".to_sym) do
        instance_variable_set("@#{name}", value)
      end
      register(name, options[:private])
    end

    # Does not actually define a method, but registers the node name
    # in the `@nodes` attribute.
    def method_node(name)
      define_method("parse_#{name}".to_sym) {}
      register(name, false)
    end

    # Defines a method on your class returning a parsed value 
    def node(name, type, options = {}, &block)
      attr_reader name.to_sym
      options[:local_context] = @local_context
      xpath = NodeXPath.new(name, options).xpath
      define_method("parse_#{name}".to_sym) do
        evaluate_args = [xpath, AwesomeXML::Type.for(type, self.class.name), options]
        instance_variable_set(
          "@#{name}",
          evaluate_nodes(*evaluate_args, &block)
        )
      end
      register(name, options[:private])
    end

    # Returns an array of symbols containing all method names defined by node builder methods
    # in your class.
    def nodes
      @nodes ||= []
    end

    # Returns an array of symbols containing all method names defined by node builder methods
    # in your class. Does not list nodes built with option `:private`.
    def public_nodes
      @public_nodes ||= []
    end

  private

    def register(node_name, privateness)
      @nodes ||= []
      @nodes << node_name.to_sym
      @public_nodes ||= []
      @public_nodes << node_name.to_sym unless privateness
    end
  end
end
