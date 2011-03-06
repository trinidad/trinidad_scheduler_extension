module TrinidadScheduler  
  module AppJob
    include org.quartz.Job    
    include TrinidadScheduler::ScheduledJob 
    
    def self.included(other_obj)
      new_job = TrinidadScheduler::JobDetail.new("#{ other_obj.job_detail_name rescue other_obj }", "#{other_obj}", other_obj)
      begin 
        TrinidadScheduler[$servlet_context].schedule_job(new_job, other_obj.trigger)
      rescue Exception => ex
        raise JobError.new(ex)
      end
    end
  end
  
  # Method to schedule a block of code to run in another Thread after execution proceeds in the current Thread
  # after the job runs it removes itself from the job scheduler 
  #
  # @example Running run_later with default 3 second delay
  #   TrinidadScheduler.run_later do
  #     _logger.info "I am inside this block" #=> prints "I am inside this block" 
  #   end
  #
  # @example Running run_later with 20 second delay
  #   TrinidadScheduler.run_later(:delay => 20) do
  #     _logger.info "I am inside this block" #=> prints "I am inside this block" 
  #   end  
  #
  # @param [Hash] opts the options for the process to be run
  # @option opts [Integer] :delay the number of seconds delay before the block is triggered
  # @param [Block] the block that will be run in a separate Thread after the delay
  def self.run_later(opts={:delay=>3}, &blk)
    Class.new(TrinidadScheduler.Simple :start => (Time.now + opts[:delay])) do 
      meta_def(:job_detail_name){ Time.now.to_i.to_s << Time.now.usec.to_s }
      meta_def(:run_proc){ blk }
      
      def run
        self.class.run_proc.call
      end  
    end
  end
  
  # Method to return an inheritable class for scheduling a CronTrigger Job 
  # the class that inherits from this method will have it's instance run method executed based on the cron_expression
  #
  # @example Schedule an INFO log message every 5 seconds
  #   class TestJob < TrinidadScheduler.Cron "0/5 * * * * ?"
  #     def run
  #       _logger.info "I am inside this block" #=> prints "I am inside this block" every 5 seconds
  #     end
  #   end
  #
  # @param [String] cron_expression the Cron Expression that defines the CronTrigger for the job class   
  # @return [Class] a new Class that is run by the CronTrigger that is defined
  def self.Cron(cron_expression)
    Class.new do
      meta_def(:cron){ cron_expression }
      
      def self.inherited(subclass) 
        meta_def :trigger do
          org.quartz.CronTrigger.new("#{subclass}" + ".trigger", "#{subclass}", self.cron)
        end

        subclass.send(:include, TrinidadScheduler::AppJob)
      end
    end  
  end
  
  # Method to return an inheritable class for scheduling a SimpleTrigger Job 
  # the class that inherits from this method will have it's instance run method executed based on the options passed
  #
  # @example Schedule an INFO log message every 5 seconds starting now, setting the end is not necessary in this context, but it done
  #   class TestJob < TrinidadScheduler.Simple :start => Time.now, :end => Time.now + 240, :repeat 3, :interval => 5000
  #     def run
  #       _logger.info "I am inside this block" #=> prints "I am inside this block" every 5 seconds
  #     end
  #   end
  #
  # @param [Hash] opts the options for the SimpleTrigger
  # @option opts [java.util.Date, Time] :start the starting time of the trigger
  # @option opts [java.util.Date, Time] :end the ending time of the trigger
  # @option opts [Integer] :repeat the number of times to repeat the job (defaults to 0)
  # @option opts [Integer] :interval the number of milliseconds between runs
  # @return [Class] a new anonymous Class that is the parent of the Class run by the SimpleTrigger that is defined
  def self.Simple(opts={})    
    opts[:start] ||= java.util.Date.new(Time.now.to_i*1000)
    opts[:start] = java.util.Date.new(opts[:start].to_i*1000) if opts[:start].class == Time
    
    opts[:end] ||= java.util.Date.new((Time.now + 10.years).to_i*1000)
    opts[:end] = java.util.Date.new(opts[:end].to_i*1000) if opts[:end].class == Time
    
    opts[:repeat] ||= 0
    opts[:interval] ||= 0
    
    Class.new do
      meta_def(:opts){ opts }

      def self.inherited(subclass)
        meta_def :trigger do
          org.quartz.SimpleTrigger.new("#{subclass}" + ".trigger", "#{subclass}", 
                                       self.opts[:start], self.opts[:end], 
                                       self.opts[:repeat], self.opts[:interval])
        end 
        
        subclass.send(:include, TrinidadScheduler::AppJob)
      end
    end  
  end
  
  # Method to return an inheritable class for scheduling a DateIntervalTrigger Job 
  # the class that inherits from this method will have it's instance run method executed based on the options passed
  #
  # @example Schedule an INFO log message every 5 seconds starting now and ending after 4 minutes
  #   class TestJob < TrinidadScheduler.DateInterval :start => Time.now, :end => Time.now + 240, :unit => :second, :interval => 5
  #     def run
  #       _logger.info "I am inside this block" #=> prints "I am inside this block" every 5 seconds
  #     end
  #   end
  #
  # @param [Hash] opts the options for the DateIntervalTrigger
  # @option opts [java.util.Date, Time] :start the starting time of the trigger
  # @option opts [java.util.Date, Time] :end the ending time of the trigger
  # @option opts [Symbol, String] :unit the defined unit (:day, :second, :year, :month, :week)
  # @option opts [Integer] :interval the number of units between runs
  # @return [Class] a new anonymous Class that is the parent of the Class run by the SimpleTrigger that is defined
  def self.DateInterval(opts={})    
    opts[:start] ||= java.util.Date.new(Time.now.to_i*1000)
    opts[:start] = java.util.Date.new(opts[:start].to_i*1000) if opts[:start].class == Time
    
    opts[:end] ||= java.util.Date.new((Time.now + 10.years).to_i*1000)
    opts[:end] = java.util.Date.new(opts[:end].to_i*1000) if opts[:end].class == Time
    
    opts[:unit] ||= :day
    opts[:unit] = org.quartz.DateIntervalTrigger::IntervalUnit.value_of(opts[:unit].to_s.upcase)

    opts[:interval] ||= 1
    
    Class.new do
      meta_def(:opts){ opts }

      def self.inherited(subclass) 
        meta_def :trigger do
          org.quartz.DateIntervalTrigger.new("#{subclass}" + ".trigger", "#{subclass}", 
                                             self.opts[:start], self.opts[:end], 
                                             self.opts[:unit], self.opts[:interval])        
        end
        
        subclass.send(:include, TrinidadScheduler::AppJob)
      end
    end  
  end
end
