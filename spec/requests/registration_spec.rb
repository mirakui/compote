require 'rails_helper'

RSpec.describe 'User Registration', type: :request do
  describe 'GET /signup' do
    before { get '/signup' }
    it { expect(response).to have_http_status(200) }
  end

  describe 'POST /signup' do
    before do
      expect(User.find_by_email '1@example.com').to be_nil
    end

    it 'should create new user when the params are valid' do
      post '/signup',
        'user[email]' => '1@example.com',
        'user[password]' => 'test123',
        'user[password_confirmation]' => 'test123'

      expect(response).to have_http_status(302)
      expect(User.find_by_email '1@example.com').not_to be_nil
    end

    it 'should not create any user when the password is short' do
      post '/signup',
        'user[email]' => '1@example.com',
        'user[password]' => 'test',
        'user[password_confirmation]' => 'test'

      #expect(response).to have_http_status(302)
      expect(User.find_by_email '1@example.com').to be_nil
    end
  end
end
