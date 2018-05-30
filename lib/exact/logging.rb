# -*- coding: utf-8 -*-
require "exact/logging/version"

# Provides rudimentary logging within GwLib when running in the standalone mode.
# This is now only in testing mode.

module Exact
  module Logging

    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    private

    module InstanceMethods
      # define methods for log levels
      %W(debug info warn error fatal).each do |name|
        class_eval <<-EOS
          def log_#{name}(msg, exception = nil, options = {})
            Exact::Logging::Logger.log('#{name}', msg, exception, {:log_prefix => Exact::Logging.log_prefix}.merge(options))
          end
          EOS
      end

      def log_elapsed_time(task_title, level = :info, &block)
        start_time = Time.new
        result = yield
        end_time = Time.new
        msg = %{Elapsed time for task "#{task_title}": took #{end_time - start_time} seconds.}
        Exact::Logging::Logger.log(level, msg, nil, :log_prefix => Exact::Logging.log_prefix)
        result
      end

      def url_safe_for_logging(url)
        return "NIL URL!" if url.nil?
        return "BLANK URL!" if url.blank?
        begin
          uri = URI::parse(url)
          "scheme #{uri.scheme.inspect}, host #{uri.host.inspect}, port #{uri.port.inspect}, path length #{uri.path.length rescue "N/A"}, query length #{uri.query.length rescue "N/A"}"
        rescue  
          "Could not parse URL - #{$!.class}" # the $! error may actually include the url itself, which we don't want to log
        end
      end

      end

    class << self
      attr_accessor :log_prefix

      # Create the class methods herein to work correctly.
      # while a class including this module is still being declared.
      def append_features(base)
        super
        base.extend(InstanceMethods)
      end
    end

  end
end
