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

  def inspect
    "#<#{@self.class} #{@merchants.size} rows>"
  end
end
