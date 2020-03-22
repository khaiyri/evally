# frozen_string_literal: true

module V2
  class RecruitDocumentsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize!

    def new
      presenter = V2::RecruitDocuments::NewPresenter.new

      render json: V2::RecruitDocuments::NewView.render(presenter), status: :ok
    end

    def create
      create_form.save

      render(
        json: V2::RecruitDocuments::Serializer.render(create_form.recruit_document),
        status: :created
      )
    end

    def edit
      presenter = V2::RecruitDocuments::EditPresenter.new(recruit_document)

      render json: V2::RecruitDocuments::EditView.render(presenter), status: :ok
    end

    def update
      update_form.save

      render(
        json: V2::RecruitDocuments::Serializer.render(update_form.recruit_document),
        status: :ok
      )
    end

    private

    def authorize!
      authorize [:v2, RecruitDocument]
    end

    def recruit_documents_scope
      policy_scope([:v2, RecruitDocument])
    end

    def recruit_document
      @recruit_document ||= recruit_documents_scope.find_by(id: params[:id])
      raise ErrorResponderService.new(:record_not_found, 404) unless @recruit_document

      @recruit_document
    end

    def create_form
      @create_form ||= V2::RecruitDocuments::BasicForm.new(
        RecruitDocument.new,
        params: recruit_document_params,
        user: current_user
      )
    end

    def update_form
      @update_form ||= V2::RecruitDocuments::BasicForm.new(
        recruit_document,
        params: recruit_document_params,
        user: current_user
      )
    end

    def recruit_document_params
      params.require(:recruit_document).permit(
        :first_name, :last_name, :gender, :email, :phone, :position, :group, :received_at, :source,
        :status, :accept_current_process, :accept_future_processes
      )
    end
  end
end
