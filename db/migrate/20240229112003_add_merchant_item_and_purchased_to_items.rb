class AddMerchantItemAndPurchasedToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :merchant_item, :boolean, default: false
    add_column :items, :purchased, :boolean, default: false
  end
end
