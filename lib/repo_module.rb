module RepoModule
  def all
    @repo
  end

  def find_by_id(id)
    @repo.find { |element| element.id == id }
  end

  def inspect
    "#<#{@self.class} #{@merchants.size} rows>"
  end
end
