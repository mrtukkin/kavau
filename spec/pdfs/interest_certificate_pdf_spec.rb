require 'rails_helper'

RSpec.describe InterestCertificatePdf do
  include ActionView::Helpers::NumberHelper

  before :each do
    @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
      street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
    @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
      street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber' 
    @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
    @credit_agreement = create :credit_agreement, account: @account, creditor: @creditor
    @deposit = create :deposit, amount: 2000, credit_agreement: @credit_agreement, date: Date.today.beginning_of_year.next_day(30)
    @balance = create :balance, credit_agreement: @credit_agreement, date: Date.today.end_of_year
    @pdf = InterestCertificatePdf.new(@balance)
  end

  it "stores the balance" do
    expect(@pdf.instance_variable_get('@balance')).to eq(@balance)
  end

  it "has the right content" do
    text_analysis = PDF::Inspector::Text.analyze(@pdf.render).strings 
    expect(text_analysis).to include("Zinsbescheinigung für das Jahr #{Date.today.year}")
    expect(text_analysis).to include("Zinssatz: 2,00% p.a.")
    expect(text_analysis).to include("Jahreszinsbetrag #{Date.today.year}: 36,60 €")
  end
end

