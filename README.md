Trinidad Scheduler Extension
=========
Trinidad Scheduler uses Quartz to schedule processes for execution.  It can be run as a server extension to Trinidad and/or a Web Application extension
for Trinidad.  If run as a Server extension all schedulers will get the server configuration options each option that is defined at the Web Application
level will override the Server option.  

Trinidad Scheduler creates a unique scheduler for each web application.

Most processes we schedule are scheduled using the *Cron* Trigger and *run_later*

Install Gem
---------
    gem install trinidad_scheduler_extension
    
Configure Trinidad
---------
In either the Server *extensions* block or the Web Application *extentions* block add "scheduler"

    extensions:
      scheduler:

Example Usage
---------
It is valid to use the top level scheduling methods and run_later together

    class ScheduledLog < TrinidadScheduler.Cron "0/5 * * * * ?"
      def run
        _logger.info "Executed every 5 seconds"
        
        TrinidadScheduler.run_later do 
          _logger.info "Executed after a 3 second delay"
        end
      end
    end

Laziness
---------
Trinidad Scheduler is very lazy.  Schedulers will only be instantiated when they are needed to execute a job or to setup a schedule for execution.
This laziness extends to even runtime definition of classes and use of run_later in conditional statements.  When a run_later block is encountered or
a class is defined at runtime that inherits from a TrinidadScheduler base method the scheduler will be created and started (if it does not exist)

If schedules are defined during application initialization then the scheduler will not be started until after the application is started by Tomcat.

(The lazy nature of TrinidadScheduler also gives the user time to define a logger outstide of the default configured log4j StdOut logger that 
is included with TrinidadScheduler)

Usage
=========
The extension defines several methods that return classes based on the configuration options provided.  These methods map to the scheduler trigger type
that Quartz provides.  The implemented triggers are CronTrigger, SimpleTrigger, and DateIntervalTrigger. 

Cron Trigger
---------
To define a process to be run based on a [cron expression](http://en.wikipedia.org/wiki/CRON_expression#CRON_expression)

    class ScheduledClass < TrinidadScheduler.Cron "0/5 * * * * ?"
      def run
        _logger.info "I am printed every 5 seconds"
      end
    end

The method *TrinidadScheduler.Cron* takes a cron expression as it's only argument and returns a class.  This anonymous class is the parent of
ScheduledClass and does the work to wrap ScheduledClass for use as a CronTrigger in Quartz.

The instance method "run" must be defined because it is called when the scheduled process is triggered.  *_logger* is an instance variable available
in ScheduledClass which gives the class access to the Quartz logger that is configured.   

Simple Trigger
---------
Schedule an INFO log message every 5 seconds starting now, setting the end is not necessary in this context, but is done
    
    class TestJob < TrinidadScheduler.Simple :start => Time.now, :end => Time.now + 240, :repeat 3, :interval => 5000
      def run
        _logger.info "I am inside this block" #=> prints "I am inside this block" every 5 seconds
      end
    end

The Simple Trigger will execute based on options passed to the method *TrinidadScheduler.Simple*, the options available are outlined
above in the example, none of them are necessary if you only want to trigger the process once.   You can define a start and end time as well as how many
times to fire the trigger along with an interval to be observed between trigger execution.

DateInterval Trigger
---------
Schedule an INFO log message every 5 seconds starting now and ending after 4 minutes
    
    class TestJob < TrinidadScheduler.DateInterval :start => Time.now, :end => Time.now + 240, :unit => :second, :interval => 5
      def run
        _logger.info "I am inside this block" #=> prints "I am inside this block" every 5 seconds
      end
    end

The DateInterval Trigger will execute a triggered process based on the configuration options passed.  For more information on using the DateInterval
trigger consult the source. 

run_later
---------
Schedules a block of code to run in another Thread after execution proceeds in the current Thread
*after the job runs it removes itself from the job scheduler 

Using run_later with default 3 second delay

    TrinidadScheduler.run_later do
      _logger.info "I am inside this block" #=> prints "I am inside this block" 
    end
  
Using run_later with 20 second delay

    TrinidadScheduler.run_later(:delay => 20) do
      _logger.info "I am inside this block" #=> prints "I am inside this block" 
    end 
    
Behind the scenes *run_later* is actually implemented using an anonymous class that inherits from TrinidadScheduler.Simple to schedule the run.


Inspiration
---------
Open Source software is a community effort - thanks to all, but the following were instrumental in the inspiration for TrinidadScheduler.

[techwhizbang](https://github.com/techwhizbang/jruby-quartz) for handling of Quartz JobFactory

[why_metaid](https://github.com/evaryont/why_metaid) for metaid extension

[TERRACOTTA](http://www.terracotta.org/) for continued support of Quartz Scheduler

[calavera](https://github.com/calavera/trinidad) for Trinidad Server

Copyright
---------
Copyright (c) 2011 Brandon Dewitt <brandon+trinidad_scheduler "at" myjibe.com>. See LICENSE for details.    
