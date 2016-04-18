class Factory
  def self.new(*args, &block)
    @@args = args
    if args.empty?
      raise ArgumentError, 'wrong number of arguments (0 for 1+)'
    end

    if args.first.is_a?(String)
      raise NameError, "identifier #{args.first} needs to be constant" unless /^[A-Z]/.match(args.first[0])
    end

    Class.new do
      attr_accessor *args

      def initialize(*attributes)
        @attributes = attributes
        raise ArgumentError, "factory size differs" if attributes.size > @@args.size
        @@args.each_with_index { |value, i| instance_variable_set("@#{@@args[i]}", attributes[i]) }
      end

      def [](arg)
        if arg.kind_of? Fixnum
          instance_variable_get("@#{@@args[arg]}")
        else
          instance_variable_get("@#{arg}")
        end
      end

      def []=(arg, value)
        if arg.kind_of? Fixnum
          instance_variable_set("@#{@@args[arg]}", value)
        else
          instance_variable_set("@#{arg}", value)
        end
      end

      def each
        return to_enum(__method__) unless block_given?
        @attributes.each { |value| yield value }
      end

      def each_pair
        return to_enum(__method__) unless block_given?
        @attributes.each_with_index { |value, i| yield @@args[i], value }
      end

      def eql?(other)
        return false unless other.kind_of? (self.class)
        @attributes.eql?(other)
      end

      def members
        @@args
      end

      def to_s
        str = "#<factory #{self.class} "
        @attributes.each_with_index do |value, i|
          if i == @attributes.length - 1
            str << "#{@@args[i]}=#{value.inspect}>"
          else
            str << "#{@@args[i]}=#{value.inspect}, "
          end
        end
        str
      end

      def values_at

      end

      self.class_eval(&block) if block_given?
    end
  end
end




