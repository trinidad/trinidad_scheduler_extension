describe "Trinidad Scheduler Server Extension" do
  before(:all) do 
    @options = {}
    @server = Trinidad::Server.new({
      :web_apps => {
        :default => {
          :web_app_dir => MOCK_WEB_APP_DIR
        },
        :unscheduled => {
          :context_path => "/unscheduled",
          :web_app_dir => MOCK_WEB_APP_DIR
        },
        :mock3 => {
          :context_path => "/unscheduled2",
          :web_app_dir => MOCK_WEB_APP_DIR
        }        
      }
    })

    @tomcat = @server.tomcat
    @default = @tomcat.host.find_child("")
    @unscheduled = @tomcat.host.find_child("/unscheduled")
    @unscheduled2 = @tomcat.host.find_child("/unscheduled2")
  end
  
  subject { Trinidad::Extensions::SchedulerServerExtension.new(@options)}

  before(:each) do 
    subject.configure(@tomcat)
  end

  it "uses the server extension when configured" do 
    config = {:extensions => {:scheduler => {}}}
    app = Trinidad::WebApp.create(config, {})
    app.extensions.should include(:scheduler)
    app.extensions[:scheduler].should_not include(:num_threads)
  end
  
  it "overrides server extension params when configured by application" do
    config = {:extensions => {:scheduler => {}}}
    app_config = {:extensions => {:scheduler => {:num_threads => 12}}}
    app = Trinidad::WebApp.create(config, app_config)
    app.extensions.should include(:scheduler)
    app.extensions[:scheduler].should include(:num_threads)
  end
  
  it "does not create a scheduler if no scheduling is done on initialization" do 
    TrinidadScheduler.scheduler_exists?(@default.servlet_context).should be_false
    TrinidadScheduler.scheduler_exists?(@unscheduled.servlet_context).should be_false    
    TrinidadScheduler.scheduler_exists?(@unscheduled2.servlet_context).should be_false
  end
end
