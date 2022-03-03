# frozen_string_literal: true

# Invoice Repo
require_relative 'repo_module'
class InvoiceRepository
  include RepoModule
  attr_reader :repo, :new_object

  def initialize(file)
    @repo = []
    open_items(file)
    @new_object = Invoice
  end

  def open_items(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Invoice.new(row)
    end
  end

  def find_all_by_customer_id(customer_id)
    @repo.find_all { |invoice| invoice.customer_id == customer_id }
  end

  def find_all_by_status(status)
    @repo.find_all { |invoice| invoice.status == status }
  end

  def update(id, attributes)
    invoice = find_by_id(id)
    attributes.map do |key, value|
      invoice.status = value if key == :status
      invoice.updated_at = Time.now
    end
  end
end
