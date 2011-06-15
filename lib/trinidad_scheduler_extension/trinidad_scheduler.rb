module TrinidadScheduler
  CONFIG_HOME = File.expand_path(File.dirname(__FILE__) + "/config")
  JAR_HOME = File.expand_path(File.dirname(__FILE__) + "/jars")
  
  # Sets log4j properties if not established by Application Servers
  # TrinidadScheduler is really lazy so this is only set when a scheduler is needed
  def self.trinidad_scheduler_init_log4j
    if java.lang.System.get_property('log4j.configuration').nil? 
      java.lang.System.set_property('log4j.configuration', java.io.File.new("#{CONFIG_HOME}/log4j.properties").to_url.to_s)
    end
  end 
  
  # Standardizing the naming of the variables that are stored on the context
  def self.context_path(path)
    path.gsub("/", "") == "" ? "Default" : path.gsub("/", "").capitalize
  end
  
  # Assists in lazily evaluating if a scheduler is needed for a context
  # 
  # @param [ServletContext] context
  # @return [Boolean]
  def self.scheduler_exists?(context)
    !!context.get_attribute(scheduler_name(context))
  end
  
  # Tomcat event callbacks are good for static systems but JRuby allows dynamic definition of classes and function
  # so I am storing a variable on the servlet context that allow the extension to check if the servlet has been started
  # during lazy evaluation of the need for a scheduler and/or starting the scheduler
  #
  # @param [ServletContext] context
  # @return [Boolean]
  def self.servlet_started?(context)
    !!context.get_attribute(started_name(context))
  end
  
  # Helper to centralize the operations on the servlet contexts, sets the servlet started variable when the context is started, reguardless of whether
  # a scheduler exists or not
  # 
  # @param [ServletContext] context
  def self.set_servlet_started(context)
    context.set_attribute(started_name(context), true)
  end
  
  # Helper method that attaches the configuration options from the Trinidad config file to the ServletContext
  #
  # @param [ServletContext] context
  # @param [Hash] options
  def self.store_scheduler_options(context, options)
    context.set_attribute(options_name(context), options)
  end

  # Centralized definition of where variables will be stored on the ServletContext
  def self.started_name(context)
    "TrinidadScheduler::#{context_path(context.context_path)}::ServletStarted"
  end
  
  def self.options_name(context)
    "TrinidadScheduler::#{context_path(context.context_path)}::SchedulerOptions"
  end
  
  def self.scheduler_name(context)
    "TrinidadScheduler::#{context_path(context.context_path)}::Scheduler"
  end
  
  # Bracket accessor defined to retreive the scheduler for a context
  # if no scheduler is attached to the context then one is created and attached at time of access and returned
  # 
  # @param [ServletContext] context
  # @return [org.quartz.impl.StdScheduler]
  def self.[](context)
    if !scheduler_exists?(context)
      self.trinidad_scheduler_init_log4j
      self[context] = self.quartz_scheduler(context, context.get_attribute(options_name(context)))
    end
    
    scheduler = context.get_attribute(scheduler_name(context)) 
    
    if !scheduler.is_started && servlet_started?(context)
      scheduler.start
      scheduler.resume_all
    end
    
    return scheduler
  end
  
  # Bracket assignment operator, will attach the scheduler passed to the context in the brackets
  #
  # @param [ServletContext] context
  # @param [org.quartz.impl.StdScheduler] scheduler
  def self.[]=(context, scheduler)
    context.set_attribute(scheduler_name(context), scheduler)
  end 
  
  # Method to build and return Quartz schedulers
  #
  # @param [ServletContext] context
  # @param [Hash] opts, the options to configure the scheduler with 
  def self.quartz_scheduler(context, opts={})
    options = {:wrapped => false, :thread_count => 10, :thread_priority => 5}
    options.merge!(opts)
    options[:name] = context_path(context.context_path)
    
    scheduler_factory = org.quartz.impl.StdSchedulerFactory.new
    scheduler_factory.initialize(quartz_properties(options))
    scheduler = scheduler_factory.get_scheduler
    scheduler.set_job_factory(TrinidadScheduler::JobFactory.new)
    scheduler.pause_all
    return scheduler
  end
  
  # Properties stream for initializing a scheduler
  # Currently restricts schedulers to RAMJobStore and SimpleThreadPool
  def self.quartz_properties(opts={})
    prop_string = java.lang.String.new("
      org.quartz.scheduler.rmi.export = false
      org.quartz.scheduler.rmi.proxy = false
      org.quartz.scheduler.wrapJobExecutionInUserTransaction = #{opts[:wrapped]}
      org.quartz.threadPool.class = org.quartz.simpl.SimpleThreadPool
      org.quartz.threadPool.threadCount = #{opts[:thread_count]}
      org.quartz.threadPool.threadPriority = #{opts[:thread_priority]}
      org.quartz.threadPool.threadNamePrefix = WorkerThread::#{opts[:name]}
      org.quartz.threadPool.threadsInheritContextClassLoaderOfInitializingThread = true
      org.quartz.jobStore.misfireThreshold = 60000
      org.quartz.jobStore.class = org.quartz.simpl.RAMJobStore")
    
    qp = java.util.Properties.new 
    qp.load(java.io.ByteArrayInputStream.new(prop_string.getBytes()))
    qp.set_property("org.quartz.scheduler.instanceName", "Quartz::#{opts[:name]}::Application")
    return qp
  end
end
