module TrinidadScheduler 
  class JobDetail < org.quartz.JobDetail
    
    attr_accessor :job
    
    def initialize(name, group, job_class)
      super()
      set_name name
      set_group group
      @job = job_class.new
    end
    
    def isStateful()
      @job.is_a?(org.quartz.StatefulJob)
    end

    def validate()
      raise org.quartz.SchedulerException.new("Job's name cannot be null",
        org.quartz.SchedulerException.ERR_CLIENT_ERROR) if get_name == nil
      raise org.quartz.SchedulerException.new("Job's group cannot be null",
        org.quartz.SchedulerException.ERR_CLIENT_ERROR) if get_group == nil  
    end  
  end
end
