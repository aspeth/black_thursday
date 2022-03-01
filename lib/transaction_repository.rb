# Transaction Repo
require 'pry'
class TransactionRepository
  attr_reader :transactions

  def initialize(transactions)
    @transactions = transactions
  end

  def all
    @transactions
  end

  def find_by_id(id)
    @transactions.find { |transactions| transactions.id == id }
  end

  def find_all_by_invoice_id(id)
    @transactions.find_all { |transactions| transactions.invoice_id == id }
  end

  def find_all_by_credit_card_number(credit_card_number)
    @transactions.find_all { |transaction| transaction.credit_card_number == credit_card_number }
  end

  def find_all_by_result(result)
    @transactions.find_all { |transaction| transaction.result == result }
  end

  def create(attributes)
    @transactions.sort_by { |transaction| transaction.id }
    last_id = @transactions.last.id
    attributes[:id] = (last_id += 1)
    @transactions << Transaction.new(attributes)
  end
end
