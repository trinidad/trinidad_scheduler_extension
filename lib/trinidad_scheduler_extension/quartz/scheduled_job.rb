
module Quartz
  module ScheduledJob

    # @private
    JobError = Quartz::JobError

    def self.included(base)
      base.send :include, org.quartz.Job if base.is_a?(Class)
    end

    def run
      raise NotImplementedError,
        "Implement a [run] method if you are going to use #{self.class} as a job class"
    end

    # @private internal API
    def execute(context)
      set_context(context)
      begin
        run
      rescue Exception => ex
        raise JobError.new(ex)
      end
    end

    private

    def logger
      @_logger ||= begin
        require 'trinidad_scheduler_extension/slf4j/logger'
        logger = Java::OrgSlf4j::LoggerFactory.getLogger(self.class.name)
        # logger.extend Slf4j::Logger unless logger.is_a? Slf4j::Logger
        logger
      end
    end
    alias_method :_logger, :logger

    # @private kind of internal stuff
    def context; @_context end
    alias_method :_context, :context
    # @private kind of internal stuff
    def set_context(context); @_context = context end

  end
end
