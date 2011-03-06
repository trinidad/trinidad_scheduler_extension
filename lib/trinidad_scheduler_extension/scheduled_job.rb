module TrinidadScheduler
  module ScheduledJob
    class JobError < StandardError; end
    
    attr_accessor :_context
    attr_accessor :_logger
    
    def run
      raise "Implement a [run] method if you are going to use #{self.class} as a job class"
    end  
      
    def execute(context)
      begin 
        @_context = context
        @_logger = org.apache.log4j.Logger.getLogger("#{self.class}")
        run()
      rescue Exception => ex
        raise JobError.new(ex)
      end
    end
  end
end
