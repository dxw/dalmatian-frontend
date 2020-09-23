require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#active_link" do
    context "when the link path matches the current path" do
      it "returns an 'active' string" do
        link_path = infrastructure_path(Infrastructure.create)
        allow_any_instance_of(ActionController::TestRequest).to receive(:path)
          .and_return(link_path)

        expect(helper.active_link(path: link_path)).to eql("active")
      end
    end

    context "when the link path DOES NOT match the current path" do
      it "returns nil" do
        link_path = infrastructure_path(Infrastructure.create)
        allow_any_instance_of(ActionController::TestRequest).to receive(:path)
          .and_return("/another/path/")

        expect(helper.active_link(path: link_path)).to eql(nil)
      end
    end
  end

  describe "#present_sensitive_value" do
    context "when the app is configured to HIDE secrets" do
      around do |example|
        ClimateControl.modify HIDE_SECRETS_BY_DEFAULT: "true" do
          example.run
        end
      end

      it "obfuscates the value by replacing it with *" do
        result = helper.present_sensitive_value("secret")
        expect(result).to eql I18n.t("obfuscation")
      end
    end

    context "when the app is configured to SHOW secrets" do
      around do |example|
        ClimateControl.modify HIDE_SECRETS_BY_DEFAULT: "false" do
          example.run
        end
      end

      it "obfuscates the value by replacing it with *" do
        result = helper.present_sensitive_value("secret")
        expect(result).to eql("secret")
      end
    end
  end
end
