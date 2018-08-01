require 'spec_helper'

module Spree
  module Stock
    module Splitter
      describe Base, type: :model do
        let(:packer) { build(:stock_packer) }

        it 'continues to splitter chain' do
          splitter1 = Base.new(packer)
          splitter2 = Base.new(packer, splitter1)
          packages = []

          expect(splitter1).to receive(:split).with(packages)
          splitter2.split(packages)
        end
      end
    end
  end
end
