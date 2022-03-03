# frozen_string_literal: true

# Transaction Repo
require_relative 'repo_module'
class TransactionRepository
  include RepoModule
  attr_reader :repo

  def initialize(file)
    @repo = []
    open_transactions(file)
  end

  def open_transactions(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Transaction.new(row)
    end
  end

  def find_all_by_invoice_id(id)
    @repo.find_all { |transactions| transactions.invoice_id == id }
  end

  def find_all_by_credit_card_number(credit_card_number)
    @repo.find_all { |transaction| transaction.credit_card_number == credit_card_number }
  end

  def find_all_by_result(result)
    @repo.find_all { |transaction| transaction.result == result }
  end

  def create(attributes)
    @repo.sort_by(&:id)
    last_id = @repo.last.id
    attributes[:id] = (last_id += 1)
    @repo << Transaction.new(attributes)
  end

  def update(id, attributes)
    transactions = find_by_id(id)
    attributes.map do |key, value|
      if key == :result
        transactions.result = value
        transactions.updated_at = Time.now
      end
    end
  end

  def delete(id)
    @repo.delete(find_by_id(id)) unless nil
  end
end
