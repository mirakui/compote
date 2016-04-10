require 'rails_helper'

RSpec.describe RegistrationController, type: :controller do
  describe 'GET /signup' do
    before { get :new }
    it { expect(response).to have_http_status(200) }
  end

  describe 'POST /signup' do
    before do
      expect(User.find_by_email '1@example.com').to be_nil
    end

    it 'should create new user when the params are valid' do
      post :create, user: {
        email: '1@example.com',
        password: 'test123',
        password_confirmation: 'test123'
      }

      expect(response).to have_http_status(302)
      expect(User.find_by_email '1@example.com').not_to be_nil
    end

    it 'should not create any user when the password is short' do
      post :create, user: {
        email: '1@example.com',
        password: 'test',
        password_confirmation: 'test'
      }

      #expect(response).to have_http_status(302)
      expect(User.find_by_email '1@example.com').to be_nil
    end
  end
end
