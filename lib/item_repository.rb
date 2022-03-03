# frozen_string_literal: true

# item_repository
require 'pry'
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

  # def all
  #   @items
  # end

  def find_by_id(id)
    @repo.find { |item| item.id == id }
  end

  def find_by_name(name)
    @repo.find { |item| item.name.downcase == name.downcase }
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

  def find_all_by_merchant_id(merchant_id)
    @repo.find_all { |item| item.merchant_id == merchant_id }
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

  def delete(id)
    @repo.delete(find_by_id(id))
  end

  def inspect
    "#<#{@items.class} #{@items.all.size} rows>"
  end
end
