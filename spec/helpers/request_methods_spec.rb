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
require 'helpers/request_methods'

class Likeno::BaseTestRequester
  extend RequestMethods
end

class TestRequester < Likeno::BaseTestRequester; end

describe 'RequestMethods' do
  describe 'module_name' do
    it 'is expected to raise a NotImplemented error' do
      expect {TestRequester.module_name}.to raise_error NotImplementedError
    end
  end

  describe 'entity_name' do
    before :each do
      TestRequester.expects(:module_name).at_least_once.returns('Likeno')
    end

    it 'is expected to be a String' do
      expect(TestRequester.entity_name).to be_a(String)
    end

    it 'is expected to return Entity' do
      expect(TestRequester.entity_name).to eq('base_test_requester')
    end
  end

  describe 'endpoint' do
    it 'is expected to return the entity_name' do
      endpoint = 'tests'
      TestRequester.expects(:entity_name).returns(endpoint)
      expect(TestRequester.endpoint).to eq(endpoint)
    end
  end

  describe 'client' do
    context 'without a defined address' do
      it 'raises a NotImplementedError' do
        expect { TestRequester.client }.to raise_error(NotImplementedError)
      end
    end

    context 'with a defined address' do
      let(:address) { 'http://localhost:3000' }

      before do
        TestRequester.expects(:address).returns(address)
      end

      it 'returns a Faraday::Connection' do
        expect(TestRequester.client).to be_a(Faraday::Connection)
      end
    end
  end

  describe 'request' do
    context 'with successful responses' do
      let(:exists_response) { { 'exists' => false } }
      let(:entities_response) { { 'entities' => { 'id' => 1 } } }
      let(:prefix_entities_response) { { 'entities' => { 'id' => 2 } } }
      let(:faraday_stubs) { Faraday::Adapter::Test::Stubs.new }
      let(:connection) { Faraday.new { |builder| builder.adapter :test, faraday_stubs } }

      before :each do
        TestRequester.expects(:client).at_least_once.returns(connection)
        TestRequester.expects(:endpoint).at_least_once.returns('entities')
      end

      after :each do
        faraday_stubs.verify_stubbed_calls
      end

      context 'without an id parameter' do
        context 'without a prefix' do
          it 'is expected to make the request without the prefix' do
            # stub.get receives arguments: path, headers, block
            # The block should be a Array [status, headers, body]
            faraday_stubs.get('/entities/') { [200, {}, entities_response] }
            response = TestRequester.request('', {}, :get)
            expect(response).to eq(entities_response)
          end
        end

        context 'with a prefix' do
          it 'is expected to make the request with the prefix' do
            # stub.get receives arguments: path, headers, block
            # The block should be a Array [status, headers, body]
            faraday_stubs.get('/prefix/entities/') { [200, {}, prefix_entities_response] }
            response = TestRequester.request('', {}, :get, 'prefix')
            expect(response).to eq(prefix_entities_response)
          end
        end
      end

      context 'with an id parameter' do
        it 'is expected to make the request with the id included' do
          # stub.get receives arguments: path, headers, block
          # The block should be a Array [status, headers, body]
          faraday_stubs.get('/entities/1/exists') { [200, {}, exists_response] }
          response = TestRequester.request(':id/exists', { id: 1 }, :get)
          expect(response).to eq(exists_response)
        end
      end
    end

    context 'when the record was not found' do
      context "and the response doesn't have a NotFound error message" do
        let!(:faraday_stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            # stub.get receives arguments: path, headers, block
            # The block should be a Array [status, headers, body]
            stub.get('/entities/1') { [404, {}, {}] }
          end
        end
        let!(:connection) { Faraday.new { |builder| builder.adapter :test, faraday_stubs } }

        before :each do
          TestRequester.expects(:client).at_least_once.returns(connection)
          TestRequester.expects(:endpoint).at_least_once.returns('entities')
        end

        it 'is expected to raise a RecordNotFound error' do
          expect { TestRequester.request(':id', { id: 1 }, :get) }.to raise_error(Likeno::Errors::RecordNotFound)
          faraday_stubs.verify_stubbed_calls
        end
      end

      context 'and the response has a NotFound error message' do
        let(:error_message) { { 'errors' => 'RecordNotFound' } }
        let!(:faraday_stubs) do
          Faraday::Adapter::Test::Stubs.new do |stub|
            # stub.get receives arguments: path, headers, block
            # The block should be a Array [status, headers, body]
            stub.get('/entities/1') { [404, {}, error_message] }
          end
        end
        let!(:connection) { Faraday.new { |builder| builder.adapter :test, faraday_stubs } }

        before :each do
          TestRequester.expects(:client).at_least_once.returns(connection)
          TestRequester.expects(:endpoint).at_least_once.returns('entities')
        end

        it 'is expected to raise a RecordNotFound error with the message' do
          expect { TestRequester.request(':id', { id: 1 }, :get) }.to raise_error do |error|
            expect(error).to be_a(Likeno::Errors::RecordNotFound)
            expect(error.response.body).to eq error_message
          end
          faraday_stubs.verify_stubbed_calls
        end
      end
    end

    context 'with an unsuccessful request' do
      context 'and no error message on the response' do
        let!(:stubs) { Faraday::Adapter::Test::Stubs.new { |stub| stub.get('/entities/1/exists') { [500, {}, {}] } } }
        let(:connection) { Faraday.new { |builder| builder.adapter :test, stubs } }

        before :each do
          TestRequester.expects(:client).at_least_once.returns(connection)
          TestRequester.expects(:endpoint).at_least_once.returns('entities')
        end

        it 'is expected to raise a RequestError with the response habing an empty body' do
          expect { TestRequester.request(':id/exists', { id: 1 }, :get) }.to raise_error do |error|
            expect(error).to be_a(Likeno::Errors::RequestError)
            expect(error.response.status).to eq(500)
            expect(error.response.body).to eq({})
          end
          stubs.verify_stubbed_calls
        end
      end

      context 'with an error message on the response' do
        let(:error_message) { { 'error' => 'InternalServerError'} }
        let!(:stubs) { Faraday::Adapter::Test::Stubs.new { |stub| stub.get('/entities/1/exists') { [500, {}, error_message] } } }
        let(:connection) { Faraday.new { |builder| builder.adapter :test, stubs } }

        before :each do
          TestRequester.expects(:client).at_least_once.returns(connection)
          TestRequester.expects(:endpoint).at_least_once.returns('entities')
        end

        it 'is expected to raise a RequestError with the response and its error message' do
          expect { TestRequester.request(':id/exists', { id: 1 }, :get) }.to raise_error do |error|
            expect(error).to be_a(Likeno::Errors::RequestError)
            expect(error.response.status).to eq(500)
            expect(error.response.body).to eq(error_message)
          end
          stubs.verify_stubbed_calls
        end
      end
    end
  end
end
