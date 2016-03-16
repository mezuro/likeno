require 'spec_helper'
require 'likeno/helpers/date_attributes'

include Likeno::DateAttributes

class Klass
  include Likeno::DateAttributes
end


describe Likeno::DateAttributes do
  subject { Klass.new }
  let(:time){ "2015-02-04T15:53:18.452Z" }

  describe 'created_at=' do
    it 'is expected to parse it to DateTime' do
      DateTime.expects(:parse).with(time)

      subject.created_at = time
    end
  end

  describe 'updated_at=' do
    it 'is expected to parse it to DateTime' do
      DateTime.expects(:parse).with(time)

      subject.updated_at = time
    end
  end
end
