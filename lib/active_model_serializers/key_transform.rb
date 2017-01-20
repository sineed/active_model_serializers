require 'active_support/core_ext/hash/keys'

module ActiveModelSerializers
  class KeyTransform
    class << self
      def key_cache
        @key_cache ||= KeyCache.new
      end

      # Transforms values to UpperCamelCase or PascalCase.
      #
      # @example:
      #    "some_key" => "SomeKey",
      # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L66-L76 ActiveSupport::Inflector.camelize}
      def camel(value)
        case value
        when Hash then value.deep_transform_keys! { |key| camel(key) }
        when Symbol then key_cache.fetch(value, :camel) { value.to_s.underscore.camelize }.to_sym
        when String then key_cache.fetch(value, :camel) { value.underscore.camelize }
        else value
        end
      end

      # Transforms values to camelCase.
      #
      # @example:
      #    "some_key" => "someKey",
      # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L66-L76 ActiveSupport::Inflector.camelize}
      def camel_lower(value)
        case value
        when Hash then value.deep_transform_keys! { |key| camel_lower(key) }
        when Symbol then key_cache.fetch(value, :camel_lower) { value.to_s.underscore.camelize(:lower) }.to_sym
        when String then key_cache.fetch(value, :camel_lower) { value.underscore.camelize(:lower) }
        else value
        end
      end

      # Transforms values to dashed-case.
      # This is the default case for the JsonApi adapter.
      #
      # @example:
      #    "some_key" => "some-key",
      # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L185-L187 ActiveSupport::Inflector.dasherize}
      def dash(value)
        case value
        when Hash then value.deep_transform_keys! { |key| dash(key) }
        when Symbol then key_cache.fetch(value, :dash) { value.to_s.underscore.dasherize }.to_sym
        when String then key_cache.fetch(value, :dash) { value.underscore.dasherize }
        else value
        end
      end

      # Transforms values to underscore_case.
      # This is the default case for deserialization in the JsonApi adapter.
      #
      # @example:
      #    "some-key" => "some_key",
      # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L89-L98 ActiveSupport::Inflector.underscore}
      def underscore(value)
        case value
        when Hash then value.deep_transform_keys! { |key| underscore(key) }
        when Symbol then key_cache.fetch(value, :underscore) { value.to_s.underscore }.to_sym
        when String then key_cache.fetch(value, :underscore) { value.underscore }
        # when Symbol then value.to_s.underscore.to_sym
        # when String then value.underscore
        else value
        end
      end

      def old_underscore(value)
        case value
        when Hash then value.deep_transform_keys! { |key| underscore(key) }
        when Symbol then value.to_s.underscore.to_sym
        when String then value.underscore
        else value
        end
      end

      # Returns the value unaltered
      def unaltered(value)
        value
      end
    end
  end

  class KeyCache
    def initialize(hash = {})
      @hash = hash
    end

    def fetch(key, transform_type)
      key = key.to_sym
      hash[key] ||= {}
      hash[key][transform_type] = yield unless hash[key][transform_type]
      hash[key][transform_type]
    end

    def to_h
      hash
    end

  private

    attr_reader :hash

  end
end
