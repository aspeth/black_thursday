# frozen_string_literal: true

# Item Repo
require_relative 'repo_module'
class ItemRepository
  include RepoModule
  attr_reader :repo

  def initialize(file)
    @repo = []
    open_items(file)
  end

  def open_items(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Item.new(row)
    end
  end

  def find_all_with_description(description)
    @repo.find_all { |item| item.description.downcase == description.downcase }
  end

  def find_all_by_price(price)
    @repo.find_all { |item| item.unit_price == price }
  end

  def find_all_by_price_in_range(range)
    @repo.find_all { |item| item.unit_price >= range.first && item.unit_price <= range.last }
  end

  def create(attributes)
    @repo.sort_by(&:id)
    last_id = @repo.last.id
    attributes[:id] = (last_id += 1)
    @repo << Item.new(attributes)
  end

  def update(id, attributes)
    item = find_by_id(id)
    attributes.map do |key, value|
      item.unit_price = value if key == :unit_price
      item.description = value if key == :description
      item.name = value if key == :name
      item.updated_at = Time.now
    end
  end
end
