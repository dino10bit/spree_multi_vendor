require 'spec_helper'

RSpec.describe 'Admin Stock Locations', :js do
  let(:vendor) { create(:vendor) }
  let!(:user) { create(:user, vendors: [vendor]) }
  let!(:admin) { create(:admin_user) }

  before do
    create(:product, name: 'Test')
    create(:stock_location, name: 'Test')
  end

  context 'when user with admin role' do
    describe '#index' do
      it 'displays all stock locations' do
        login_as(admin, scope: :spree_user)
        visit spree.admin_stock_locations_path
        expect(page).to have_selector('tr', count: 3)
      end
    end
  end

  context 'when user with vendor' do
    before do
      login_as(user, scope: :spree_user)
      visit spree.admin_stock_locations_path
    end

    describe '#index' do
      it 'displays only vendor stock location' do
        expect(page).to have_selector('tr', count: 2)
      end
    end

    describe 'stock movements' do
      it 'displays stock movements for vendor stock location' do
        click_on 'Stock Movements'
        expect(page).to have_text "Stock Movements for #{vendor.name}"
      end

      it 'can create a new stock movement for vendor stock location' do
        click_on 'Stock Movements'
        click_on 'New Stock Movement'
        expect(page).to have_current_path spree.new_admin_stock_location_stock_movement_path(vendor.stock_locations.first)

        fill_in 'stock_movement_quantity', with: 5
        fill_in 'stock_movement_stock_item_id', with: 1

        click_button 'Create'

        expect(page).to have_text 'successfully created!'
        expect(Spree::StockMovement.count).to eq 1
      end
    end

    describe '#create' do
      it 'can create a new stock location' do
        click_link 'New Stock Location'
        expect(page).to have_current_path spree.new_admin_stock_location_path

        fill_in 'stock_location_name', with: 'Vendor stock location'

        click_button 'Create'

        expect(page).to have_text 'successfully created!'
        expect(page).to have_current_path spree.admin_stock_locations_path
        expect(Spree::StockLocation.last.vendor_id).to eq vendor.id
      end
    end

    describe '#edit' do
      before do
        within_row(1) { click_icon :edit }
      end

      it 'can update an existing stock location' do
        fill_in 'stock_location_name', with: 'Testing edit'
        click_button 'Update'
        expect(page).to have_text 'successfully updated!'
        expect(page).to have_text 'Testing edit'
      end

      it 'shows validation error with blank name' do
        fill_in 'stock_location_name', with: ''
        click_button 'Update'
        expect(page).not_to have_text 'successfully created!'
      end
    end
  end
end
