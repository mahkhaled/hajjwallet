require 'spec_helper'

describe EmailValidator do
  class Tester
    include ActiveModel::Validations
    attr_accessor :email_address
    validates :email_address, email: true
  end

  let(:valid_emails) do [
    'valid@email.com',
    'valid@email.com.uk',
    'e@email.com',
    'valid+email@email.com',
    'valid-email@email.com',
    'valid_email@email.com',
    'validemail_@email.com',
    'valid.email@email.com',
    'valid.email@email.photography'
  ]
  end
  let(:invalid_emails) do [
    '',
    ' ',
    'invalid email@email.com',
    'invalidemail @email.com',
    '@email.com',
    'invalidemailemail.com',
    '@invalid.email@email.com',
    'invalid@email@email.com',
    'invalid.email@@email.com'
  ]
  end

  it 'validates valid email addresses' do
    tester = Tester.new
    valid_emails.each do |email|
      tester.email_address = email
      expect(tester.valid?).to be true
    end
  end

  it 'validates invalid email addresses' do
    tester = Tester.new
    invalid_emails.each do |email|
      tester.email_address = email
      expect(tester.valid?).to be false
    end
  end
end
