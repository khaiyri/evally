import Vue from 'vue'
import Vuetify from 'vuetify'

Vue.use(Vuetify)

import en from 'vuetify/lib/locale/en'
import pl from 'vuetify/lib/locale/pl'

export default new Vuetify({
  lang: {
    locales: { en, pl },
    current: 'en'
  },
  theme: {
    dark: false,
    themes: {
      light: {
        primary: '#4169E1', //DODGERBLUE
        secondary: '#BA55D3', // MEDIUMORCHID
        accent: '#87CEFA', // LIGHTSKYBLUE
        error: '#FF5252',
        info: '#2196F3',
        success: '#4CAF50',
        warning: '#FFC107',
      }
    }
  }
})
