# Invoice_items class
require 'time'
require 'bigdecimal'

class InvoiceItems
  attr_accessor :item_id, :invoice_id, :quantity, :unit_price, :updated_at
  attr_reader :id, :created_at

  def initialize(attributes)
    @id = attributes[:id].to_i
    @item_id = attributes[:item_id].to_i
    @invoice_id = attributes[:invoice_id].to_i
    @quantity = attributes[:quantity].to_i
    @unit_price = BigDecimal(attributes[:unit_price]) / 100
    @created_at = Time.parse(attributes[:created_at].to_s)
    @updated_at = Time.parse(attributes[:updated_at].to_s)
    # require "pry"; binding.pry
  end
end
