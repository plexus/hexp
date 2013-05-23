module Hexp
  class Array < ::Array
    def self.[](*args)
      super(*normalize(args))
    end

    def self.normalize(args)
      idx = 0
      case args[idx]
      when Symbol
        tag = args[idx] ; idx+=1
        attrs = case args[idx]
                when Hash
                  idx += 1 ; args[idx-1]
                else
                  {}
                end
        children = normalize_children args[idx]
        [tag, attrs, children]
      end
    end

    def self.normalize_children(children)
      case children
      when String
        [ children ]
      when ::Array
        children.map do |child|
          case child
          when String
            child
          when ::Array
            Hexp::Array[*child]
          else
            raise "bad input #{child}"
          end
        end
      else
        []
      end
    end
  end
end
