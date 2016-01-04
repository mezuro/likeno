require 'active_support/inflector'
require 'faraday_middleware'
require 'errors'
require 'helpers/hash_converters'
require 'helpers/crud_request_parameters'

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

    def self.request(action, params = {}, method = :post, prefix = '')
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
          response = self.class.request(save_action, save_params, :post, save_prefix)

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
        self.class.request(update_action, update_params, :put, update_prefix)
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
      request(exists_action, id_params(id), :get)['exists']
    end

    def self.find(id)
      response = request(find_action, id_params(id), :get)
      new(response[entity_name], true)
    end

    def destroy
      without_request_error? do
        response = self.class.request(destroy_action, destroy_params, :delete, destroy_prefix)
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

    def self.address
      raise NotImplementedError
    end

    # TODO: probably the connection could be a class static variable.
    def self.client
      Faraday.new(url: address) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def self.valid?(field)
      field.to_s[0] != '@' && (field =~ /attributes!/).nil? && (field.to_s =~ /errors/).nil?
    end

    def instance_entity_name
      self.class.entity_name
    end

    include CRUDRequestParameters
    extend CRUDRequestParameters::ClassMethods

    def add_error(exception)
      @likeno_errors << exception
    end

    def self.endpoint
      entity_name.pluralize
    end

    def self.entity_name
      # This loop is a generic way to make this work even when the children class has a different name
      entity_class = self
      until entity_class.name.include?('Likeno::')
        entity_class = entity_class.superclass
      end

      entity_class.name.split('::').last.underscore.downcase
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

