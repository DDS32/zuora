require 'spec_helper'

describe Zuora::Objects::AmendRequest do

  describe "most persistence methods" do
    it "are not publicly available" do
      [:update, :destroy, :where, :find].each do |meth|
        subject.public_methods.should_not include(meth)
      end
    end
  end

  describe "generating a request" do
    before do 
      subscription = FactoryGirl.build(:subscription)
      @amendment = FactoryGirl.build(:amendment)
      @amendment.subscription_id = subscription.id
      MockResponse.responds_with(:payment_method_credit_card_find_success) do
        product_rate_plans = [Zuora::Objects::ProductRatePlan.find('stub')]

        @rate_plan = Zuora::Objects::RatePlan.new
        @rate_plan.product_rate_plan_id = product_rate_plans[0].id
      end
    end

    it "provides properly formatted xml when using existing objects" do
      MockResponse.responds_with(:amend_request_success) do
        @amendment.rate_plan_data = { rate_plan: @rate_plan, charges: nil }
        subject.amendments = [ @amendment ]

        amnd_resp = subject.create
        amnd_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:Type").
        with_value('NewProduct')
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:Name").
        with_value('Example Amendment 1')
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:RatePlanData/#{zns}:RatePlan/#{ons}:ProductRatePlanId").
        with_value('4028e48834aa10a30134c50f40901ea7')
    end

    it "handles applying amend failures messages" do
      MockResponse.responds_with(:amend_request_failure) do
        @amendment.subscription_id = '2c92c0f93a569878013a6778f0446b11'
        @amendment.rate_plan_data = { rate_plan: @rate_plan, charges: nil }
        subject.amendments = [ @amendment ]
        amnd_resp = subject.create
        amnd_resp[:success].should == false
        amnd_resp[:errors][:message].should include('Invalid value for field SubscriptionId: 2c92c0f93a569878013a6778f0446b11')
      end
    end

    it "supports amend options" do
      MockResponse.responds_with(:amend_request_success) do
        @amendment.rate_plan_data = { rate_plan: @rate_plan, charges: nil }
        subject.amendments = [ @amendment ]
        subject.amend_options = {:generate_invoice => true, :process_payments => true}
        amnd_resp = subject.create
        amnd_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:GenerateInvoice").
        with_value(true)
    end

    it "supports preview options" do
      MockResponse.responds_with(:amend_request_success) do
        @amendment.rate_plan_data = { rate_plan: @rate_plan, charges: nil }
        subject.amendments = [ @amendment ]
        subject.preview_options = { enable_preview_mode: true, number_of_periods: 1 }
        amnd_resp = subject.create
        amnd_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:PreviewOptions/#{zns}:EnablePreviewMode").
        with_value(true)
    end

    it "supports a rate plan with multiple charges" do
      MockResponse.responds_with(:amend_request_success) do

        rpc = Zuora::Objects::RatePlanCharge.new
        rpc.quantity = 12
        rpc.product_rate_plan_charge_id = '123'

        @amendment.rate_plan_data = { rate_plan: @rate_plan, charges: [rpc, rpc] }
        subject.amendments = [ @amendment ]

        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
      end
      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:RatePlanData")
    end

  end  
end
