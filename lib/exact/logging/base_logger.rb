require 'logger'

module Exact
  module Logging
    class BaseLogger

      # Create the detailed message for the argument o. If the argument
      # is exception, the message containing the message and the backtrace
      # is returned. Otherwise, simply the to_s is invoked on the object.
      def self.detailed_message(o)
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

    end
  end
end
