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

module Likeno
  module Errors
    class RecordInvalid < Standard
      attr_reader :record

      def initialize(record = nil)
        if record
          @record = record
          errors = @record.likeno_errors.join(', ')
          message = "Record invalid: #{errors}"
        else
          message = 'Record invalid'
        end

        super(message)
      end
    end
  end
end
