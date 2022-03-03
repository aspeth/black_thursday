# frozen_string_literal: true

# merchant_repository
require_relative 'repo_module'
class MerchantRepository
  include RepoModule
  attr_reader :repo

  def initialize(file)
    @repo = []
    open_merchants(file)
  end

  def open_merchants(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Merchant.new(row)
    end
  end

  def find_all_by_name(fragment)
    @repo.find_all { |merchant| merchant.name.downcase.include?(fragment) }
  end

  def create(attributes)
    @repo.sort_by(&:id)
    last_id = @repo.last.id
    attributes[:id] = (last_id += 1)
    @repo << Merchant.new(attributes)
  end

  def update(id, attributes)
    merchant = find_by_id(id)
    attributes.map do |key, v|
      merchant.name = v if key == :name
    end
  end

  def delete(id)
    @repo.delete(find_by_id(id))
  end
end
