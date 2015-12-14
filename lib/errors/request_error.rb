module Likeno
  module Errors
    class RequestError < Standard
      attr_reader :response

      def initialize(attributes={})
        @response = attributes[:response]
      end
    end
  end
end
