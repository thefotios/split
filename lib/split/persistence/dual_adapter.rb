# frozen_string_literal: true

module Split
  module Persistence
    class DualAdapter
      def self.with_config(options={})
        self.config.merge!(options)
        self
      end

      def self.config
        @config ||= {}
      end

      def initialize(context)
        if logged_in = self.class.config[:logged_in]
        else
          raise "Please configure :logged_in"
        end
        if logged_in_adapter = self.class.config[:logged_in_adapter]
        else
          raise "Please configure :logged_in_adapter"
        end
        if logged_out_adapter = self.class.config[:logged_out_adapter]
        else
          raise "Please configure :logged_out_adapter"
        end

        @logged_in = logged_in.call(context)
        @logged_in_adapter = logged_in_adapter.new(context)
        @logged_out_adapter = logged_out_adapter.new(context)
      end

      def keys
        (@logged_in_adapter.keys + @logged_out_adapter.keys).uniq
      end

      def [](key)
        @logged_in && @logged_in_adapter[key] || @logged_out_adapter[key]
      end

      def []=(key, value)
        @logged_in_adapter[key] = value if @logged_in
        @logged_out_adapter[key] = value
      end

      def delete(key)
        @logged_in_adapter.delete(key)
        @logged_out_adapter.delete(key)
      end
    end
  end
end
