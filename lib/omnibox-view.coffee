
# lib/omnibox-view
        
{View}  = require 'atom-space-pen-views'
SubAtom = require 'sub-atom'

module.exports =
class OmniboxView extends View
  
  @content: ->
    @div class:'omnibox', tabindex:-1, =>
      @input 
        outlet: 'input'
        placeholder: 'Web-Browser: Enter URL'
        class: 'native-key-bindings'

  initialize: (browser) ->
    @subs = new SubAtom
    @subs.add @input, 'keydown', (e) =>
      url = @input.val()
      if not /^\w+:\/\//.test url then url = 'http://' + url
      switch e.which
        when 13 # cr
          if e.ctrlKey then browser.createPage  url; @input.blur()
          else              browser.setLocation url; @input.blur()
        when  9 then                                 @input.blur() # tab
        when 27 then        browser.getToolbar().destroy();        # esc           
        else return
      false
      
    # var @focused is used in pageView for speed
    @subs.add @input, 'focus', =>
      @focused = yes
      @focusCallback? yes
          
    @subs.add @input, 'blur', =>
      @focused = no
      @focusCallback? no
    
  focus: -> @input.focus()
  onFocusChg: (@focusCallback) ->
    
  setText: (text) -> @input.val text

  destroy: ->
    @subs.dispose()
    @detach()
