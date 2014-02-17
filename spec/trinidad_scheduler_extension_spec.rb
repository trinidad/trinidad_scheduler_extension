require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Trinidad::Extensions::SchedulerServerExtension do

  before(:all) do # less "deploying" logging from TC :
    logger = Java::JavaUtilLogging::Logger.getLogger 'org.apache.catalina.startup.Tomcat'
    logger.level = Java::JavaUtilLogging::Level::WARNING
  end

  let(:server) do
    Trinidad::Server.new({
      :extensions => { :scheduler => {} },
      :web_apps => {
        :scheduled => {
          :root_dir => MOCK_WEB_APP_DIR,
          :extensions => { :scheduler => { :num_threads => 12 } }
        },
        :default => { :root_dir => MOCK_WEB_APP_DIR },
      }
    })
  end

  let(:web_apps) { server.deploy_web_apps.map(&:web_app) }
  let(:tomcat) { web_apps; server.tomcat }

  let(:default_context) { tomcat.host.find_child("default") }
  let(:scheduled_context) { tomcat.host.find_child("scheduled") }

  let(:default_web_app) { web_apps.find { |app| app.context_path == '/' } }
  let(:scheduled_web_app) { web_apps.find { |app| app.context_path == '/scheduled' } }

  # subject { Trinidad::Extensions::SchedulerServerExtension.new }
  # before(:each) { subject.configure(server.tomcat) }

  it "uses the server extension when configured" do
    # config = { :extensions => { :scheduler => {} } }
    # app = Trinidad::WebApp.create(config, {})
    # app.extensions.should include(:scheduler)
    # app.extensions[:scheduler].should be_empty
    expect( default_web_app.extensions ).to_not be_empty
    expect( default_web_app.extensions[:scheduler] ).to be_empty
  end

  it "overrides server extension params when configured by application" do
    expect( scheduled_web_app.extensions ).to_not be_empty
    expect( scheduled_web_app.extensions[:scheduler] ).to_not be_empty
    expect( scheduled_web_app.extensions[:scheduler][:num_threads] ).to eql 12
  end

  it "does not create a scheduler if no scheduling is done on initialization" do
    [ default_context, scheduled_context ].each do |context|
      TrinidadScheduler.scheduler_exists?(context.servlet_context).should be_false
    end
  end

  it "configured web-app listener" do
    listeners = default_context.find_lifecycle_listeners
    listeners = listeners.find_all { |l| l.is_a?(SchedulerLifecycle) }
    expect( listeners.size ).to eql 1
  end

end


describe Trinidad::Extensions::SchedulerWebAppExtension do

  SchedulerLifecycle = Trinidad::Extensions::SchedulerWebAppExtension::SchedulerLifecycle

  let(:server) do
    Trinidad::Server.new({
      :web_apps => {
        :default => {
          :root_dir => MOCK_WEB_APP_DIR,
          :extensions => { :scheduler => { :num_threads => 2 } }
        },
      }
    })
  end

  let(:tomcat) { server.deploy_web_apps; server.tomcat }

  let(:default_context) { tomcat.host.find_child("default") }

  it "configures web-app listener" do
    listeners = default_context.find_lifecycle_listeners
    listeners = listeners.find_all { |l| l.is_a?(SchedulerLifecycle) }
    expect( listeners.size ).to eql 1
  end

  it "starts and stops context" do
    context = default_context
    servlet_context = context.servlet_context

    TrinidadScheduler.servlet_started?(servlet_context).should be_false

    context.start

    # since we're lazy :
    TrinidadScheduler.scheduler_exists?(servlet_context).should be_false
    TrinidadScheduler.servlet_started?(servlet_context).should be_true

    context.stop

    TrinidadScheduler.scheduler_exists?(servlet_context).should be_false
  end

end