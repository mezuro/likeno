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

require 'faraday'
require 'faraday_middleware'
require 'likeno/errors'

module Likeno
  module RequestMethods
    def request(action, params = {}, method = :post, prefix = '')
      response = client.send(method) do |request|
        url = "/#{endpoint}/#{action}".gsub(':id', params[:id].to_s)
        url = "/#{prefix}#{url}" unless prefix.empty?
        request.url url
        request.body = params unless method == :get || params.empty?
        request.options.timeout = 300
        request.options.open_timeout = 300
      end

      if response.success?
        response.body
      elsif response.status == 404
        raise Likeno::Errors::RecordNotFound.new(response: response)
      else
        raise Likeno::Errors::RequestError.new(response: response)
      end
    end

    def address
      raise NotImplementedError
    end

    # TODO: probably the connection could be a class static variable.
    def client
      Faraday.new(url: address) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def endpoint
      entity_name.pluralize
    end

    def module_name
      raise NotImplementedError
    end

    def entity_name
      # This loop is a generic way to make this work even when the children class has a different name
      entity_class = self
      until entity_class.name.include?("#{module_name}::")
        entity_class = entity_class.superclass
      end

      entity_class.name.split('::').last.underscore.downcase
    end
  end
end
