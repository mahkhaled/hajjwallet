# encoding: utf-8

require 'spec_helper'

describe 'Customer Returns', type: :feature do
  stub_authorization!
  let!(:customer_return) { create(:customer_return, created_at: Time.current) }

  describe 'listing' do
    let!(:customer_return_2) { create(:customer_return, created_at: Time.current - 1.day) }

    before(:each) do
      visit spree.admin_customer_returns_path
    end

    it 'lists sorted by created_at' do
      within_row(1) { expect(page).to have_content(customer_return.number) }
      within_row(2) { expect(page).to have_content(customer_return_2.number) }
    end

    it 'displays pre tax total' do
      within_row(1) { expect(page).to have_content(customer_return.display_pre_tax_total.to_html) }
    end

    it 'displays order number' do
      within_row(1) { expect(page).to have_content(customer_return.order.number) }
    end

    it 'displays customer return number' do
      within_row(1) { expect(page).to have_content(customer_return.number) }
    end

    it 'displays status' do
      within_row(1) { expect(page).to have_content(Spree.t(:incomplete)) }
    end

    it 'has edit link' do
      expect(page).to have_css('.icon-edit')
    end
  end

  describe 'searching' do
    let!(:customer_return_2) { create(:customer_return) }

    it 'searches on number' do
      visit spree.admin_customer_returns_path

      click_on 'Filter'
      fill_in 'q_number_cont', with: customer_return.number
      click_on 'Search'

      expect(page).to have_content(customer_return.number)
      expect(page).not_to have_content(customer_return_2.number)

      click_on 'Filter'
      fill_in 'q_number_cont', with: customer_return_2.number
      click_on 'Search'

      expect(page).to have_content(customer_return_2.number)
      expect(page).not_to have_content(customer_return.number)
    end
  end

  describe 'link' do
    describe 'order number' do
      it 'opens orders edit page' do
        visit spree.admin_customer_returns_path
        click_link customer_return.order.number
        expect(page).to have_content("Orders / #{customer_return.order.number}")
      end
    end

    describe 'customer return number' do
      it 'opens customer return edit page' do
        visit spree.admin_customer_returns_path
        click_link customer_return.number
        expect(page).to have_content("Customer Return ##{customer_return.number}")
      end
    end
  end
end
