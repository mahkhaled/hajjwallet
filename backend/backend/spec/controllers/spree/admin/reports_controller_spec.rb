require 'spec_helper'

describe Spree::Admin::ReportsController, type: :controller do
  stub_authorization!

  describe 'ReportsController.available_reports' do
    it 'should contain sales_total' do
      expect(Spree::Admin::ReportsController.available_reports.keys.include?(:sales_total)).to be true
    end

    it 'should have the proper sales total report description' do
      expect(Spree::Admin::ReportsController.available_reports[:sales_total][:description]).to eql('Sales Total For All Orders')
    end
  end

  describe 'ReportsController.add_available_report!' do
    context 'when adding the report name' do
      it 'should contain the report' do
        Spree::Admin::ReportsController.add_available_report!(:some_report)
        expect(Spree::Admin::ReportsController.available_reports.keys.include?(:some_report)).to be true
      end
    end
  end

  describe 'GET index' do
    it 'should be ok' do
      spree_get :index
      expect(response).to be_ok
    end
  end

  it 'should respond to model_class as Spree::AdminReportsController' do
    expect(controller.send(:model_class)).to eql(Spree::Admin::ReportsController)
  end

  after(:each) do
    Spree::Admin::ReportsController.available_reports.delete_if do |key, _value|
      key != :sales_total
    end
  end
end
