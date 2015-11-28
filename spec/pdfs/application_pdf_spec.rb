require 'rails_helper'

RSpec.describe ApplicationPdf do
  before :each do
    @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
      street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
    @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
      street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber' 
    @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
    #@credit_agreement = create :credit_agreement, account: @account, creditor: @creditor
    #@balance = create :balance, credit_agreement: @credit_agreement
    @pdf = ApplicationPdf.new(@project_address, @creditor)
  end

  let(:text_analysis){ PDF::Inspector::Text.analyze(@pdf.render).strings }

  it "stores sender and recipient" do
    expect(@pdf.instance_variable_get('@sender').model).to eq(@project_address)
    expect(@pdf.instance_variable_get('@recipient').model).to eq(@creditor)
    expect(@pdf.instance_variable_get('@date')).to eq(Date.today)
  end

  it "includes sender, recipient and date" do
    expect(text_analysis).to include('Das Projekt GmbH, Weg 1, 7800 Städtl')
    expect(text_analysis).to include('Dr. Albert Meier')
    expect(text_analysis).to include('Strasse 1')
    expect(text_analysis).to include('79100 Freiburg')
    expect(text_analysis).to include('Deutschland')
    expect(text_analysis).to include(I18n.l(Date.today))
  end

  it "includes the senders contact information" do
    pending 'pdf-inspector does not find contact_information!!!'
    expect(text_analysis).to include('info@example.org')
  end

  it "includes banking info" do
    pending 'pdf-inspector does not find footer!!!'
    expect(text_analysis).to include('DiBaDu')
  end

end