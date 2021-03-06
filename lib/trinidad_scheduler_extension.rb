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
        SchedulerLifecycle.setup_listener(context, options)
      end

      class SchedulerLifecycle < Trinidad::Lifecycle::Base

        def self.setup_listener(context, options)
          unless context.find_lifecycle_listeners.find { |l| l.is_a?(self) }
            context.add_lifecycle_listener(self.new(context, options))
          end
        end

        def initialize(context, options)
          servlet_context = context.servlet_context

          # TODO
          $servlet_context = servlet_context unless $servlet_context.is_a?(javax.servlet.ServletContext)

          TrinidadScheduler.store_scheduler_options(servlet_context, options)
          @start_scheduler = nil
        end

        def configure_start(event)
          # NOTE: context.application_listeners setup at this point
          return unless start_scheduler?(event)

          TrinidadScheduler.initialize_configuration!
        end

        def start(event)
          return unless start_scheduler?(event)

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

        private

        def start_scheduler?(event)
          return @start_scheduler unless @start_scheduler.nil?
          context = event.lifecycle
          # NOTE: in "rackup" mode empty no 'org.jruby.rack.RackServletContextListener'
          start = context.findApplicationListeners.length > 0
          start ||= Java::JavaLang::Boolean.getBoolean('trinidad.extensions.scheduler')
          unless @start_scheduler = start
            context.logger.info "Skipped configuration of scheduler extension (due rackup mode)"
          end
          @start_scheduler
        end

      end

    end

    # NOTE: disabled the server extension - since the extensions[:scheduler]
    # hash gets merged into each web-app's configuration (on recent Trinidad).
    # @private
    class SchedulerServerExtension < ServerExtension

      def configure(tomcat)
        return unless ENV['Trindidad::Extensions::SchedulerServerExtension']
        tomcat.host.add_container_listener(ContextListener.new(options))
      end

      class ContextListener
        include Trinidad::Tomcat::ContainerListener

        def initialize(options)
          @options = options || {}
        end

        # @private
        CONTAINER = Trinidad::Tomcat::Container

        def containerEvent(event)
          case event.type # ContainerEvent
          when CONTAINER::ADD_CHILD_EVENT then
            if ( context = event.data ).is_a?(Trinidad::Tomcat::Context)
              SchedulerWebAppExtension::SchedulerLifecycle.setup_listener(context, @options)
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