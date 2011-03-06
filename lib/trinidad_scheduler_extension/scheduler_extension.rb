module Trinidad  
  module Extensions
    
    class SchedulerWebAppExtension < WebAppExtension
      
      def configure(tomcat, app_context)
        app_context.add_lifecycle_listener(TrinidadScheduler::WebAppListener.new(app_context.servlet_context, @options))
      end
    end
    
    class SchedulerServerExtension < ServerExtension
      
      def configure(tomcat)
        tomcat.get_host.add_container_listener(TrinidadScheduler::GlobalListener.new(@options))
      end
    end
  end
end    
