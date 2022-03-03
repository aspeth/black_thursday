# frozen_string_literal: true

require_relative 'repo_module'
class CustomerRepository
  include RepoModule
  attr_reader :repo

  def initialize(file)
    @repo = []
    open_customers(file)
  end

  def open_customers(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Customer.new(row)
    end
  end

  # def all
  #  @repo
  # end

  def find_by_id(id)
    @repo.find { |customer| customer.id == id }
  end

  def find_all_by_first_name(name)
    @repo.find_all { |customer| customer.first_name.downcase.include?(name.downcase) }
  end

  def find_all_by_last_name(name)
    @repo.find_all { |customer| customer.last_name.downcase.include?(name.downcase) }
  end

  def create(attributes)
    @repo.sort_by(&:id)
    last_id = @repo.last.id
    attributes[:id] = (last_id += 1)
    @repo << Customer.new(attributes)
  end

  def update(id, attributes)
    customer = find_by_id(id)
    attributes.map do |key, v|
      customer.first_name = v if key == :first_name
      customer.last_name = v if key == :last_name
      customer.updated_at = Time.now
    end
  end

  def delete(id)
    @repo.delete(find_by_id(id))
  end
end
