'use strict'
const _ = require('lodash')
const assert = require('assert')
const config = require('../services/config')
const log = require('../services/log')('accounts')
const notificationBroadcaster = require('../services/notificationBroadcaster')
const db = require('./db/accounts')
const hashPassword = require('five-bells-shared/utils/hashPassword')
const NotFoundError = require('five-bells-shared/errors/not-found-error')
const UnauthorizedError = require('five-bells-shared/errors/unauthorized-error')

function * getAccounts () {
  const accounts = yield db.getAccounts()
  return accounts.map((account) => account.getDataExternal())
}

function * getConnectors () {
  const accounts = yield db.getConnectorAccounts()
  return accounts.map((account) => account.getDataConnector())
}

function * getAccount (name, requestingUser) {
  log.debug('fetching account name ' + name)

  const canExamine = requestingUser &&
    (requestingUser.name === name || requestingUser.is_admin)
  const account = yield db.getAccount(name)
  if (!account) {
    throw new NotFoundError('Unknown account')
  } else if (account.is_disabled &&
      (requestingUser && !requestingUser.is_admin)) {
    throw new UnauthorizedError('This account is disabled')
  }

  // TODO get rid of this when we start using biginteger math everywhere
  account.balance = Number(account.balance).toString()
  delete account.password_hash
  const data = canExamine
    ? account.getDataExternal() : account.getDataPublic()
  data.ledger = config.getIn(['server', 'base_uri'])
  return data
}

function * setAccount (account, requestingUser) {
  assert(requestingUser)

  if (account.password) {
    account.password_hash = (yield hashPassword(account.password)).toString('base64')
    delete account.password
  }

  const allowedKeys = ['name', 'connector', 'password_hash', 'fingerprint',
    'public_key']
  if (!requestingUser.is_admin && !(requestingUser.name === account.name && (
      _.every(_.keys(account), (key) => _.includes(allowedKeys, key))))) {
    throw new UnauthorizedError('Not authorized')
  }
  const existed = yield db.upsertAccount(account)
  log.debug((existed ? 'updated' : 'created') + ' account name ' +
    account.name)
  return {
    account: account.getDataExternal(),
    existed: existed
  }
}

function subscribeTransfers (account, requestingUser, listener) {
  assert(requestingUser)
  if (!requestingUser.is_admin && !(requestingUser.name === account)) {
    throw new UnauthorizedError('Not authorized')
  }

  log.info('new ws subscriber for ' + account)
  notificationBroadcaster.addListener('transfer-' + account, listener)

  return () => notificationBroadcaster.removeListener('transfer-' + account, listener)
}

module.exports = {
  getAccounts,
  getConnectors,
  getAccount,
  setAccount,
  subscribeTransfers
}
