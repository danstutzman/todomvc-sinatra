assert      = require 'assert'
prettyPrint = require('html').prettyPrint
React       = require 'react'

assertRendersHtml = (reactComponent, done, expectedHtml) ->
  React.renderComponentToString reactComponent, (html) ->
    html = html.replace /data-reactid="(.*?)"/g, ''
    html = html.replace /data-react-checksum="(.*?)"/g, ''
    html = prettyPrint html, indent_size: 2, unformatted: []
    assert.equal html, expectedHtml
    done()

module.exports = { assertRendersHtml }
