require 'spec_helper'
require 'cancan'
require 'spree/testing_support/bar_ability'

describe Spree::Admin::Orders::CustomerDetailsController, type: :controller do
  context 'with authorization' do
    stub_authorization!

    let(:user) { mock_model(Spree.user_class) }

    let(:order) do
      mock_model(
        Spree::Order,
        total:           100,
        number:          'R123456789',
        billing_address: mock_model(Spree::Address)
      )
    end

    before do
      allow(Spree::Order).to receive_message_chain(:includes, find_by!: order)
    end

    describe '#update' do
      let(:attributes) do
        {
          order_id: order.number,
          order: {
            email: '',
            use_billing: '',
            bill_address_attributes: { firstname: 'john' },
            ship_address_attributes: { firstname: 'john' },
            user_id: user.id.to_s
          },
          guest_checkout: 'true'
        }
      end

      def send_request(params = {})
        spree_put :update, params
      end

      context 'using guest checkout' do
        context 'having valid parameters' do
          before do
            allow(order).to receive_messages(update_attributes: true)
            allow(order).to receive_messages(next: false)
            allow(order).to receive_messages(address?: false)
            allow(order).to receive_messages(refresh_shipment_rates: true)
          end

          context 'having successful response' do
            before { send_request(attributes) }
            it { expect(response).to have_http_status(302) }
            it { expect(response).to redirect_to(edit_admin_order_url(order)) }
          end

          context 'with correct method flow' do
            it { expect(order).to receive(:update_attributes).with(ActionController::Parameters.new(attributes[:order]).permit(permitted_order_attributes)) }
            it { expect(order).to_not receive(:next) }
            it { expect(order).to receive(:address?) }
            it 'does refresh the shipment rates with all shipping methods' do
              expect(order).to receive(:refresh_shipment_rates).
                with(Spree::ShippingMethod::DISPLAY_ON_BACK_END)
            end
            it { expect(controller).to receive(:load_order).and_call_original }
            it { expect(controller).to receive(:guest_checkout?).twice.and_call_original }
            it { expect(controller).to_not receive(:load_user).and_call_original }
            after { send_request(attributes) }
          end
        end

        context 'having invalid parameters' do
          before do
            allow(order).to receive_messages(update_attributes: false)
          end

          context 'having failure response' do
            before { send_request(attributes) }
            it { expect(response).to render_template(:edit) }
          end

          context 'with correct method flow' do
            it { expect(order).to receive(:update_attributes).with(ActionController::Parameters.new(attributes[:order]).permit(permitted_order_attributes)) }
            it { expect(controller).to receive(:load_order).and_call_original }
            it { expect(controller).to receive(:guest_checkout?).and_call_original }
            it { expect(controller).to_not receive(:load_user).and_call_original }
            after { send_request(attributes) }
          end
        end
      end

      context 'without using guest checkout' do
        let(:changed_attributes) { attributes.merge(guest_checkout: 'false') }

        context 'having valid parameters' do
          before do
            allow(Spree.user_class).to receive(:find_by).and_return(user)
            allow(order).to receive_messages(update_attributes: true)
            allow(order).to receive_messages(next: false)
            allow(order).to receive_messages(address?: false)
            allow(order).to receive_messages(refresh_shipment_rates: true)
            allow(order).to receive_messages(associate_user!: true)
            allow(controller).to receive(:guest_checkout?).and_return(false)
            allow(order).to receive(:associate_user!)
          end

          context 'having successful response' do
            before { send_request(changed_attributes) }
            it { expect(response).to have_http_status(302) }
            it { expect(response).to redirect_to(edit_admin_order_url(order)) }
          end

          context 'with correct method flow' do
            it { expect(order).to receive(:update_attributes).with(ActionController::Parameters.new(attributes[:order]).permit(permitted_order_attributes)) }
            it { expect(order).to receive(:associate_user!).with(user, order.email.blank?) }
            it { expect(order).to_not receive(:next) }
            it { expect(order).to receive(:address?) }
            it 'does refresh the shipment rates with all shipping methods' do
              expect(order).to receive(:refresh_shipment_rates).
                with(Spree::ShippingMethod::DISPLAY_ON_BACK_END)
            end
            it { expect(controller).to receive(:load_order).and_call_original }
            it { expect(controller).to receive(:guest_checkout?).twice.and_call_original }
            it { expect(controller).to receive(:load_user).and_call_original }
            after { send_request(changed_attributes) }
          end
        end

        context 'having invalid parameters' do
          before do
            allow(Spree.user_class).to receive(:find_by).and_return(false)
            allow(controller).to receive(:guest_checkout?).and_return(false)
          end

          context 'having failure response' do
            before { send_request(changed_attributes) }
            it { expect(response).to render_template(:edit) }
          end

          context 'with correct method flow' do
            it { expect(order).to_not receive(:update_attributes).with(ActionController::Parameters.new(attributes[:order]).permit(permitted_order_attributes)) }
            it { expect(controller).to receive(:load_order).and_call_original }
            it { expect(controller).to receive(:guest_checkout?).and_call_original }
            it { expect(controller).to receive(:load_user).and_call_original }
            after { send_request(changed_attributes) }
          end
        end

        describe '#load_user' do
          context 'having valid parameters' do
            before do
              allow(Spree.user_class).to receive(:find_by).and_return(user)
              allow(order).to receive_messages(update_attributes: true)
              allow(order).to receive_messages(next: false)
              allow(order).to receive_messages(address?: false)
              allow(order).to receive_messages(refresh_shipment_rates: true)
              allow(order).to receive_messages(associate_user!: true)
              allow(controller).to receive(:guest_checkout?).and_return(false)
              allow(order).to receive(:associate_user!)
            end

            it 'expects to assign user' do
              send_request(changed_attributes)
              expect(assigns[:user]).to eq(user)
            end

            context 'with correct method flow' do
              it { expect(Spree.user_class).to receive(:find_by).with(id: user.id.to_s).and_return(user) }
              after { send_request(changed_attributes) }
            end
          end

          context 'with invalid parameters' do
            before do
              allow(Spree.user_class).to receive(:find_by).and_return(nil)
              allow(controller).to receive(:guest_checkout?).and_return(false)
            end

            it 'expects to not assign user' do
              send_request(changed_attributes)
              expect(assigns[:user]).to_not eq(user)
            end

            context 'with correct method flow' do
              it { expect(Spree.user_class).to receive(:find_by).with(id: user.id.to_s).and_return(nil) }
              it 'expects user class to receive find_by with email' do
                expect(Spree.user_class).to receive(:find_by).
                  with(email: changed_attributes[:order][:email]).and_return(nil)
              end
              after { send_request(changed_attributes) }
            end
          end
        end
      end
    end
  end
end
