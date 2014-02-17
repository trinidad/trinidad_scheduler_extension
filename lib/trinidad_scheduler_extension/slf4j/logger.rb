# require 'logger'
# Ruby Logger compatible API
module Slf4j
  module Logger

    def trace(msg = nil); block_given? ? super(yield) : super(msg) end

    def debug(msg = nil); block_given? ? super(yield) : super(msg) end
    def info(msg = nil);  block_given? ? super(yield) : super(msg) end
    def warn(msg = nil);  block_given? ? super(yield) : super(msg) end
    def error(msg = nil); block_given? ? super(yield) : super(msg) end

    def trace?; isTraceEnabled end

    def debug?; isDebugEnabled end
    def info?;  isInfoEnabled  end
    def warn?;  isWarnEnabled  end
    def error?; isErrorEnabled end

    alias_method :fatal, :error
    alias_method :fatal?, :error?

    alias_method :unknown, :error

    def add(severity, msg = nil, prog = nil, &block)
      severity ||= 3 # unknown
      return error(msg, &block) if severity >= 3
      return warn(msg, &block)  if severity == 2
      return info(msg, &block)  if severity == 1
      return debug(msg, &block) if severity == 0
      trace(msg, &block)
    end

    # Message should be logged without any formatting, but since
    # we can not do that we simply log at the info level.
    def <<(msg); info(msg) end

    def level
      return 0 if trace_enabled? || debug_enabled?
      return 1 if info_enabled?
      return 2 if warn_enabled?
      return 3 if error_enabled?
      3 # #fatal, #unknown are #error level
    end
    # @private not supported
    def level=(level); self.level end

    # @private not supported
    def datetime_format; nil end
    # @private not supported
    def datetime_format=(format); self.datetime_format end

    # @private do nothing on close
    def close; end

  end
end