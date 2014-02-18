
module Quartz
  class JobError < StandardError

    unless method_defined?(:cause)

      attr_reader :cause

      def initialize(arg = nil)
        @cause = arg.is_a?(Exception) ? arg : nil
        super(@cause ? @cause.message : arg)
      end

    end

  end
end
