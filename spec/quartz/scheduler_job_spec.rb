require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'trinidad_scheduler_extension/quartz/scheduled_job'

ScheduledJob = TrinidadScheduler::ScheduledJob

describe ScheduledJob do

  class JobImpl
    include ScheduledJob

    def run
      [ _logger, _context ]
    end
  end

  it "is a quartz job" do
    expect( JobImpl.new ).to be_a org.quartz.Job
  end

  it "supports _logger and _context API" do
    job = JobImpl.new
    result = job.execute context = mock('context')

    expect( result[0] ).to respond_to :debug
    expect( result[1] ).to be context
  end

  JobError = ScheduledJob::JobError

  it "wraps exceptions into a job-error" do
    job = JobImpl.new
    def job.run; raise '42' end
    begin
      result = job.execute mock('context')
    rescue JobError => e
      expect( e.message ).to include('42')
      expect( e.cause ).to be_a RuntimeError
    else
      fail 'job-error not raised'
    end
  end

#  it "returns a logger.rb-like logger" do
#    logger = JobImpl.new.send :logger
#    logger.debug?
#    logger.debug java.lang.RuntimeException.new('debug')
#    logger.info?
#    logger.info { 'info_message' }
#    logger.warn?
#    logger.warn :warn_message
#    logger.error?
#    logger.error 'error_message'
#  end

end