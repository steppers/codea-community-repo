# Oil
### A Super 'Slick' and versatile Codea GUI library with an emphasis on ease of use.

---

Inspired by the work of art that is [Soda](https://github.com/Utsira/Soda) and feeling like it was lacking some features I wanted to use during the development of [WebRepo 2.0](https://github.com/steppers/codea-community-repo/tree/main/WebRepo/2.0) I set about to develop my own easy to use GUI library.

Oil is designed to handle all of the grunt work involved with generating beautiful user interfaces, providing a powerful styling system that is pre-configured with both light & dark themes that look great. Say goodbye to configuring everything by hand!

3 lines* is all it takes to create a useful button using Oil:
```
Oil.TextButton(0.5, 0.5, 100, 100, "I'm a button!", function(bttn)
        print("I was pressed!")
end)
```

With a few lines of boilerplate to handle input events and Oil's draw cycle you'll be creating amazing GUIs in no time!


#### More to come...

function Oil.TextRenderer(node, w, h)

function Oil.ButtonHandler(callback, long_press_callback)
function Oil.TouchBlocker(node, event)

function Oil.Node(x, y, w, h)
function Oil.Label(x, y, w, h, label, align)
function Oil.Rect(x, y, w, h, col, radius, blur)
function Oil.Icon(x, y, w, h, texture)
function Oil.TextButton(x, y, w, h, label, cb, press_cb)
function Oil.EmojiButton(x, y, w, h, emoji, cb, press_cb)
function Oil.IconButton(x, y, w, h, texture, cb, press_cb)
function Oil.HorizontalStack(x, y, w, h)
function Oil.VerticalStack(x, y, w, h)
function Oil.Scroll(x, y, w, h)
function Oil.Switch(x, y, callback, default)
function Oil.Slider(x, y, w, h, min, max, callback, default)
function Oil.List(x, y, w)
function Oil.Dropdown(x, y, w, h, label, max_size)
function Oil.TextEntry(x, y, w, h, default_text, callback)