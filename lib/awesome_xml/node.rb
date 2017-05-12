# frozen_string_literal: true

module AwesomeXML
  module Node
    def to_hash
      Hash[self.class.nodes.map { |node| [node, public_send(node)] }]
    end

  private

    def evaluate_node(xpath, type = :string, &block)
      if block_given?
        yield(evaluate_node_blockless(xpath, type), self)
      else
        evaluate_node_blockless(xpath, type)
      end
    end

    def evaluate_node_blockless(xpath, type)
      self.class.parse_type(find_node(xpath)&.text, type)
    end

    def evaluate_nodes(xpath, type = :string, &block)
      if block_given?
        yield(evaluate_nodes_blockless(xpath, type), self)
      else
        evaluate_nodes_blockless(xpath, type)
      end
    end

    def evaluate_nodes_blockless(xpath, type = :string)
      find_nodes(xpath)&.map { |node| self.class.parse_type(node&.text, type) }
    end

    def find_node(xpath)
      xml.at_xpath(xpath)
    end

    def find_nodes(xpath)
      xml.xpath(xpath)
    end

    def evaluate_child_node(node_class_name, node, &block)
      if block_given?
        yield(evaluate_child_node_blockless(node_class_name, node), self)
      else
        evaluate_child_node_blockless(node_class_name, node)
      end
    end

    def evaluate_child_node_blockless(node_class_name, node)
      [self.class.name, node_class_name].join('::').constantize.new(node, self).to_hash
    end

    def evaluate_child_nodes(node_class_name, xpath, &block)
      if block_given?
        yield(evaluate_child_nodes_blockless(node_class_name, xpath), self)
      else
        evaluate_child_nodes_blockless(node_class_name, xpath)
      end
    end

    def evaluate_child_nodes_blockless(node_class_name, xpath)
      find_nodes(xpath).map do |new_current_node|
        evaluate_child_node_blockless(node_class_name, new_current_node)
      end
    end

    def xml
      data
    end
  end
end
