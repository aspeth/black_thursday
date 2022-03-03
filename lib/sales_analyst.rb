# frozen_string_literal: true

require 'pry'
require 'bigdecimal'
require 'bigdecimal/util'
require_relative 'sales_engine'
class SalesAnalyst
  attr_reader :items, :merchants, :invoices, :transactions, :customers, :invoice_items

  def initialize(items, merchants, invoices, transactions, customers, invoice_items)
    @items = items
    @merchants = merchants
    @invoices = invoices
    @transactions = transactions
    @customers = customers
    @invoice_items = invoice_items
    @customers = customers
  end

  def average_items_per_merchant
    (@items.all.count.to_f / @merchants.all.count).round(2)
  end

  def total_items_per_merchant
    @items_per_merchant = {}
    @items.all.each do |item|
      @items_per_merchant[item.merchant_id] = 0 unless @items_per_merchant.key?(item.merchant_id)
      !@items_per_merchant[item.merchant_id] += 1
    end
    @items_per_merchant
  end

  def average_items_per_merchant_standard_deviation
    total_items_per_merchant
    total_square_diff = 0
    total_items_per_merchant.values.map do |item_count|
      total_square_diff += ((item_count - average_items_per_merchant)**2)
    end
    Math.sqrt(total_square_diff / (@merchants.all.count - 1)).round(2)
  end

  def merchants_with_high_item_count
    @high_item_merchants = []
    total_items_per_merchant.select { |_k, v| v > 6 }.each_key do |high_id|
      @merchants.all.each do |merchant|
        @high_item_merchants << merchant if merchant.id == high_id
      end
    end
    @high_item_merchants
  end

  def average_item_price_for_merchant(merchant_id)
    merchant_items = @items.all.find_all { |item| item.merchant_id == merchant_id }
    total_price = BigDecimal(0)
    merchant_items.map do |item|
      total_price += item.unit_price_to_dollars
    end
    BigDecimal((total_price / total_items_per_merchant[merchant_id]).to_f.round(2), 4)
  end

  def average_average_price_per_merchant
    sum_of_averages = BigDecimal(0)
    @merchants.all.map do |merchant|
      sum_of_averages += average_item_price_for_merchant(merchant.id)
    end
    BigDecimal((sum_of_averages / @merchants.all.count), 5).truncate(2)
  end

  def golden_items
    average = average_average_price_per_merchant
    total_square_diff = 0
    @items.all.each do |item|
      total_square_diff += ((item.unit_price.to_i - average)**2)
    end
    std_dev = Math.sqrt(total_square_diff / (@items.all.count - 1))
    @items.all.find_all { |item| item.unit_price.to_i > (average + (std_dev * 2)) }
  end

  def average_invoices_per_merchant
    (@invoices.all.count.to_f / @merchants.all.count).round(2)
  end

  def total_invoices_per_merchant
    @invoices_per_merchant = {}
    @invoices.all.each do |item|
      @invoices_per_merchant[item.merchant_id] = 0 unless @invoices_per_merchant.key?(item.merchant_id)
      !@invoices_per_merchant[item.merchant_id] += 1
    end
    @invoices_per_merchant
  end

  def average_invoices_per_merchant_standard_deviation
    total_invoices_per_merchant
    total_square_diff = 0
    total_invoices_per_merchant.values.map do |item_count|
      total_square_diff += ((item_count - average_invoices_per_merchant)**2)
    end
    Math.sqrt(total_square_diff / (@merchants.all.count - 1)).round(2)
  end

  def high_invoice_merchants
    highest_invoice_merchants = []
    total_invoices_per_merchant.select do |k, v|
      if v > (average_invoices_per_merchant + (average_invoices_per_merchant_standard_deviation * 2))
        highest_invoice_merchants << k
      end
    end
    highest_invoice_merchants
  end

  def top_merchants_by_invoice_count
    top_merchants = []
    high_invoice_merchants.each do |high_id|
      @merchants.all.each do |merchant|
        top_merchants << merchant if merchant.id == high_id
      end
    end
    top_merchants
  end

  def low_invoice_merchants
    low_invoice_merchants = []
    total_invoices_per_merchant.select do |k, v|
      if v < (average_invoices_per_merchant - (average_invoices_per_merchant_standard_deviation * 2))
        low_invoice_merchants << k
      end
    end
    low_invoice_merchants
  end

  def bottom_merchants_by_invoice_count
    bottom_merchants = []
    low_invoice_merchants.each do |low_id|
      @merchants.all.each do |merchant|
        bottom_merchants << merchant if merchant.id == low_id
      end
    end
    bottom_merchants
  end

  def invoices_by_day_of_week
    invoices_by_day_of_week = Hash.new(0)
    @invoices.all.each do |invoice|
      invoices_by_day_of_week[invoice.created_at.strftime('%A')] += 1
    end
    invoices_by_day_of_week
  end

  def std_dev_of_invoices_per_day
    average_invoice_per_day = (@invoices.all.count / 7).to_f
    total_square_diff = 0
    invoices_by_day_of_week.each do |_day, count|
      total_square_diff += ((count - average_invoice_per_day)**2)
    end
    Math.sqrt(total_square_diff.to_f / 6).round(2)
  end

  def top_days_by_invoice_count
    average_invoice_per_day = (@invoices.all.count / 7).to_f
    top_days = invoices_by_day_of_week.find_all do |_day, count|
      count > (average_invoice_per_day + std_dev_of_invoices_per_day)
    end
    top_days.flatten.find_all { |item| item.instance_of?(String) }
  end

  def invoice_status(status_type)
    invoice_type_count = Hash.new(0)
    @invoices.all.each do |invoice|
      invoice_type_count[invoice.status.to_sym] += 1
    end
    ((invoice_type_count[status_type].to_f / @invoices.all.count) * 100).round(2)
  end

  def invoice_paid_in_full?(invoice_id)
    transactions_by_invoice = @transactions.find_all_by_invoice_id(invoice_id)
    transactions_by_invoice.any? { |transaction| transaction.result == :success }
  end

  def invoice_total(invoice_id)
    invoices = @invoice_items.find_all_by_invoice_id(invoice_id) if invoice_paid_in_full?(invoice_id) == true
    invoices.map { |invoice| (invoice.unit_price * invoice.quantity) }.sum
  end

  def invoices_by_date(date)
    invoice_id_by_date = []
    @invoices.all.each do |invoice|
      invoice_id_by_date << invoice.id if invoice.created_at.strftime('%D') == date.strftime('%D')
    end
    invoice_id_by_date
  end

  def total_revenue_by_date(date)
    invoice_items_by_date = []
    invoices_by_date(date).each do |invoice_id|
      invoice_items_by_date << @invoice_items.find_all_by_invoice_id(invoice_id)
    end
    invoice_items_by_date.flatten.map { |invoice| (invoice.unit_price * invoice.quantity) }.sum
  end

  def invoice_revenue
    revenue_per_invoice = {}
    @invoice_items.all.each do |invoice_item|
      @invoices.find_by_id(invoice_item.id)
      unless revenue_per_invoice.key?(invoice_item.invoice_id)
        revenue_per_invoice[@invoices.find_by_id(invoice_item.id)] = 0
      end
      revenue_per_invoice[@invoices.find_by_id(invoice_item.id)] += (invoice_item.unit_price * invoice_item.quantity)
    end
    revenue_per_invoice
  end

  def merchant_revenue_hash
    revenue_per_merchant_hash = Hash.new(0)
    invoice_revenue.each do |invoice, revenue|
      break if invoice.nil?

      merchant = @merchants.find_by_id(invoice.merchant_id)
      revenue_per_merchant_hash[merchant] += revenue if invoice.status == :success
    end
    revenue_per_merchant_hash
  end

  def revenue_by_merchant(merchant_id)
    merchant = @merchants.find_by_id(merchant_id)
    BigDecimal(merchant_revenue_hash[merchant])
  end

  def merchants_and_items
    merchants_and_items = Hash.new(0)
    @merchants.all.each do |merchant|
      @items.all.each do |item|
        merchants_and_items[merchant] += 1 if item.merchant_id == merchant.id
      end
    end
    merchants_and_items
  end

  def merchants_with_only_one_item
    one_item_merchants = []
    merchants_and_items.each do |merchant, item_count|
      one_item_merchants << merchant if item_count == 1
    end
    one_item_merchants
  end
end

# def top_revenue_earners(num)
#   top_merchants = merchant_revenue_hash.sort
#   top_merchants.flatten!
#   top_merchants
#
#   # require "pry"; binding.pry

# top_merchants_by_revenue = []
# merchant_revenue_hash.each do |merchant, revenue|
#   revenue.sort

# def new_method
#   revenue = {}
#   @invoice_items.all.each do |invoice_item|
#     invoice = find_by_id(invoice_item.invoice_id)
#
# end
