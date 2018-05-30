# Exact::Logging

Provides convenient logging for apps and gems, including setup and config.

## Installation

Add this line to your application's Gemfile:

    gem 'exact-logging', git: 'https://github.com/fintechdev/exact-logging.git'

And then execute:

    $ bundle

## Usage
Adding logging to your class or app is straightforward. Just include `Exact::Logging`.

```
class MyClass
  include Exact::Logging

  def doing_stuff
    begin
      log_info("starting to do stuff")
      ...
    rescue => e
      log_error("oops, something went wrong", e)
    end
  end
end
```

####
Available logging methods:
* log_debug(msg, exception)
* log_info(msg, exception)
* log_warn(msg, exception)
* log_error(msg, exception)
* log_fatal(msg, exception)
* log_elapsed_time(description, log_level, &block)
  - log the elapsed time while executing the block

## Configuration for Apps
The `Apps::Logger` handles the setup of our default loggers for use within the apps. It depends on `exact-log4r` and configures two loggers, "rails" for the Rails subsystem and a second logger used within the app's code. In all cases the logs are written to a file named `"#{environment}_#{date}.log` in the app's `log` directory, and, in production mode, the logs are additionally written to syslog.

Configuration options:
* `base_dir`: (required) = the root directory of the application, i.e: Rails.root.to_s
* `environment`: the application's running environment (defaults to 'development')
* `logger_name`: the name of the application's logger (defaults to 'rails::steam')
* `message_adjuster`: a module used to adjust the log message immediately before it's written to output (pass the module, not the module name)

Example (placed somewhere in `config/initializers`):
```
require 'exact/logging/apps/logger'

Exact::Logging::Apps::Logger.configure({
  base_dir: Rails.root.to_s,
  environment: Rails.env.to_s,
  logger_name: 'rails::steam',
  message_adjuster: LogMessageAdjuster
})

# Switch the app to our logger
Rails.application.config.logger = Log4r::Logger.get('rails')
```

#### Message Adjusters
The gem allows you to specify a module to use to 'adjust' the log message before it's written to the output. The module will be prepended to the loggers and must have an `adjust(str)` method which returns the adjust string.

```
module MyAdjuster
  def adjust(str)
    str.reverse
  end
end
```

The apps contain `LogMessageAdjuster` which will replace any CC numbers with '[FILTERED]' and will also prepend the request UUID to the log message. 

#### Overriding Logger Configuration
`Log4r` is used to configure the undelying log stream and this gem includes the default configuration used across our apps. However, if you need to override this, or you are running the app in an environment other than `development` or `production`, you can place a `YAML` file containing a `Log4r` configuration in the app's `config` directory and it will be used in preference to the default configs included within the app.

The file must be named as follows: "log4r_\<environment\>.yml", e.g: "log4r_production.yml"

## Configuration for Gems
When developing/debugging/testing gems we want logging, but we do not need the full range of options available with `Log4r` - we just want basic logging to a file provided by `Gem::Logger`. It simply logs to a `log/debug.log` file in the gem's directory.

Configuration options:
* `base_dir`: (required) = the root directory of the gem
* `log_sql_statements`: whether or not to log any ActiveRecord queries executed by the gem (defaults to true)

Example (placed in `test_helper.rb`):
```
require 'exact/logging/gems/logger'

Exact::Logging::Gems::Logger.configure({
  base_dir: File.expand_path('../../',__FILE__)
})
```

Note: when the gem is being used within an app, it will pick up the configured `App::Logger` and its log messages will be included in the app's log output.
