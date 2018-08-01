require 'spec_helper'

describe 'Taxonomies', type: :feature, js: true do
  stub_authorization!

  before(:each) do
    visit spree.admin_path
    click_link 'Products'
  end

  context 'show' do
    it 'should display existing taxonomies' do
      create(:taxonomy, name: 'Brand')
      create(:taxonomy, name: 'Categories')
      visit spree.admin_taxonomies_path
      within_row(1) { expect(page).to have_content('Brand') }
      within_row(2) { expect(page).to have_content('Categories') }
    end
  end

  context 'create' do
    before(:each) do
      click_link 'Taxonomies'
      click_link 'admin_new_taxonomy_link'
    end

    it 'should allow an admin to create a new taxonomy' do
      expect(page).to have_content('New Taxonomy')
      fill_in 'taxonomy_name', with: 'sports'
      click_button 'Create'
      expect(page).to have_content('successfully created!')
    end

    it 'should display validation errors' do
      fill_in 'taxonomy_name', with: ''
      click_button 'Create'
      expect(page).to have_content("can't be blank")
    end
  end

  context 'edit' do
    it 'should allow an admin to update an existing taxonomy' do
      create(:taxonomy)
      click_link 'Taxonomies'
      within_row(1) { click_icon :edit }
      fill_in 'taxonomy_name', with: 'sports 99'
      click_button 'Update'
      expect(page).to have_content('successfully updated!')
      expect(page).to have_content('sports 99')
    end
  end
end
