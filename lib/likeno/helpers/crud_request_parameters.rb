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
  module CRUDRequestParameters
    def save_params
      { instance_entity_name.underscore.to_sym => to_hash }
    end

    def save_action
      ''
    end

    def save_prefix
      ''
    end

    def destroy_action
      ':id'
    end
    alias_method :update_action, :destroy_action

    def destroy_params
      { id: id }
    end

    def destroy_prefix
      ''
    end

    def update_params
      { instance_entity_name.underscore.to_sym => to_hash, :id => id }
    end

    def update_prefix
      ''
    end

    def default_headers
      {}
    end
    alias_method :save_headers, :default_headers
    alias_method :destroy_headers, :default_headers
    alias_method :update_headers, :default_headers

    module ClassMethods
      def exists_action
        ':id/exists'
      end

      def id_params(id)
        { id: id }
      end

      def find_action
        ':id'
      end
    end
  end
end
