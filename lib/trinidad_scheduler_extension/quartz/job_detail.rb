module Quartz
  class JobDetail < org.quartz.JobDetail

    attr_reader :job

    def initialize(name, group, job_class)
      super()
      set_name name
      set_group group
      @job = job_class.new
    end

    def validate
      raise org.quartz.SchedulerException.new("Job's name cannot be null",
        org.quartz.SchedulerException.ERR_CLIENT_ERROR) unless name
      raise org.quartz.SchedulerException.new("Job's group cannot be null",
        org.quartz.SchedulerException.ERR_CLIENT_ERROR) unless group
    end

    # @deprecated
    def job=(job); @job = job end

  end
end