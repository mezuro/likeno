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
