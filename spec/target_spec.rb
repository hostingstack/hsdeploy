require 'spec_helper'

describe DeployTool::Target do
  context "Target selection" do
    before do
      stub.any_instance_of(HighLine).ask do |q, |
        if q[/E-mail/]
          "demo@hostingstack.org"
        elsif q[/Password/]
          "demo"
        else
          nil
        end
      end
      
      # TODO: Mock HTTP get method
    end

    ["app10000@api.hostingstack.org", "app10000@hostingstack.org", "app10000@app123.hostingstack.org", "app10000.hostingstack.org"].each do |target_spec|
      it "should detect #{target_spec} as an HostingStack target" do
        DeployTool::Target.find(target_spec).class.should == DeployTool::Target::HostingStack
      end
    end

    ["gandi.net", "1and1.com"].each do |target_spec|
      it "should return an error with #{target_spec} as target" do
        DeployTool::Target.find(target_spec).class.should == NilClass
      end
    end
  end
end
