# frozen_string_literal: true

# Transaction Repo
require_relative 'repo_module'
class TransactionRepository
  include RepoModule
  attr_reader :repo, :new_object

  def initialize(file)
    @repo = []
    open_transactions(file)
    @new_object = Transaction
  end

  def open_transactions(file)
    CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
      @repo << Transaction.new(row)
    end
  end

  def find_all_by_credit_card_number(credit_card_number)
    @repo.find_all { |transaction| transaction.credit_card_number == credit_card_number }
  end

  def find_all_by_result(result)
    @repo.find_all { |transaction| transaction.result == result }
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
end
