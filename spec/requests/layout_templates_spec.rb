require 'spec_helper'

describe "LayoutTemplates" do
  describe "GET /layout_templates" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get layout_templates_path
      response.status.should be(200)
    end
  end
end
