module Hexp
  class MutableTreeWalk
    attr_reader :root, :path, :result

    def initialize(root)
      @root = root
      @path = [root]
      @replacements = [{}]
      @result = nil
    end

    def next!
      return if end?
      if current.children.any?
        @path << current.children.first
        @replacements << {}
      elsif @path.length == 1
        @result = @path.pop
      else
        backtrack_and_right!
      end
    end

    def backtrack_and_right!
      while at_rightmost_child?
        @path.pop
        handle_replacements!
        if @path.length == 1 #back at start, we're done
          @result = @path.pop
          return
        end
      end
      go_right!
    end

    def replace!(val)
      @replacements.last[current_idx] = val
    end

    def handle_replacements!
      replacements = @replacements.pop
      return if replacements.empty?
      new_children = [*current.children]
      replacements.each do |idx, val|
        new_children[idx..idx] = val
      end
      new_node = current.set_children(new_children)
      if @path.length == 1
        @path = [new_node]
      else
        @replacements.last[current_idx] = new_node
      end
    end

    def at_rightmost_child?
      current.equal? parent.children.last
    end

    def go_right!
      @path[-1] = parent.children[current_idx + 1]
    end

    def current_idx
      parent.children.find_index { |ch| current.equal?(ch) }
    end

    def parent
      @path[-2]
    end

    def current
      @path.last
    end

    def end?
      @path.empty?
    end
  end
end
