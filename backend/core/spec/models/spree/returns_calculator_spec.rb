require 'spec_helper'

module Spree
  describe ReturnsCalculator, type: :model do
    let(:return_item) { build(:return_item) }
    subject { ReturnsCalculator.new }

    it 'compute_shipment must be overridden' do
      expect do
        subject.compute(return_item)
      end.to raise_error(NotImplementedError)
    end
  end
end
