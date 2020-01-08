# frozen_string_literal: true

module V2
  class DraftsController < ApplicationController
    before_action :authenticate!

    def index
      drafts = V2::EvaluationsQuery.call(drafts_scope).order(updated_at: :desc)

      render json: V2::EvaluationSerializer.render(drafts), status: :ok
    end

    def show
      presenter = V2::EvaluationPresenter.new(draft)

      render json: V2::Views::DraftView.render(presenter), status: :ok
    end

    def update
      update_form.save
      presenter = V2::EvaluationPresenter.new(update_form.draft)

      render json: V2::Views::DraftView.render(presenter), status: :ok
    end

    def destroy
      ActiveRecord::Base.transaction do
        draft.destroy!

        current_user.activities.create!(
          action: 'destroy',
          activable: draft,
          activable_name: draft.employee.fullname
        )
      end

      head :no_content
    end

    private

    def drafts_scope
      Evaluation.draft
    end

    def draft
      @draft ||= V2::EvaluationsQuery.call(drafts_scope).find_by(id: params[:id])
      raise V1::ErrorResponderService.new(:record_not_found, 404) unless @draft

      @draft
    end

    def update_form
      @update_form ||= V2::DraftUpdateForm.new(
        draft,
        params: update_params,
        user: current_user
      )
    end

    def update_params
      params.require(:draft).permit(
        :state, :next_evaluation_at, sections: [:id, skills: %i[name value needToImprove]]
      )
    end
  end
end
