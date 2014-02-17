module Quartz
  class JobFactory
    include org.quartz.spi.JobFactory

    def new_job bundle
      bundle.get_job_detail.job
    end
  end
end