{puts} = require 'sys'


exports.html = html = (data, indent=0) ->
  parseSelector = (selector) ->
    # split the selector into parts
    rawId = selector.match(/#[A-Za-z](\w|-|:)*/g)
    rawClasses = selector.match(/\.-?[_a-zA-Z][_a-zA-Z0-9-]*/g) or []
    tag = selector.match(/^(\w+)(\.|#)/)?[1] or selector

    # and tidy those parts up
    classes = (c.replace(/^\./, '') for c in rawClasses)
    id = rawId && rawId[0].replace(/^#/, '')
    [tag, classes, id]

  # we want the content to be indented whatever it is
  indentString = ""
  for i in [0...indent]
    do (i) ->
      indentString += " "

  if data.constructor is Array
    # collect the variables
    [tag, classes, id] = parseSelector(data[0])
    attrs = {}
    attrs['id'] = id if id?
    if data[1]?.constructor is Object
      attrs = data[1]
      content = data[2..]
    else
      content = data[1..]

    # add the classes to attrs
    classString = classes.join(" ")
    if attrs.hasOwnProperty('class')
      atrcl = attrs['class']
      if atrcl.constructor is Array
        classString += (" " + atrcl.join(" "))
      else
        classString += (" " + atrcl)
    attrs['class'] = classString if classString

    # render the content and attrs
    rendered = (html(e, indent + 2) for e in content).join("\n")
    rendered = rendered
    attrStrings = for k,v of attrs
      do (k,v) ->
        valString = if v.constructor is Array
          css.inline(v)
        else
          html.toInlineString(v)
        "#{k}=\"" + valString.replace(/"/, '\\"') + "\""
    attrString = attrStrings.join(" ")
    attrString = " " + attrString if attrString

    # produce the tag
    if rendered
      "#{indentString}<#{tag}#{attrString}>\n#{rendered}\n#{indentString}</#{tag}>"
    else
      "#{indentString}<#{tag}#{attrString} />"
  else
    indentString + data.toString()

html.toInlineString = (fn) ->
  # a dirty hack to convert a js function to an inline js string
  stringified = fn.toString()
  if stringified.match(/^function \(\) {/)
    stringified.replace(/^function \(\) {/, '')
      .replace(/}$/, '')
      .replace(/\s+/g, ' ')
      .replace(/^\s+/, '')
      .replace(/\s+$/, '')
  else
    stringified

makeSafe = (data) ->
  if data.constructor is String
    data
  else if data.constructor is Function
    html.toInlineString(data)
  else if data.constructor is Object
    newObject = {}
    for k,v of data
      do (k,v) ->
        newObject[k] = makeSafe(v) if data.hasOwnProperty(k)
    newObject
  else if data.constructor is Array
    result = []
    for i in data
      do (i) ->
        result.push(makeSafe(i))
    result

exports.jsonify = (data) ->
  "(" + JSON.stringify(makeSafe(data)) + ")"

exports.css = css = (data, prefix="") ->
  ruleSet = (selector, array) ->
    ruleStrings = []
    nestedSets = []
    array = css.flattenMixins(array)
    while array.length > 0
      element = array.shift()
      if element.constructor is Object # treat it as a nested stylesheet
        nestedSets.push(css(element, selector + " "))
      else # it's an Array, so we treat it as a set of attr/value pairs
        attribute = element
        value = array.shift()
        ruleStrings.push(css.rule(attribute, value))
    "#{selector} {\n  #{ruleStrings.join("\n  ")}\n}\n#{nestedSets.join("\n")}"

  strings = []
  for selector,rules of data
    do (selector, rules) ->
      strings.push(ruleSet(prefix + selector, rules))
  strings.join("")

css.rule = (attribute, value) ->
  "#{attribute}: #{value};"

css.flattenMixins = (array) ->
  # flatten nested arrays maintaining order and leaving objects untouched
  result = []
  for e in array
    do (e) ->
      if e.constructor is Array
        result = result.concat(css.flattenMixins(e))
      else
        result.push(e)
  result

css.inline = (data) ->
  data = css.flattenMixins(data)
  strings = []
  for atr, i in data by 2
    do (atr, i) ->
      strings.push(css.rule(atr, data[i+1]))
  strings.join(" ")
