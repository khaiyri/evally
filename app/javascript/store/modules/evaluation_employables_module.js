import http from '@utils/http'
import { fetchError } from '@utils/helpers'

import i18n from '@locales/i18n'

import { Evaluation, EvaluationsList } from '@models/evaluation'
import { EmployeesList } from '@models/employee'
import { TemplatesList } from '@models/template'
import { SectionsList } from '@models/section'

const initialState = () => ({
  evaluations: new EvaluationsList(),
  evaluation: new Evaluation(),
  sections: new SectionsList(),
  employees: new EmployeesList(),
  templates: new TemplatesList(),
  loading: true
})

const EvaluationEmployablesModule = {
  namespaced: true,

  state: initialState(),

  getters: {
    evaluations: state => state.evaluations,
    evaluation: state => state.evaluation,
    sections: state => state.sections,
    employees: state => state.employees,
    templates: state => state.templates,
    loading: state => state.loading
  },
  mutations: {
    addToList(state, data) {
      state.evaluations.add(data)
      return state
    },
    setForm(state, { employees, templates }) {
      state.employees = new EmployeesList(employees)
      state.templates = new TemplatesList(templates)
      return state
    },
    setItem(state, { evaluation, sections }) {
      state.evaluation = new Evaluation(evaluation)
      state.sections = new SectionsList(sections)
      return state
    },
    setList(state, evaluations) {
      state.evaluations = new EvaluationsList(evaluations)
      return state
    },
    setLoading(state, status) {
      state.loading = status
      return state
    },
    removeFromList(state, id) {
      state.evaluation = new Evaluation()
      state.sections = new SectionsList()
      state.evaluations.remove(id)
      return state
    },
    replaceSection(state, section) {
      state.sections.replace(section)
      return state
    },
    resetItem(state) {
      state.evaluation = new Evaluation()
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

      http.get(Evaluation.routes.evaluationEmployablesPath)
        .then(response => {
          commit('setList', response.data)
        })
        .catch(error => {
          commit(
            'NotificationsModule/push',
            { error: i18n.t('messages.evaluations.index.error', { msg: fetchError(error) }) },
            { root: true }
          )
        })
        .finally(() => commit('setLoading', false))
    },
    show({ commit }, id) {
      http.get(Evaluation.routes.draftEvaluationEmployablePath(id))
        .then(response => {
          commit('setItem', response.data)
        })
        .catch(error => {
          commit(
            'NotificationsModule/push',
            { error: i18n.t('messages.evaluations.show.error', { msg: fetchError(error) }) },
            { root: true }
          )
        })
    },
    form({ commit }) {
      return new Promise(resolve => {
        http.get(Evaluation.routes.formEvaluationEmployablePath)
          .then(response => {
            commit('setForm', response.data)
            resolve()
          })
          .catch(error => {
            commit(
              'NotificationsModule/push',
              { error: i18n.t('messages.evaluations.show.error', { msg: fetchError(error) }) },
              { root: true }
            )
          })
        })
    },
    create({ commit }, { employeeId, templateId, useLatest }) {
      const params = {
        evaluation: {
          employee_id: employeeId,
          template_id: templateId,
          use_latest: useLatest
        }
      }

      return new Promise(resolve => {
        http.post(Evaluation.routes.evaluationEmployablesPath, params)
          .then(response => {
            const { data } = response

            commit('addToList', data.evaluation)
            commit(
              'NotificationsModule/push',
              { success: i18n.t('messages.evaluations.create.ok') },
              { root: true }
            )

            resolve(data)
          })
          .catch(error => {
            commit(
              'NotificationsModule/push',
              { error: i18n.t('messages.evaluations.create.error', { msg: fetchError(error) }) },
              { root: true }
            )
          })
      })
    },
    update({ state, commit }) {
      const { evaluation, sections } = state;

      const params = {
        evaluation: {
          sections: sections.models
        }
      }

      return new Promise(resolve => {
        http.put(Evaluation.routes.evaluationEmployablePath(evaluation.id), params)
          .then(response => {
            commit('setItem', response.data)
            commit(
              'NotificationsModule/push',
              { success: i18n.t('messages.evaluations.update.ok') },
              { root: true }
            )

            resolve()
          })
          .catch(error => {
            commit(
              'NotificationsModule/push',
              { error: i18n.t('messages.evaluations.update.error', { msg: fetchError(error) }) },
              { root: true }
            )
          })
      })

    },
    complete({ state, commit }, { nextEvaluationDate }) {
      const { evaluation, sections } = state;

      const params = {
        evaluation: {
          state: 'completed',
          next_evaluation_on: nextEvaluationDate,
          sections: sections.models
        }
      }

      return new Promise(resolve => {
        http.put(Evaluation.routes.evaluationEmployablePath(evaluation.id), params)
          .then(() => {
            commit('removeFromList', evaluation.id)
            commit(
              'NotificationsModule/push',
              { success: i18n.t('messages.evaluations.complete.ok') },
              { root: true }
            )

            resolve()
          })
          .catch(error => {
            commit(
              'NotificationsModule/push',
              { error: i18n.t('messages.evaluations.complete.error', { msg: fetchError(error) }) },
              { root: true }
            )
          })
      })
    },
    destroy({ state, commit }) {
      const { evaluation } = state;

      http.delete(Evaluation.routes.evaluationEmployablePath(evaluation.id))
        .then(() => {
          commit('removeFromList', evaluation.id)

          commit(
            'NotificationsModule/push',
            { success: i18n.t('messages.evaluations.delete.ok') },
            { root: true }
          )
        })
        .catch(error => {
          commit(
            'NotificationsModule/push',
            { error: i18n.t('messages.evaluations.delete.error', { msg: fetchError(error) }) },
            { root: true }
          )
        })
    }
  }
}

export default EvaluationEmployablesModule