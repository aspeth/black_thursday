# frozen_string_literal: true

# Customer Repo
require_relative 'repo_module'
class CustomerRepository
  include RepoModule
  attr_reader :repo, :new_object

  def initialize(file)
    @repo = []
    open_customers(file)
    @new_object = Customer
  end

  def open_customers(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Customer.new(row)
    end
  end

  def find_all_by_first_name(name)
    @repo.find_all { |customer| customer.first_name.downcase.include?(name.downcase) }
  end

  def find_all_by_last_name(name)
    @repo.find_all { |customer| customer.last_name.downcase.include?(name.downcase) }
  end

  def update(id, attributes)
    customer = find_by_id(id)
    attributes.map do |key, v|
      customer.first_name = v if key == :first_name
      customer.last_name = v if key == :last_name
      customer.updated_at = Time.now
    end
  end
end
