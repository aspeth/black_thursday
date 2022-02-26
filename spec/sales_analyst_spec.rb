require './lib/sales_engine'
require 'pry'
require 'bigdecimal'

RSpec.describe ItemRepository do
  before(:each) do
    @se = SalesEngine.from_csv({
                                 items: './data/items.csv',
                                 merchants: './data/merchants.csv'
                               })
    @sales_analyst = @se.analyst
  end

  it '#average_items_per_merchant returns average items per merchant' do
    expected = @sales_analyst.average_items_per_merchant

    expect(expected).to eq 2.88
    expect(expected.class).to eq Float
  end

  it ' ' do
    en
  end
end
