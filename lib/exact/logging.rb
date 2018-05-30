# -*- coding: utf-8 -*-

require "exact/logging/version"
require 'logger'

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
            Exact::Logging.log('#{name}',msg,exception,options)
          end
          EOS
      end
    end

    class << self
      attr_accessor :log_dir_path

      def log(name, msg, exception, options)
        msg << " Exception: " << detailed_message(exception) unless exception.nil?
        logger.send(name.to_sym, msg)
      end

      private

      def logger
        @@logger ||= initialise_logger
      end

      # initialize the logger when it's first used
      # we do it here so it's not initialised when we first require
      # the module from within a Rails project, as we'll be pulling
      # a sleight-of-hand and substituting Rails's logger
      def initialise_logger
        unless defined?(@@logger)
          raise ArgumentError.new('Exact::Logging.log_dir_path has not been set.') if log_dir_path.to_s.gsub(/\s/,'').empty?
          Dir.mkdir(log_dir_path) unless Dir.exist?(log_dir_path)
          @@logger = Logger.new(log_dir_path+"/debug.log")
          @@logger.level = Logger::DEBUG
          @@logger.datetime_format = "%H:%M:%S"
          @@logger.info("Exact::Logging: using Ruby logger to file 'debug.log'.")
          # ensure we log any DB calls too
          ActiveRecord::Base.logger = @@logger if defined?(ActiveRecord)
          @@logger
        end
        @@logger
      end

      # Create the detailed message for the argument o. If the argument
      # is exception, the message containing the message and the backtrace
      # is returned. Otherwise, simply the to_s is invoked on the object.
      def detailed_message(o)
        case
        when o.kind_of?(Exception)
          backtrace = ''
          unless o.backtrace.empty?
            backtrace = o.backtrace.join("\n    ") +"\n\n"
          end
          "#{o.class} (#{o.message}):\n    " + backtrace
        else
          o.to_s
        end
      end

      # Create the class methods herein to work correctly.
      # while a class including this module is still being declared.
      def append_features(base)
        super
        base.extend(InstanceMethods)
      end
    end

  end
end
