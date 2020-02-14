import axios from 'axios'

import store from '@store/store'
import router from '@router/router'

// Request interceptor
axios.interceptors.request.use(config => {

  config.baseURL = `${window.location.origin}/${localStorage.getItem('ev411y_l4ng') || 'en'}`
  config.headers.common['Content-Type'] = 'application/json'

  const token = localStorage.getItem('ev411y_t0k3n')
  if (token) config.headers.common['Authorization'] = 'Bearer ' + token

  config.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  return config;
}, error => {
  return Promise.reject(error);
})

// Response interceptor
axios.interceptors.response.use(response => {
  return response
}, error => {
  if (error.response.status === 401) {
    store.commit('SessionModule/clearStore')

    router.push({ name: 'login_path' })
    localStorage.removeItem('ev411y_t0k3n')
  }

  return Promise.reject(error)
})

export default axios