# This file is part of KalibroClient
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
require 'helpers/range_methods'

class TestRangeMethods
  attr_reader :beginning, :end

  include RangeMethods
end

describe TestRangeMethods do
  subject { TestRangeMethods.new }

  describe 'range' do
    before do
      subject.beginning = 0
      subject.end = 10
    end

    it 'is expected to instantiate a Range' do
      instantiated_range = subject.range

      expect(instantiated_range).to be_a(Range)
      expect(instantiated_range === 10).to be_falsey
      expect(instantiated_range === 0).to be_truthy
      expect(instantiated_range === Float::INFINITY).to be_falsey
    end
  end

  describe 'beginning=' do
    context 'with a finite value' do
      it 'is expected to set the beginning attribute to the value' do
        subject.beginning = 10
        expect(subject.beginning).to eq(10)
      end
    end

    context 'with a string representing a negative infinity value' do
      it 'is expected to set the beginning attribute to a negative infinity value' do
        subject.beginning = "-INF"
        expect(subject.beginning).to eq(-Float::INFINITY)
      end
    end
  end

  describe 'end=' do
    context 'with a finite value' do
      it 'is expected to set the end attribute to the value' do
        subject.end = 10
        expect(subject.end).to eq(10)
      end
    end

    context 'with a string representing a positive infinity value' do
      it 'is expected to set the end attribute to a positive infinity value' do
        subject.end = "INF"
        expect(subject.end).to eq(Float::INFINITY)
      end
    end
  end
end
