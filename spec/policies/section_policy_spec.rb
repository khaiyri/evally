# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::SectionPolicy, type: :policy do
  describe 'scope' do
    it 'returns correct scope' do
      admin = FactoryBot.create(:user, role: 'admin')
      recruiter = FactoryBot.create(:user, role: 'recruiter')
      evaluator = FactoryBot.create(:user, role: 'evaluator')

      recruit_document = FactoryBot.create(:recruit_document)
      evaluation = FactoryBot.create(:evaluation_draft_recruit, evaluable: recruit_document.recruit)

      open_section = FactoryBot.create(:section, sectionable: evaluation, sensitive: false)
      sensitive_section = FactoryBot.create(:section, sectionable: evaluation, sensitive: true)

      aggregate_failures 'for admin' do
        scope = Pundit.policy_scope!(admin, [:v2, evaluation.sections])

        expect(scope.ids).to contain_exactly(open_section.id, sensitive_section.id)
      end

      aggregate_failures 'for recruiter' do
        scope = Pundit.policy_scope!(recruiter, [:v2, evaluation.sections])

        expect(scope.ids).to contain_exactly(open_section.id, sensitive_section.id)
      end

      aggregate_failures 'for evaluator' do
        scope = Pundit.policy_scope!(evaluator, [:v2, evaluation.sections])

        expect(scope.ids).to contain_exactly(open_section.id)
      end
    end
  end
end
