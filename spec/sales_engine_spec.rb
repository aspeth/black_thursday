# frozen_string_literal: true

require_relative '../lib/sales_engine'

RSpec.describe SalesEngine do
  it 'can pull items and merchants from csv' do
    se = SalesEngine.from_csv({
                                items: './data/items.csv',
                                merchants: './data/merchants.csv',
                                invoices: './data/invoices.csv',
                                invoice_items: './data/invoice_items.csv',
                                transactions: './data/transactions.csv'
                              })

    expect(se).to be_a(SalesEngine)
    expect(se.items).to be_a(ItemRepository)
    expect(se.merchants).to be_a(MerchantRepository)
    expect(se.items.repo.count).to eq(1367)
    expect(se.merchants.all.count).to eq(475)
    expect(se.invoices.all.count).to eq(4985)
    expect(se.invoice_items.all.count).to eq(21_830)
  end
end
