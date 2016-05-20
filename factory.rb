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
        @@args.each_with_index { |value, i| send("#{@@args[i]}=", attributes[i]) }
      end

      def [](arg)
        if arg.kind_of? Fixnum
          send("#{@@args[arg]}")
        else
          send("#{arg}")
        end
      end

      def []=(arg, value)
        if arg.kind_of? Fixnum
          send("#{@@args[arg]}=", value)
        else
          send("#{arg}=", value)
        end
      end

      def each
        return to_enum() unless block_given?
        @attributes.each { |value| yield value }
      end

      def each_pair
        return to_enum() unless block_given?
        @attributes.each_with_index { |value, i| yield @@args[i], value }
      end

      def eql?(other)
        return false unless other.kind_of? (self.class)
        @attributes.eql?(other)
      end

      def members
        @@args
      end

      def to_a(*arg)
        @attributes.to_a(*arg)
      end

      def to_h
          hash = Hash.new
          @@args.each_with_index() do |value, i|
            hash[value] = @attributes[i]
          end
          hash
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

      def values_at(*arg)
        result = []
        return result if arg.length == 0
        arg.each do |i|
          raise IndexError, "offset #{i} too large for struct(size:#{@attributes.size})" if @attributes.size <= i
          result << @attributes[i]
        end
        result
      end

      def length
        members.length
      end

      alias :size :length
      alias :inspect :to_s

      self.class_eval(&block) if block_given?
    end
  end
end