# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::RecruitsController, type: :controller do
  let(:admin) { FactoryBot.create(:user, role: :admin) }

  describe '#show' do
    context 'when unauthorized' do
      it 'responds with 401 error' do
        get :show, params: { id: 1 }
        expect(response).to have_http_status 401
      end
    end

    context 'when authorized' do
      it 'responds with recruit data' do
        recruit = FactoryBot.create(:recruit)

        evaluation = FactoryBot.create(:evaluation_draft_recruit, evaluable: recruit)
        FactoryBot.create(:section, sectionable: evaluation)

        sign_in admin
        get :show, params: { id: recruit.public_recruit_id }

        expect(response).to have_http_status 200
        expect(json_response.keys).to contain_exactly(
          'evaluations', 'evaluation', 'evaluators', 'sections', 'templates', 'comments'
        )
      end
    end
  end

  describe '#webhook' do
    context 'when unauthorized' do
      it 'responds with 401 error' do
        post :webhook, params: { recruit: { public_recruit_id: 1 } }
        expect(response).to have_http_status 401
      end
    end

    context 'when authorized' do
      it 'creates new recruit' do
        recruit_attribtues = FactoryBot.attributes_for(:recruit, evaluator: nil)

        params = {
          recruit: {
            public_recruit_id: recruit_attribtues[:public_recruit_id]
          }
        }

        sign_in admin

        expect do
          post :webhook, params: params
        end.to(change { Recruit.count }.by(1))

        expect(response).to have_http_status 204
      end

      it 'confirms that recruit exists' do
        recruit = FactoryBot.create(:recruit, evaluator: nil)

        params = {
          recruit: {
            public_recruit_id: recruit.public_recruit_id
          }
        }

        sign_in admin

        expect do
          post :webhook, params: params
        end.not_to(change { Recruit.count })

        expect(response).to have_http_status 204
      end

      it 'creates proper notificaions' do
        evaluator = FactoryBot.create(:user, role: :evaluator)
        recruiter = FactoryBot.create(:user, role: :recruiter)

        recruit_attribtues = FactoryBot.attributes_for(:recruit, evaluator_id: evaluator.id)

        params = {
          recruit: {
            public_recruit_id: recruit_attribtues[:public_recruit_id],
            evaluator_id: recruit_attribtues[:evaluator_id]
          }
        }

        sign_in admin

        expect do
          post :webhook, params: params
        end.to(change { Notification.count }.by(2))

        latest_recruit = Recruit.last

        expect(evaluator.notifications.last).to have_attributes(
          action: 'assign_me',
          actor_id: admin.id,
          read_at: nil,
          notifiable: latest_recruit
        )

        expect(recruiter.notifications.last).to have_attributes(
          action: 'assign_evaluator',
          actor_id: admin.id,
          read_at: nil,
          notifiable: latest_recruit
        )
      end

      it 'responds with error if public recruit id blank' do
        params = {
          recruit: {
            public_recruit_id: nil
          }
        }

        sign_in admin
        post :webhook, params: params

        expect(response).to have_http_status 422
      end
    end
  end
end
