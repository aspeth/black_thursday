# Invoice Items Repo

require_relative 'repo_module'
class InvoiceItemsRepository
  include RepoModule
  attr_reader :repo

  def initialize(file)
    @repo = []
    open_invoice_items(file)
  end

  def open_invoice_items(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << InvoiceItem.new(row)
    end
  end

  def find_all_by_item_id(item_id)
    @repo.find_all { |item| item.item_id == item_id }
  end

  def create(attributes)
    @repo.sort_by { |invoice_item| invoice_item.id }
    last_id = @repo.last.id
    attributes[:id] = (last_id += 1)
    @repo << InvoiceItem.new(attributes)
  end

  def update(id, attributes)
    invoice_item = find_by_id(id)
    attributes.map do |key, value|
      invoice_item.quantity = value if key == :quantity
      invoice_item.unit_price = value if key == :unit_price
      invoice_item.updated_at = Time.now
    end
  end
end
