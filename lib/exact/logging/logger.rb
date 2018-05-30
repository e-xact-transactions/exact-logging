module Exact
  module Logging
    class Logger

      cattr_accessor :logger

      def self.log(name, msg, exception, options)
        logger.send('log', name, msg, exception, options)
      end

    end

  end
end
