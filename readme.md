# Description

Hiccup is a small library for creating html and css using coffeescript/json data structures. It's almost a port of clojure's hiccup library, with a bit of gaka and scriptjure thrown in for good measure.


# Usage

## HTML

html is generated by passing nested arrays to the html function. The easiest way to explain is with an example, so this code...

    html(
      ["div.foo", {id: "bar"},
        ["p.foo.bar#baz", "Lorem ipsum dolor consectitur"],
        ["br"],
        ["p", "hopefully this is enough to make the point..."]
      ])

produces this html...

    <div id="bar" class="foo">
       <p id="baz" class="foo bar">
         Lorem ipsum dolor consectitur
       </p>
       <br />
       <p>
         hopefully this is enough to make the point...
       </p>
    </div>

If a function is assigned to an attr, that function is converted to an inline js string. Again, an example is worth a thousand words, so this coffeescript...

    html(
      ["div.foo", {id: "bar", onmouseover: -> doSomethingAwesome()},
        ["p.foo.bar#baz", "Lorem ipsum dolor consectitur"],
        ["br"],
        ["p", "I don't know about you, but I think this is pretty cool!"]
      ])

produces this html...

    <div id="bar" onmouseover="return doSomethingAwesome();" class="foo">
      <p id="baz" class="foo bar">
        Lorem ipsum dolor consectitur
      </p>
      <br />
      <p>
        I don't know about you, but I think this is pretty cool!
      </p>
    </div>

Finally, if an Array is assigned to an attr, it is passed to css.inline (see below) so you can also do this.

    html(
      ["div.foo", {id: "bar", onmouseover: -> doSomethingAwesome()},
        ["p.foo.bar#baz", "Lorem ipsum dolor consectitur"],
        ["br"],
        ["p", {style: ["color", "red"]}, "I don't know about you, but I think this is pretty cool!"]
      ])

which produces...

    <div id="bar" onmouseover="return doSomethingAwesome();" class="foo">
      <p id="baz" class="foo bar">
        Lorem ipsum dolor consectitur
      </p>
      <br />
      <p style="color: red;">
        I don't know about you, but I think this is pretty cool
      </p>
    </div>

Naturally, if you pass this through JSON.stringify, the function will be deemed unsafe and will be removed so you can safely eval the result. To avoid this you can convert any hiccup data structure to the correct json using jsonify. When applied to the data structure from the previous example we get the following...

    data = ["div.foo", {id: "bar", onmouseover: -> doSomethingAwesome()},
      ["p.foo.bar#baz", "Lorem ipsum dolor consectitur"],
      ["br"],
      ["p", {style: ["color", "red"]}, "I don't know about you, but I think this is pretty cool!"]]

    jsonify(data)

    '''
    (['"div.foo"',{'"id"':'"bar"','"onmouseover"':'"return doSomethingAwesome();"'},
      ['"p.foo.bar#baz"','"Lorem ipsum dolor consectitur"'],
      ['"br"'],
      ['"p"',{'"style"':['"color"','"red"']},'"I don\'t know about you, but I think this is pretty cool!"']])
    '''

## CSS
    
You can also generate css using the css function. A stylesheet is modelled as an object, while a set of rules is modelled as an array, so this...

    css(
      {
        "div": ["width", "940px",
                "margin", "0 auto"],

        "p": ["background", "#00ff00",
              "color", "#ff0000"]
      })

produces...

    div {
      width: 940px;
      margin: 0 auto;
    }
    p {
      background: #00ff00;
      color: #ff0000;
    }

### Mixins

nested arrays are flattened before the css is produced, so we can use arrays as "mixins". This coffeescript...

    border = (weight, color) ->
      ["border", "#{weight}px solid #{color}"]

    css(
      {
        "div.main": ["width", "940px",
                     border(1, "#000000")]
      })

produces this css...

    div.main {
      width: 940px;
      border: 1px solid #000000;
    }

### Nesting

objects inside a stylesheet array are treated as nested stylesheets, so...

    css(
      {
        "div.main": ["width", "940px"
                     {
                       "p.foo": ["background", "#ff8888"]
                     }]
      })

produces the following css

    div.main {
      width: 940px;
    }
    div.main p.foo {
      background: #ff8888;
    }

### Inline css

If you want to generate css for use in a style attr, you can use the css.inline function like so

    css.inline(["color", "#ff0000", "background", "#00ff00"]) 
    # => "color: #ff0000; background: #00ff00;"

