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

# Create a class that has the attribute assignment methods, since some methods expect they exist
# (and usually the subclasses do that).

class EntityTest < Likeno::Entity
  attr_accessor :id, :created_at, :updated_at
end

describe Likeno::Entity do
  subject { EntityTest.new }

  describe 'new' do
    subject { described_class.new({}) }

    it 'is expected to create a model from an empty hash' do
      expect(subject.likeno_errors).to eq([])
    end
  end

  describe 'to_hash' do
    it 'is expected to return an empty hash' do
      expect(subject.to_hash).to be_empty
    end
  end

  describe 'to_object' do
    it 'is expected to return an Object with an empty hash' do
      expect(described_class.to_object({})).to eq(FactoryGirl.build(:model))
    end

    it "is expected to remain an object if it isn't a Hash" do
      expect(described_class.to_object(Object.new)).to be_an(Object)
    end
  end

  describe 'to_objects_array' do
    it 'is expected to convert [{}] to [Model]' do
      expect(described_class.to_objects_array({})).to eq([FactoryGirl.build(:model)])
    end

    it 'is expected to remain an array if it already is one' do
      object = Object.new
      expect(described_class.to_objects_array([object])).to eq([object])
    end
  end

  shared_examples 'persistence method' do |method_name, http_method, has_id = true|
    before :each do
      subject.id = 42 if has_id
    end

    let(:url) { has_id ? ':id' : '' }
    let(:params) { has_id ? has_entry(id: 42) : anything }

    context 'when a record does not exist with given id' do
      before :each do
        subject.class.expects(:request).with(url, params, http_method, '')
          .raises(Likeno::Errors::RecordNotFound)
      end

      it 'is expected to raise a RecordNotFound error' do
        expect { subject.send(method_name) }.to raise_error(Likeno::Errors::RecordNotFound)
      end
    end

    context 'when a server error is returned' do
      before :each do
        error = Likeno::Errors::RequestError.new(response: mock(status: 500))

        subject.class.expects(:request).with(url, params, http_method, '').raises(error)
      end

      it 'is expected to raise a RequestError error' do
        expect { subject.send(method_name) }.to raise_error(Likeno::Errors::RequestError)
      end
    end

    context 'when a regular kind of error is returned' do
      before :each do
        error = Likeno::Errors::RequestError.new(response: mock(status: 422, body: { 'errors' => errors }))

        subject.class.expects(:request).with(url, params, http_method, '').raises(error)
      end

      context 'with a single error' do
        let(:errors) { 'error' }

        it 'is expected to set the likeno_errors field' do
          expect(subject.send(method_name)).to eq(false)
          expect(subject.likeno_errors).to eq([errors])
        end
      end

      context 'with an array of errors' do
        let(:errors) { %w(error_1 error_2) }

        it 'is expected to set the likeno_errors field' do
          expect(subject.send(method_name)).to eq(false)
          expect(subject.likeno_errors).to eq(errors)
        end
      end

      context 'with no error message at all' do
        let(:errors) { nil }

        it 'is expected to set the likeno_errors field' do
          expect(subject.send(method_name)).to eq(false)
          expect(subject.likeno_errors.first).to be_a(Likeno::Errors::RequestError)
        end
      end
    end
  end

  describe 'save' do
    context 'persistance' do
      before :each do
        subject.expects(:instance_entity_name).at_least_once.returns('entity')
      end

      it_behaves_like 'persistence method', :save, :post, false # false means Don't use ids in URLs
    end

    context 'with a successful response' do
      context 'when it is not persisted' do
        before :each do
          subject.expects(:instance_entity_name).at_least_once.returns('entity')
          subject.class.expects(:request).at_least_once.with('', anything, :post, '')
            .returns('entity' => { 'id' => 42, 'errors' => [] })
        end

        it 'is expected to make a request to save model with id and return true without errors' do
          expect(subject.save).to be(true)
          expect(subject.id).to eq(42)
          expect(subject.likeno_errors).to be_empty
        end
      end

      context 'when it is persisted' do
        before :each do
          subject.expects(:persisted?).at_least_once.returns(true)
        end

        it 'is expected to call the update method' do
          subject.expects(:update).returns(true)
          expect(subject.save).to eq(true)
        end
      end
    end
  end

  describe 'update' do
    before :each do
      subject.expects(:instance_entity_name).at_least_once.returns('entity')
    end

    it_behaves_like 'persistence method', :update, :put

    context 'with valid parameters' do
      before :each do
        id = 42

        subject.expects(:id).at_least_once.returns(id)
        described_class.expects(:request).with(':id', has_entry(id: id), :put, '')
          .returns('entity' => { 'id' => id, 'errors' => [] })
      end

      it 'is expected to return true' do
        expect(subject.update).to eq(true)
      end
    end
  end

  describe 'create' do
    before :each do
      subject.expects(:save)
      described_class
        .expects(:new)
        .with({})
        .returns(subject)
    end

    it 'is expected to instantiate and save the model' do
      expect(described_class.create {}).to eq(subject)
    end
  end

  describe 'find' do
    let(:prefix) { '' }
    let(:header) { {} }

    context 'with an inexistent id' do
      before :each do
        subject.class.expects(:request).at_least_once.with(':id', has_entry(id: 0), :get, prefix, header)
          .raises(Likeno::Errors::RecordNotFound)
      end

      it 'is expected to raise a RecordNotFound error' do
        expect { subject.class.find(0) }.to raise_error(Likeno::Errors::RecordNotFound)
      end
    end

    context 'with an existent id' do
      before :each do
        subject.class.expects(:entity_name).at_least_once.returns('entity')
        subject.class.expects(:request).with(':id', has_entry(id: 42), :get, prefix, header)
          .returns('entity' => { 'id' => 42 })
      end

      it 'is expected to return an empty model' do
        expect(subject.class.find(42).id).to eq(42)
      end
    end
    context 'passing a prefix and a header' do
      let(:header) { { locale: 'pt_br' } }

      before :each do
        subject.class.expects(:entity_name).at_least_once.returns('entity')
        subject.class.expects(:request)
          .with(':id', has_entry(id: 42), :get, prefix, header)
          .returns('entity' => { 'id' => 42 })
      end

      it 'is expected to return an empty model' do
        expect(subject.class.find(42, prefix, header).id).to eq(42)
      end
    end
  end
  end

  describe 'destroy' do
    it_behaves_like 'persistence method', :destroy, :delete

    context 'when it gets successfully destroyed' do
      before :each do
        subject.expects(:id).at_least_once.returns(42)
        described_class.expects(:request).with(':id', { id: subject.id }, :delete, '').returns({})
      end

      it 'is expected to remain with the errors array empty and not persisted' do
        subject.destroy
        expect(subject.likeno_errors).to be_empty
        expect(subject.persisted?).to eq(false)
      end
    end
  end

  describe 'save!' do
    it 'is expected to call save and not raise when saving works' do
      subject.expects(:save).returns(true)
      expect { subject.save! }.not_to raise_error
    end

    it 'is expected to call save and raise RecordInvalid when saving fails' do
      subject.expects(:likeno_errors).returns %w(test1 test2)
      subject.expects(:save).returns(false)

      expect { subject.save! }.to raise_error { |error|
        expect(error).to be_a(Likeno::Errors::RecordInvalid)
        expect(error.record).to be(subject)
        expect(error.message).to eq('Record invalid: test1, test2')
      }
    end
  end

  describe '==' do
    subject { FactoryGirl.build(:model) }

    context 'comparing objects from different classes' do
      it 'is expected to return false' do
        expect(subject).not_to eq(Object.new)
      end
    end

    context 'with two models with different attribute values' do
      let(:another_model) { FactoryGirl.build(:model) }

      before :each do
        subject.expects(:variable_names).returns(['answer'])
        subject.expects(:send).with('answer').returns(42)
        another_model.expects(:send).with('answer').returns(41)
      end

      it 'is expected to return false' do
        expect(subject).not_to eq(another_model)
      end
    end

    context 'with two empty models' do
      it 'is expected to return true' do
        expect(subject).to eq(FactoryGirl.build(:model))
      end
    end
  end

  describe 'exists?' do
    context 'with an inexistent id' do
      before :each do
        described_class
          .expects(:request)
          .with(':id/exists', { id: 0 }, :get)
          .returns('exists' => false)
      end

      it 'is expected to return false' do
        expect(described_class.exists?(0)).to eq(false)
      end
    end

    context 'with an existent id' do
      before :each do
        described_class
          .expects(:request)
          .with(':id/exists', { id: 42 }, :get)
          .returns('exists' => true)
      end

      it 'is expected to return false' do
        expect(described_class.exists?(42)).to eq(true)
      end
    end
  end

  describe 'create_objects_array_from_hash' do
    subject { FactoryGirl.build(:model) }

    context 'with nil' do
      before :each do
        described_class.expects(:entity_name).at_least_once.returns('entity')
      end

      it 'is expected to return an empty array' do
        expect(described_class.create_objects_array_from_hash('entities' => [])).to eq([])
      end
    end

    context 'with a Hash' do
      before :each do
        described_class.expects(:entity_name).at_least_once.returns('entity')
      end

      it 'is expected to return the correspondent object to the given hash inside of an Array' do
        expect(described_class.create_objects_array_from_hash('entities' => {})).to eq([subject])
      end
    end
  end

  describe 'valid?' do
    context 'with a global var' do
      it 'is expected to return false' do
        expect(described_class.valid?('@test')).to be_falsey
      end
    end

    context 'with the attributes var' do
      it 'is expected to return false' do
        expect(described_class.valid?(:attributes!)).to be_falsey
      end
    end

    context 'with a valid var' do
      it 'is expected to return true' do
        expect(described_class.valid?('test')).to be_truthy
      end
    end
  end

  describe 'instance_entity_name' do
    it 'is expected to call its class equivalent method' do
      subject.class.expects(:entity_name).returns('entities')
      expect(subject.instance_entity_name)
    end
  end
end
