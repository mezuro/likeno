module DateAttributes
  attr_reader :created_at, :updated_at

  def created_at=(value)
    @created_at = DateTime.parse(value)
  end

  def updated_at=(value)
    @updated_at = DateTime.parse(value)
  end
end