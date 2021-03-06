import http from '@utils/http'
import { fetchError } from '@utils/helpers'

import i18n from '@locales/i18n'

import { Evaluation, EvaluationsList } from '@models/evaluation'
import { EmployeesList } from '@models/employee'
import { TemplatesList } from '@models/template'
import { SectionsList } from '@models/section'

const initialState = () => ({
  drafts: new EvaluationsList(),
  draft: new Evaluation(),
  sections: new SectionsList(),
  employees: new EmployeesList(),
  templates: new TemplatesList(),
  loading: true
})

const DraftsModule = {
  namespaced: true,

  state: initialState(),

  getters: {
    drafts: state => state.drafts,
    draft: state => state.draft,
    sections: state => state.sections,
    employees: state => state.employees,
    templates: state => state.templates,
    loading: state => state.loading
  },
  mutations: {
    addToList(state, data) {
      state.drafts.add(data)
      return state
    },
    setItem(state, { draft, sections }) {
      state.draft = new Evaluation(draft)
      state.sections = new SectionsList(sections)
      return state
    },
    setList(state, { drafts, employees, templates }) {
      state.drafts = new EvaluationsList(drafts)
      state.employees = new EmployeesList(employees)
      state.templates = new TemplatesList(templates)
      return state
    },
    setLoading(state, status) {
      state.loading = status
      return state
    },
    removeFromList(state, id) {
      state.draft = new Evaluation()
      state.sections = new SectionsList()
      state.drafts.remove(id)
      return state
    },
    replaceSection(state, section) {
      state.sections.replace(section)
      return state
    },
    resetItem(state) {
      state.draft = new Evaluation()
      state.sections = new SectionsList()
      return state
    },
    resetState(state) {
      state = Object.assign(state, initialState())
      return state
    }
  },
  actions: {
    index({ commit }) {
      commit('setLoading', true)

      http.get(Evaluation.routes.draftsPath)
        .then(response => {
          commit('setList', response.data)
        })
        .catch(error => {
          commit(
            'NotificationsModule/push',
            { error: i18n.t('messages.drafts.index.error', { msg: fetchError(error) }) },
            { root: true }
          )
        })
        .finally(() => commit('setLoading', false))
    },
    show({ commit }, id) {
      http.get(Evaluation.routes.draftPath(id))
        .then(response => {
          commit('setItem', response.data)
        })
        .catch(error => {
          commit(
            'NotificationsModule/push',
            { error: i18n.t('messages.drafts.show.error', { msg: fetchError(error) }) },
            { root: true }
          )
        })
    },
    create({ commit }, { employeeId, templateId, useLatest }) {
      const params = {
        draft: {
          employee_id: employeeId,
          template_id: templateId,
          use_latest: useLatest
        }
      }

      return new Promise(resolve => {
        http.post(Evaluation.routes.draftsPath, params)
          .then(response => {
            const { data } = response

            commit('addToList', data.draft)
            commit(
              'NotificationsModule/push',
              { success: i18n.t('messages.drafts.create.ok') },
              { root: true }
            )

            resolve(data)
          })
          .catch(error => {
            commit(
              'NotificationsModule/push',
              { error: i18n.t('messages.drafts.create.error', { msg: fetchError(error) }) },
              { root: true }
            )
          })
      })
    },
    update({ state, commit }) {
      const { draft, sections } = state;

      const params = {
        draft: {
          sections: sections.models
        }
      }

      return new Promise(resolve => {
        http.put(Evaluation.routes.draftPath(draft.id), params)
          .then(response => {
            commit('setItem', response.data)
            commit(
              'NotificationsModule/push',
              { success: i18n.t('messages.drafts.update.ok') },
              { root: true }
            )

            resolve()
          })
          .catch(error => {
            commit(
              'NotificationsModule/push',
              { error: i18n.t('messages.drafts.update.error', { msg: fetchError(error) }) },
              { root: true }
            )
          })
      })

    },
    complete({ state, commit }, { nextEvaluationDate }) {
      const { draft, sections } = state;

      const params = {
        draft: {
          state: 'completed',
          next_evaluation_on: nextEvaluationDate,
          sections: sections.models
        }
      }

      return new Promise(resolve => {
        http.put(Evaluation.routes.draftPath(draft.id), params)
          .then(() => {
            commit('removeFromList', draft.id)
            commit(
              'NotificationsModule/push',
              { success: i18n.t('messages.drafts.complete.ok') },
              { root: true }
            )

            resolve()
          })
          .catch(error => {
            commit(
              'NotificationsModule/push',
              { error: i18n.t('messages.drafts.complete.error', { msg: fetchError(error) }) },
              { root: true }
            )
          })
      })
    },
    destroy({ state, commit }) {
      const { draft } = state;

      http.delete(Evaluation.routes.draftPath(draft.id))
        .then(() => {
          commit('removeFromList', draft.id)

          commit(
            'NotificationsModule/push',
            { success: i18n.t('messages.drafts.delete.ok') },
            { root: true }
          )
        })
        .catch(error => {
          commit(
            'NotificationsModule/push',
            { error: i18n.t('messages.drafts.delete.error', { msg: fetchError(error) }) },
            { root: true }
          )
        })
    }
  }
}

export default DraftsModule
