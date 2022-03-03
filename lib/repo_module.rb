# frozen_string_literal: true

module RepoModule
  def all
    @repo
  end

  def find_by_id(id)
    @repo.find { |element| element.id == id }
  end

  def find_by_name(name)
    @repo.find { |element| element.name.downcase == name.downcase }
  end

  def find_all_by_merchant_id(merchant_id)
    @repo.find_all { |element| element.merchant_id == merchant_id }
  end

  def find_all_by_invoice_id(invoice_id)
    @repo.find_all { |element| element.invoice_id == invoice_id }
  end

  def create(attributes)
    @repo.sort_by(&:id)
    last_id = @repo.last.id
    attributes[:id] = (last_id += 1)
    object = @new_object.new(attributes)
    @repo << object
    object
  end

  def delete(id)
    @repo.delete(find_by_id(id))
  end

  def inspect
    "#<#{@self.class} #{@merchants.size} rows>"
  end
end
