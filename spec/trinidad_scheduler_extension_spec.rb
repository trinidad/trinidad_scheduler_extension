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
        :default => {
          :web_app_dir => MOCK_WEB_APP_DIR,
          :extensions => { :scheduler => { :num_threads => 12 } }
        },
        :unscheduled => {
          :context_path => "/unscheduled",
          :web_app_dir => MOCK_WEB_APP_DIR
        },
        :unscheduled2 => {
          :context_path => "/unscheduled2",
          :web_app_dir => MOCK_WEB_APP_DIR
        }
      }
    })
  end

  let(:web_apps) { server.deploy_web_apps.map(&:web_app) }
  let(:tomcat) { server.deploy_web_apps; server.tomcat }

  let(:default_context) { tomcat.host.find_child("default") }
  let(:unscheduled_context) { tomcat.host.find_child("unscheduled") }
  let(:unscheduled2_context) { tomcat.host.find_child("unscheduled2") }

  let(:default_web_app) { web_apps.find { |app| app.context_path == '/' } }
  let(:unscheduled_web_app) { web_apps.find { |app| app.context_path == '/unscheduled' } }

  subject { Trinidad::Extensions::SchedulerServerExtension.new }

  before(:each) { subject.configure(server.tomcat) }

  it "uses the server extension when configured" do
    # config = { :extensions => { :scheduler => {} } }
    # app = Trinidad::WebApp.create(config, {})
    # app.extensions.should include(:scheduler)
    # app.extensions[:scheduler].should be_empty
    expect( unscheduled_web_app.extensions ).to_not be_empty
    expect( unscheduled_web_app.extensions[:scheduler] ).to be_empty
  end

  it "overrides server extension params when configured by application" do
    expect( default_web_app.extensions ).to_not be_empty
    expect( default_web_app.extensions[:scheduler] ).to_not be_empty
    expect( default_web_app.extensions[:scheduler][:num_threads] ).to eql 12
  end

  it "does not create a scheduler if no scheduling is done on initialization" do
    [ default_context, unscheduled_context, unscheduled2_context ].each do |context|
      TrinidadScheduler.scheduler_exists?(context.servlet_context).should be_false
    end
  end

end