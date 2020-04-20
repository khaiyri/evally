import store from '@store/store'

export const alreadyAuthenticatedGuard = (_to, _from, next) => {
  localStorage.getItem('ev411y_t0k3n') ? next({ name: 'dashboard_path' }) : next()
}

export const authenticationGuard = (_to, _from, next) => {
  if (localStorage.getItem('ev411y_t0k3n')) next()
  else {
    store.commit(
      'NotificationsModule/PUSH_NOTIFICATION',
      { error: 'You are not authenticated. Please log in.' }
    )

    next({ name: 'login_path' })
  }
}

export const authorizationGuard = (_to, from, next) => {
  const user = store.state.AuthenticationModule.user

  user.isAdmin ? next() : next({ name: from.name })
}
