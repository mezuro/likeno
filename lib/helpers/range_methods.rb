module RangeMethods
  def range
    @range ||= Range.new(Float(beginning), Float(self.end), exclude_end: true)
  end

  def beginning=(value)
    @beginning = (value == "-INF") ? -Float::INFINITY : value
  end

  def end=(value)
    @end = (value == "INF") ? Float::INFINITY : value
  end
end

