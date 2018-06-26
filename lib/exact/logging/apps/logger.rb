require 'exact/logging/logger'
require 'exact/logging/base_logger'
require 'log4r/yamlconfigurator'

module Exact
  module Logging
    module Apps
      class Logger < BaseLogger

        cattr_reader :logger_name

        def self.configure(options={})
          base_dir = options.fetch(:base_dir)
          environment = options.fetch(:environment, 'development')
          @@logger_name = options.fetch(:logger_name, 'rails:steam')

          cfg = ::Log4r::YamlConfigurator

          custom_file = "#{cfg['Rails.root']}/config/log4r_#{environment}.yml"
          unless File.exist?(custom_file)
            custom_file = File.expand_path(File.dirname(__FILE__) + "/config/log4r_#{environment}.yml")
          end

          erb_file = ERB.new(File.read(custom_file)).result(binding)
          cfg.load_yaml_string(erb_file)

          unless options[:message_adjuster].blank?
            Log4r::Outputter.prepend(options[:message_adjuster])
          end

          Exact::Logging::Logger.class_variable_set("@@logger", Exact::Logging::Apps::Logger)
        end

        def self.log(level, msg, exception, options)
          # no point gathering all the information below if we'll never use it
          return true unless logger.__send__ "#{level}?"

          begin
            message = detailed_message(msg)
            args = [message]
            if options[:log_prefix]
              log_str = "#{options[:log_prefix]}. %s"
            else
              log_str = '%s'
            end

            thread_vars = Thread.current[:__steam_thread_vars__] || {}
            mbatch_vars = Thread.current[:__mbatch_logging_vars__] ||  {}
            thread_vars.merge!(mbatch_vars)

            login = options[:login] || User.current_login

            if login
              args << login
              log_str << ", Login: '%s'"
            end

            ip_address = options[:ip_address] || thread_vars[:user_ip]

            controller = thread_vars[:controller]
            unless controller.nil?
              ip_address ||= controller.request.remote_ip
            end

            unless [nil, "0.0.0.0", "127.0.0.1"].include?(ip_address)
              args << ip_address
              log_str << ", IP: %s "
            end

            unless exception.nil?
              args << detailed_message(exception)
              log_str << ", Exception: %s "
            end

            logger.__send__ level, (log_str % args)

            return true # above returns logger instance, which we don't want.
          rescue Encoding::UndefinedConversionError => e
            $stderr.print "Logging failed: " + e.message + "\n"
          rescue Exception => e
            byebug
            $stderr.print "Logging failed: " + detailed_message(e)
          end
        end

        def self.logger
          @@logger ||= Log4r::Logger.get(@@logger_name)
        end

      end
    end
  end
end