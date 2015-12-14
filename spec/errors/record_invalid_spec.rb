# This file is part of Likeno
# Copyright (C) 2013  it's respectives authors (please see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'

describe Likeno::Errors::RecordInvalid do
  describe 'initialize' do
    let(:default_message){ "Record invalid" }

    context 'without a record' do
      subject { Likeno::Errors::RecordInvalid.new }

      it 'is expected to have the default message' do
        expect(subject.message).to eq(default_message)
      end
    end

    context 'with a given record' do
      let!(:record) { mock('record') }
      let!(:kalibro_errors) { ['Kalibro', 'Error'] }
      subject { Likeno::Errors::RecordInvalid.new(record) }

      before :each do
        record.expects(:kalibro_errors).returns(kalibro_errors)
      end

      it 'is expected to return the default message concatenated with the errors' do
        expect(subject.message).to eq("#{default_message}: #{kalibro_errors.join(', ')}")
      end
    end
  end
end
