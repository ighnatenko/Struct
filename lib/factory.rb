class Factory
  def self.new(*arguments, &block)
    struct_title = (arguments.first.is_a? String) ? arguments.shift : ''

    new_class = Class.new do
      attr_accessor *arguments

      # initialize
      define_method :initialize do |*args|
        raise ArgumentError if args.size > arguments.size

        arguments.each_with_index do |var, index|
          instance_variable_set "@#{var}", args[index]
        end
      end

      # ==
      def ==(other)
        other.class == self.class && other.values == self.values
      end

      # []
      def [](key)
        key.is_a?(Integer) ? to_a[key] : send(key.to_sym)
      end

      # []=
      def []=(key, value)
        instance_variable_set("@#{key}", value)
      end

      #dig
      def dig(*keys)
        keys.inject(self) do |item, key|
          begin
            item[key]
          rescue NoMethodError
            nil
          end
        end
      end

      #each
      def each
        instance_variables.each do |property|
          yield instance_variable_get property
        end
      end

      #each_pair
      def each_pair
        instance_variables.each do |property|
          yield "#{property}"[1..-1], instance_variable_get(property)
        end
      end

      #eql?
      alias eql? ==

      #length
      def length
        instance_variables.length
      end

      # members
      def members
        instance_variables.map { |a| ("#{a}"[1..-1]).to_sym }
      end

      #select
      def select(&block)
        to_a.select(&block)
      end

      #size
      def size
        self.values.size
      end

      #to_a
      def to_a
        instance_variables.map { |a| instance_variable_get("#{a}") }
      end

      # to_s
      define_method :to_s do
        attributes = arguments.map do |var|
          value = instance_variable_get("@#{var}")
          ":#{var}=" << value.inspect
        end

        "#<factory #{self.class.name} #{attributes.join(', ')}>"
      end

      # values
      def values
        instance_variables.map { |a| instance_variable_get("#{a}") }
      end

      # values_at
      def values_at *indexes
        to_a.values_at(*indexes)
      end

      def greeting
        "Hello #{instance_variable_get("#{instance_variables.first}")}!"
      end

    end

    if struct_title.length != 0
      self.const_set "#{struct_title}", new_class
    end

    new_class

  end
end