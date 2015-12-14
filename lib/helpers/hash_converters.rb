require 'date'

module HashConverters
  def date_time_to_s(date)
    milliseconds = '.' + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
    date.to_s[0..18] + milliseconds + date.to_s[19..-1]
  end

  def convert_to_hash(value)
    return value if value.nil?
    return value.collect { |element| convert_to_hash(element) } if value.is_a? Array
    return value.to_hash if value.is_a?(Likeno::Base)
    return date_time_to_s(value) if value.is_a? DateTime
    return 'INF' if value.is_a?(Float) && value.infinite? == 1
    return '-INF' if value.is_a?(Float) && value.infinite? == -1
    value.to_s
  end

  def field_to_hash(field)
    hash = {}
    field_value = send(field)
    hash[field] = convert_to_hash(field_value) unless field_value.nil?
    hash
  end
end
