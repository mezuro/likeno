module Likeno
  class Base
    extend RequestMethods

    def initialize(attributes = {})
      attributes.each { |field, value| send("#{field}=", value) if self.class.valid?(field) }
      @likeno_errors = []
    end

    def to_hash(options = {})
      hash = {}
      excepts = options[:except].nil? ? [] : options[:except]
      excepts << 'likeno_errors'
      fields.each { |field| field_to_hash(field).merge!(hash) unless excepts.include? field }
      hash
    end

    def self.to_object(value)
      value.is_a?(Hash) ? new(value, true) : value
    end

    def self.to_objects_array(value)
      array = value.is_a?(Array) ? value : [value]
      array.map { |element| to_object element }
    end

    protected

    def instance_variable_names
      instance_variables.map(&:to_s)
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

    def add_error(exception)
      @likeno_errors << exception
    end
  end
end
