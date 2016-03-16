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
require 'spec_helper'

describe Likeno::Errors::RecordInvalid do
  describe 'initialize' do
    let(:default_message) { 'Record invalid' }

    context 'without a record' do
      subject { described_class.new }

      it 'is expected to have the default message' do
        expect(subject.message).to eq(default_message)
      end
    end

    context 'with a given record' do
      let!(:record) { mock('record') }
      let!(:likeno_errors) { %w(Likeno Error) }
      subject { described_class.new(record) }

      before :each do
        record.expects(:likeno_errors).returns(likeno_errors)
      end

      it 'is expected to return the default message concatenated with the errors' do
        expect(subject.message).to eq("#{default_message}: #{likeno_errors.join(', ')}")
      end
    end
  end
end
