'use strict'

const App = require('../lib/app')
module.exports = new App({
  log: require('./log'),
  config: require('./config'),
  db: require('./db'),
  timerWorker: require('./timerWorker'),
  notificationBroadcaster: require('./notificationBroadcaster')
})
