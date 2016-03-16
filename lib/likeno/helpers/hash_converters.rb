# This file is part of Likeno. Copyright (C) 2013-2016 The Mezuro Team

# Likeno is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Likeno is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with Likeno.  If not, see <http://www.gnu.org/licenses/>.

require 'date'

module Likeno
  module HashConverters
    def date_time_to_s(date)
      milliseconds = '.' + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
      date.to_s[0..18] + milliseconds + date.to_s[19..-1]
    end

    def convert_to_hash(value)
      return value if value.nil?
      return value.collect { |element| convert_to_hash(element) } if value.is_a? Array
      return value.to_hash if value.is_a?(Likeno::Entity)
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
end
