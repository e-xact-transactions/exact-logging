module Exact
  module Logging
    class Logger

      def self.log(name, msg, exception, options)
        @@logger.send('log', name, msg, exception, options)
      end

    end

  end
end
