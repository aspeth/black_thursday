# frozen_string_literal: true

# Merchant Repo
require_relative 'repo_module'
class MerchantRepository
  include RepoModule
  attr_reader :repo, :new_object

  def initialize(file)
    @repo = []
    open_merchants(file)
    @new_object = Merchant
  end

  def open_merchants(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Merchant.new(row)
    end
  end

  def find_all_by_name(fragment)
    @repo.find_all { |merchant| merchant.name.downcase.include?(fragment) }
  end

  def update(id, attributes)
    merchant = find_by_id(id)
    attributes.map do |key, v|
      merchant.name = v if key == :name
    end
  end
end
