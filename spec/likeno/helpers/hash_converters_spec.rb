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
require 'likeno/helpers/hash_converters'

include Likeno::HashConverters

class Another
  attr_accessor :attr

  def to_hash
    {'attr' => self.attr}
  end
end

describe Likeno::HashConverters do
  describe 'date_time_to_s' do
    context 'with 21/12/1995 (first Ruby publication)' do
      it 'is expected to return 1995-12-21T00:00:00.0/1+00:00' do
        expect(date_time_to_s(DateTime.parse('21/12/1995'))).to eq('1995-12-21T00:00:00.0/1+00:00')
      end
    end
  end

  describe 'convert_to_hash' do
    context 'with a nil value' do
      it 'returns nil' do
        expect(convert_to_hash(nil)).to be_nil
      end
    end

    context 'with an Array' do
      let(:array) { [] }
      let(:element1) { :likeno }

      before :each do
        array << element1
      end

      it 'returns the Array wth its elements converted' do
        expect(convert_to_hash(array).first).to eq(element1.to_s)
      end
    end

    context 'with a Base' do
      let(:model) { FactoryGirl.build(:model) }

      it "returns the Base's Hash" do
        expect(convert_to_hash(model)).to eq(model.to_hash)
      end
    end

    context 'with a DateTime' do
      let(:date) { DateTime.parse('21/12/1995') }

      it 'returns the date with miliseconds' do
        expect(convert_to_hash(date)).to eq(date_time_to_s(date))
      end
    end

    context 'with a positive infinite Float' do
      it 'returns INF' do
        expect(convert_to_hash(1.0 / 0.0)).to eq('INF')
      end
    end

    context 'with a negative infinite Float' do
      it 'returns -INF' do
        expect(convert_to_hash(-1.0 / 0.0)).to eq('-INF')
      end
    end

    context 'without a base class that responds to to_hash' do
      let(:obj) { Another.new }

      before do
        obj.attr = "attribute"
      end

      it 'is expected to do the conversion' do
        expect(convert_to_hash(obj)).to eq({'attr' => obj.attr})
      end
    end
  end

  describe 'field_to_hash' do
    let(:model) { FactoryGirl.build(:model) }

    context 'with a nil field value' do
      before do
        model.expects(:send).with(:field_getter).returns(nil)
      end

      it 'returns an instance of Hash' do
        expect(model.field_to_hash(:field_getter)).to be_a(Hash)
      end

      it 'returns an empty Hash' do
        expect(model.field_to_hash(:field_getter)).to eq({})
      end
    end

    context 'with a Float field value' do
      before do
        model.expects(:send).with(:field_getter).returns(1.0)
      end

      it 'returns an instance of Hash' do
        expect(model.field_to_hash(:field_getter)).to be_a(Hash)
      end
    end
  end
end
