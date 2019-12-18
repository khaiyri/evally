# frozen_string_literal: true

module V1
  class TemplateUpdaterService
    def initialize(attributes:, template:, user:)
      @attributes = attributes
      @template = template
      @user = user
    end

    def call
      @template if update_template && add_activity
    end

    private

    def update_template
      @template.attributes = template_params

      unless @template.valid?
        raise V1::ErrorResponderService.new(:invalid_record, 422, @template.errors.full_messages)
      end

      @template.save!
    end

    def template_params
      @attributes.permit(
        :name,
        :state,
        sections_attributes: [
          :id, :name, :group, :width, :position, :_destroy, skills: %i[name value needToImpsrove]
        ]
      )
    end

    def add_activity
      @user.activities.create!(
        action: 'update',
        activable: @template,
        activable_name: @template.name
      )
    end
  end
end
