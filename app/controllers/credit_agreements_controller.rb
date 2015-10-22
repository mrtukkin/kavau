class CreditAgreementsController < ApplicationController
  before_action :set_type
  before_action :set_creditor
  before_action :set_credit_agreement, only: [:show, :edit, :update, :destroy]

  def index
    @credit_agreements = CreditAgreement.all
  end

  def show
    respond_with @credit_agreement
  end

  def new
    @credit_agreement = CreditAgreement.new
    authorize @credit_agreement
    respond_with @credit_agreement
  end

  def edit
    respond_with @credit_agreement
  end

  def create
    @credit_agreement = CreditAgreement.new(credit_agreement_params.merge(creditor: @creditor))
    authorize @credit_agreement
    @credit_agreement.save
    respond_with @credit_agreement, location: @credit_agreement.creditor
  end

  def update
    @credit_agreement.update(credit_agreement_params)
    respond_with @credit_agreement, location: @credit_agreement.creditor
  end

  def destroy
    @credit_agreement.destroy
    respond_with @credit_agreement, location: @credit_agreement.creditor
  end

  private
    def credit_agreement_params
      params[:credit_agreement].permit(policy(@credit_agreement || CreditAgreement.new).permitted_params)
    end

    def set_credit_agreement
      @credit_agreement = CreditAgreement.find(params[:id])
      authorize @credit_agreement
    end

    def set_creditor
      @creditor = @type.find(get_creditor_id)
    end

    def set_type
      @type = type.constantize
    end

    def type
      params[:type]
    end

    def get_creditor_id
      params["#{type.underscore}_id"]
    end
end
