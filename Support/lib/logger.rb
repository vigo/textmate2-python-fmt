require 'logger'

module Logging
  ENABLE_LOGGING = !!ENV["ENABLE_LOGGING"]

  LOG_FILE = "/tmp/textmate-python-fmt.log"
  LOG_PROGNAME = "Python-FMT"
  LOG_LEVEL = Logger::DEBUG
  LOG_DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"

  ROTATION_TIME = 1200 # (20 minutes * 60 seconds = 1200 seconds)

  BLACK            = "\e[30m"
  RED              = "\e[31m"
  RED_BOLD         = "\e[01;31m"
  GREEN            = "\e[32m"
  GREEN_BOLD       = "\e[01;32m"
  YELLOW           = "\e[33m"
  YELLOW_BOLD      = "\e[01;33m"
  BLUE             = "\e[34m"
  BLUE_BOLD        = "\e[01;34m"
  MAGENTA          = "\e[35m"
  MAGENTA_BOLD     = "\e[01;35m"
  CYAN             = "\e[36m"
  CYAN_BOLD        = "\e[01;36m"
  WHITE            = "\e[37m"
  WHITE_BOLD       = "\e[01;37m"
  EXTENDED         = "\e[38m"
  BLINK            = "\e[5m"
  OFF              = "\e[0m"

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  # DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
  def self.severity_color(severity)
    case severity
    when "DEBUG" then BLUE
    when "INFO" then GREEN
    when "WARN" then YELLOW
    when "ERROR" then RED
    when "FATAL" then MAGENTA
    when "UNKNOWN" then BLINK
    end
  end
  

  module ClassMethods
    def logger
      @logger ||= initialize_logger
    end
    
    private

    def initialize_logger
      if ENABLE_LOGGING
        logger = Logger.new(LOG_FILE, 'daily', ROTATION_TIME)

        logger.level = LOG_LEVEL
        logger.progname = LOG_PROGNAME
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        
        logger.formatter = proc do |severity, time, progname, msg|
          color_code = Logging.severity_color(severity)
          caller_info = caller(5).first
          method_name = caller_info.match(/`([^']*)'/) ? caller_info.match(/`([^']*)'/)[1] : "unknown"
          formatted_time = time.strftime(logger.datetime_format)
          file_path = File.basename(caller_info.split(':').first)

          "[#{formatted_time}][#{WHITE_BOLD}#{progname}#{OFF}][#{color_code}#{severity}#{OFF}][#{CYAN_BOLD}#{file_path}->#{method_name}#{OFF}]: #{msg}\n"
        end
      else
        logger = Logger.new(nil)
      end
      logger
    end
  end

  def logger
    self.class.logger
  end
end
