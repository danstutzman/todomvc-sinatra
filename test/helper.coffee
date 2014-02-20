assert      = require 'assert'
prettyPrint = require('html').prettyPrint
React       = require 'react'

if typeof(document) == 'undefined'
  assertRendersHtml = (reactComponent, done, expectedHtml) ->
    React.renderComponentToString reactComponent, (html) ->
      html = html.replace /data-reactid="(.*?)"/g, ''
      html = html.replace /data-react-checksum="(.*?)"/g, ''
      html = prettyPrint html, indent_size: 2, unformatted: []
      assert.equal html, expectedHtml
      done()
else
  assertRendersHtml = (reactComponent, done, expectedHtml) ->
    div = document.createElement('div')
    body = window.document.getElementsByTagName('body')[0]
    body.appendChild(div)
    React.renderComponent reactComponent, div
    div.parentNode.removeChild div
    done()

module.exports = { assertRendersHtml }
