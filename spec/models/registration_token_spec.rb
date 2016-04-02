require 'rails_helper'

RSpec.describe RegistrationToken, type: :model do
  before(:all) { Rails.cache.clear }

  describe '#create' do
    context 'with valid user_id' do
      let!(:token) { RegistrationToken.create user_id: 123 }

      it { expect(token.value).to match /\A[a-z0-9]{64}\z/ }
      it { expect(token.user_id).to eq 123 }
      it { expect(token.valid?).to be_truthy }
      it { expect{ token.validate! }.not_to raise_error }
      it { expect(token.cache_key).to match /\Aregistration_token\/#{token.value}\z/ }

      it 'should be stored with user_id' do
        cached_user_id = Rails.cache.read token.cache_key
        expect(cached_user_id).to eq 123
      end

      it 'should be able to #find' do
        found_token = RegistrationToken.find token.value
        expect(found_token.user_id).to eq 123
      end
    end
  end

  describe '#save!' do
    context 'with valid token' do
      let!(:token_value) { '42f21ec2cef42ae441ac8e7d1f372535d3990e9402c89d88d911442516135946' }
      let!(:token) { RegistrationToken.new value: token_value, user_id: 234 }

      it 'should be successful' do
        expect { token.save! }.not_to raise_error
      end

      it 'should be stored with user_id' do
        cached_user_id = Rails.cache.read token.cache_key
        expect(cached_user_id).to eq 234
      end

      it 'should be able to #find' do
        found_token = RegistrationToken.find token_value
        expect(found_token.user_id).to eq 234
      end
    end

    context 'with invalid token' do
      let!(:token_value) { 'foo' }
      let!(:token) { RegistrationToken.new value: token_value, user_id: 345 }

      it 'should be failure' do
        expect { token.save! }.to raise_error RegistrationToken::InvalidToken
      end

      it 'should not be stored' do
        cached_user_id = Rails.cache.read token.cache_key
        expect(cached_user_id).to be_nil
      end

      it 'should not be able to #find' do
        expect {
          RegistrationToken.find token_value
        }.to raise_error RegistrationToken::NotFound
      end
    end
  end

  describe '#delete' do
    context 'with existing token' do
      let!(:token) { RegistrationToken.create user_id: 456 }
      before do
        token.delete
      end

      it do
        expect {
          RegistrationToken.find token.value
        }.to raise_error RegistrationToken::NotFound
      end
    end
  end
end
