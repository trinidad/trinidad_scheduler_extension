require 'trinidad'

# Jar files that are needed
require 'trinidad_scheduler_extension/jars'

# Trinidad Scheduler Extension files
require 'trinidad_scheduler_extension/version'

require 'trinidad_scheduler_extension/trinidad_scheduler'
require 'trinidad_scheduler_extension/app_job'

module Trinidad
  module Extensions

    class SchedulerWebAppExtension < WebAppExtension

      def configure(context)
        TrinidadScheduler.initialize_configuration!

        context.add_lifecycle_listener(SchedulerLifecycle.new(context, options))
      end

      class SchedulerLifecycle < Trinidad::Lifecycle::Base

        def initialize(context, options)
          servlet_context = context.servlet_context

          $servlet_context = servlet_context unless $servlet_context.is_a?(javax.servlet.ServletContext)

          TrinidadScheduler.store_scheduler_options(servlet_context, options)
        end

        #def before_start(event)
          #TrinidadScheduler.initialize_configuration!
        #end

        def start(event)
          servlet_context = event.lifecycle.servlet_context

          scheduler = TrinidadScheduler.scheduler(servlet_context)

          if scheduler && ! scheduler.started?
            scheduler.start
            scheduler.resume_all
          end

          TrinidadScheduler.set_servlet_started(servlet_context)
        end

        def stop(event)
          servlet_context = event.lifecycle.servlet_context

          scheduler = TrinidadScheduler.scheduler(servlet_context)

          scheduler.shutdown if scheduler && scheduler.started?
        end

      end

    end

    class SchedulerServerExtension < ServerExtension

      def configure(tomcat)
        TrinidadScheduler.initialize_configuration!

        # TODO this won't work for multiple host configurations ...
        tomcat.host.add_container_listener(ContextListener.new(options))
      end

      class ContextListener
        include Trinidad::Tomcat::ContainerListener

        def initialize(options)
          @options = options
        end

        # @private
        CONTAINER = Trinidad::Tomcat::Container

        def containerEvent(event)
          case event.type # ContainerEvent
          when CONTAINER::ADD_CHILD_EVENT then
            if ( context = event.data ).is_a?(Trinidad::Tomcat::Context)
              lifecycle = SchedulerWebAppExtension::SchedulerLifecycle.new(context, @options)
              context.add_lifecycle_listener(lifecycle)
            end
          end
        end
      end

    end
  end
end

module TrinidadScheduler
  # @deprecated
  WebAppListener = Trinidad::Extensions::SchedulerWebAppExtension::SchedulerLifecycle
  # @deprecated
  GlobalListener = Trinidad::Extensions::SchedulerServerExtension::ContextListener
end