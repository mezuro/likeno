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

require 'active_support/inflector'
require 'likeno/request_methods'
require 'likeno/helpers/hash_converters'
require 'likeno/helpers/crud_request_parameters'
require 'likeno/errors'

module Likeno
  class Entity
    attr_accessor :likeno_errors, :persisted

    def initialize(attributes = {}, persisted = false)
      attributes.each { |field, value| send("#{field}=", value) if self.class.valid?(field) }
      @likeno_errors = []
      @persisted = persisted
    end

    def to_hash(options = {})
      hash = {}
      excepts = options[:except].nil? ? [] : options[:except]
      excepts << 'likeno_errors'
      excepts << 'persisted'
      fields.each { |field| field_to_hash(field).merge!(hash) unless excepts.include? field }
      hash
    end

    extend Likeno::RequestMethods

    def self.to_object(value)
      value.is_a?(Hash) ? new(value, true) : value
    end

    def self.to_objects_array(value)
      array = value.is_a?(Array) ? value : [value]
      array.map { |element| to_object element }
    end

    def save
      if persisted?
        update
      else
        without_request_error? do
          response = self.class.request(save_action, save_params, :post, save_prefix, save_headers)

          self.id = response[instance_entity_name]["id"]
          self.created_at = response[instance_entity_name]["created_at"] unless response[instance_entity_name]["created_at"].nil?
          self.updated_at = response[instance_entity_name]["updated_at"] unless response[instance_entity_name]["updated_at"].nil?
          @persisted = true
        end
      end
    end

    def save!
      return true if save
      raise Likeno::Errors::RecordInvalid.new(self)
    end

    def self.create(attributes = {})
      new_model = new attributes
      new_model.save
      new_model
    end

    def update(attributes = {})
      attributes.each { |field, value| send("#{field}=", value) if self.class.valid?(field) }
      without_request_error? do
        self.class.request(update_action, update_params, :put, update_prefix, update_headers)
      end
    end

    def ==(other)
      return false unless self.class == other.class
      variable_names.each do |name|
        next if %w(created_at updated_at persisted).include? name
        return false unless send("#{name}") == other.send("#{name}")
      end
      true
    end

    def self.exists?(id)
      request(exists_action, id_params(id), :get, exists_prefix, exists_headers)['exists']
    end

    def self.find(id)
      response = request(find_action, id_params(id), :get, find_prefix, find_headers)
      new(response[entity_name], true)
    end

    def destroy
      without_request_error? do
        response = self.class.request(destroy_action, destroy_params, :delete, destroy_prefix, destroy_headers)
        @persisted = false
      end
    end

    def self.create_objects_array_from_hash (response)
      create_array_from_hash(response[entity_name.pluralize]).map { |hash| new(hash, true) }
    end

    def self.create_array_from_hash (response)
      response = [] if response.nil?
      response = [response] if response.is_a?(Hash)
      response
    end

    alias_method :persisted?, :persisted

    def instance_entity_name
      self.class.entity_name
    end

    protected

    def instance_variable_names
      instance_variables.map { |var| var.to_s }
    end

    def fields
      instance_variable_names.each.collect { |variable| variable.to_s.sub(/@/, '') }
    end

    def variable_names
      instance_variable_names.each.collect { |variable| variable.to_s.sub(/@/, '') }
    end

    def self.valid?(field)
      field.to_s[0] != '@' && (field =~ /attributes!/).nil? && (field.to_s =~ /errors/).nil?
    end

    include CRUDRequestParameters
    extend CRUDRequestParameters::ClassMethods

    def add_error(exception)
      @likeno_errors << exception
    end

    def without_request_error?(&block)
      block.call
      true
    rescue Likeno::Errors::RecordNotFound => error
      raise error
    rescue Likeno::Errors::RequestError => error
      raise error if error.response.status.between?(500, 599)

      response_errors = error.response.body['errors']
      if response_errors.is_a?(Array)
        response_errors.each { |error_msg| add_error(error_msg) }
      elsif !response_errors.nil?
        add_error response_errors
      else
        add_error error
      end

      false
    end

    include HashConverters
  end
end

