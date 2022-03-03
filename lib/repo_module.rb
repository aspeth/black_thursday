module RepoModule
  def all
    @repo
  end

  def inspect
    "#<#{@self.class} #{@merchants.size} rows>"
  end
end
