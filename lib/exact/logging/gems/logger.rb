require 'logger'
require 'exact/logging/logger'
require 'exact/logging/base_logger'

module Exact
  module Logging
    module Gems
      class Logger < BaseLogger

        def self.configure(options={})
          gem_directory = options.fetch(:base_dir)
          log_sql_statements = options.fetch(:log_sql_statements, true)

          log_dir_path = "#{gem_directory}/log"
          Dir.mkdir(log_dir_path) unless Dir.exist?(log_dir_path)
          @@logger = ::Logger.new(log_dir_path+"/debug.log")
          @@logger.level = ::Logger::DEBUG
          @@logger.formatter = proc {|severity, datetime, progname, msg| datetime.strftime("%F %T") + " #{severity}: #{msg}\n"}
          @@logger.info("Exact::Logging: using Ruby logger to file 'debug.log'.")
          # ensure we log any DB calls too
          if log_sql_statements
            ActiveRecord::Base.logger = @@logger if defined?(ActiveRecord)
          end
          Exact::Logging::Logger.class_variable_set("@@logger", Exact::Logging::Gems::Logger)
        end

        def self.log(level, msg, exception, options)
          msg << " Exception: " << detailed_message(exception) unless exception.nil?
          @@logger.send(level.to_sym, msg)
        end

      end
    end
  end
end