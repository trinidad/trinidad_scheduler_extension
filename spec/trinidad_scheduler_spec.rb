require File.expand_path('spec_helper', File.dirname(__FILE__))

describe TrinidadScheduler do

  context 'properties' do

    it "returns a properties instance" do
      properties = TrinidadScheduler.quartz_properties('Default',
        :wrapped => false, :interrupt_on_shutdown => true
      )
      expect( properties ).to be_a java.util.Properties

      properties.each do |key, value|
        expect( key[0, 10] ).to eql 'org.quartz'
        expect( value ).to be_a String
      end
    end

    it "accepts thread_count and thread_priority" do
      properties = TrinidadScheduler.quartz_properties('Default', :thread_count => 42, :thread_priority => 6)
      expect( properties['org.quartz.threadPool.threadCount'] ).to eql '42'
      expect( properties['org.quartz.threadPool.threadPriority'] ).to eql '6'
    end

    it "expands non-prefixed keys" do
      properties = TrinidadScheduler.quartz_properties('Default',
        :'foo.truthy' => true, 'foo.falsy' => false
      )
      expect( properties['org.quartz.foo.truthy'] ).to eql 'true'
      expect( properties['org.quartz.foo.falsy'] ).to eql 'false'
    end

  end

end