module TrinidadScheduler
  class WebAppListener
    include org.apache.catalina.LifecycleListener
    
    def initialize(servlet_context, options)
      @servlet_context = servlet_context
      # $servlet_context is set by jruby-rack.
      # If the sheduler jobs are loaded before the web app has been loaded they 
      # fail to initialize because $servlet_context is nil.
      # Also since https://github.com/jruby/jruby-rack/issues/88 with embed 
      # scenarios $servlet_context is set to a RackContext ... workaround :
      $servlet_context = servlet_context unless $servlet_context.is_a?(javax.servlet.ServletContext)
      @options = options
      TrinidadScheduler.store_scheduler_options(@servlet_context, @options)
    end
    
    def needs_started?
      TrinidadScheduler.scheduler_exists?(@servlet_context) && !TrinidadScheduler[@servlet_context].is_started
    end
    
    def is_started?
      TrinidadScheduler.scheduler_exists?(@servlet_context) && TrinidadScheduler[@servlet_context].is_started
    end
    
    def lifecycle_event(event)
      case event.type
      when org.apache.catalina.Lifecycle::START_EVENT then
        if needs_started?
          TrinidadScheduler[@servlet_context].start
          TrinidadScheduler[@servlet_context].resume_all
        end
        
        TrinidadScheduler.set_servlet_started(@servlet_context)
      when org.apache.catalina.Lifecycle::STOP_EVENT then
        TrinidadScheduler[@servlet_context].shutdown if is_started?
      end
    end
  end

  class GlobalListener
    include org.apache.catalina.ContainerListener
    
    def initialize(options)
      @options = options
    end
    
    def container_event(event)
      case event.type
      when org.apache.catalina.Container::ADD_CHILD_EVENT then
        event.data.add_lifecycle_listener(TrinidadScheduler::WebAppListener.new(event.data.servlet_context, @options))
      end
    end
  end
end
