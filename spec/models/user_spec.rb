require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(email: 'test@example.com', password: 'password', first_name: 'Test User')
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user = User.new(email: 'test@example.com', password: 'password', first_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end
  end
end