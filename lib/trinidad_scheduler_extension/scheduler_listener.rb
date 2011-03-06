module TrinidadScheduler
  class WebAppListener
    include org.apache.catalina.LifecycleListener
    
    def initialize(servlet_context, options)
      @servlet_context = servlet_context
      @options = options         
      TrinidadScheduler.store_scheduler_options(@servlet_context, @options)
    end
    
    def needs_started?
      TrinidadScheduler.scheduler_exists?(@servlet_context) && !TrinidadScheduler[@servlet_context].is_started
    end
    
    def lifecycle_event(event)
      case event.type
      when org.apache.catalina.Lifecycle::START_EVENT then
        if needs_started?
          TrinidadScheduler[@servlet_context].start
          TrinidadScheduler[@servlet_context].resume_all
        end
        
        TrinidadScheduler.set_servlet_started(@servlet_context)
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
