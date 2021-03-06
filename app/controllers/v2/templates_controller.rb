# frozen_string_literal: true

module V2
  class TemplatesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize!, only: %i[update destroy]

    def index
      templates = Template.includes(:creator).order(name: :asc)

      render json: V2::TemplateSerializer.render(templates), status: :ok
    end

    def show
      presenter = V2::TemplatePresenter.new(template)

      render json: V2::Views::TemplateView.render(presenter), status: :ok
    end

    def create
      create_form.save
      presenter = V2::TemplatePresenter.new(create_form.template)

      render json: V2::Views::TemplateView.render(presenter), status: :created
    end

    def update
      update_form.save
      presenter = V2::TemplatePresenter.new(update_form.template)

      render json: V2::Views::TemplateView.render(presenter), status: :ok
    end

    def destroy
      ActiveRecord::Base.transaction do
        template.destroy!

        current_user.activities.create!(
          action: 'destroy',
          activable: template,
          activable_name: template.name
        )
      end

      head :no_content
    end

    private

    def authorize!
      authorize [:v2, template]
    end

    def template
      @template ||= Template.find_by(id: params[:id])
      raise ErrorResponderService.new(:record_not_found, 404) unless @template

      @template
    end

    def create_form
      @create_form ||= V2::TemplateForm.new(
        current_user.templates.build,
        params: create_params,
        user: current_user
      )
    end

    def update_form
      @update_form ||= V2::TemplateForm.new(
        template,
        params: update_params,
        user: current_user
      )
    end

    def create_params
      params.require(:template).permit(
        :name, sections: [:name, :width, :group, :position, skills: %i[name value needToImprove]]
      )
    end

    def update_params
      params.require(:template).permit(
        :name, sections: [
          :id, :name, :group, :width, :position, :_destroy, skills: %i[name value needToImpsrove]
        ]
      )
    end
  end
end
