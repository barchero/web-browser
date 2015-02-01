
# lib/web-browser

Toolbar = require './toolbar'
Page    = require './page'
SubAtom = require 'sub-atom'

class WebBrowser
  activate: ->
    # atom.webBrowser = @ 
    
    @subs = new SubAtom
    atom.commands.add 'atom-workspace', 'web-browser:toggle': =>
      @toolbar ?= new Toolbar @
      switch
        when not @toolbar.visible()
          @toolbar.show().focus()
        when not @toolbar.focused()
          @toolbar.focus()
        else
          @toolbar.hide()
          
    atom.workspace.onDidChangeActivePaneItem =>
      if @getActivePage() then @page.update()
      else if @page then @page.locationChanged @page.getPath()
      
    @opener = (filePath, options) =>
      if /^https?:\/\//.test filePath
        new Page @, filePath
        
    @subs.add atom.workspace.addOpener @opener
    
  getToolbar:                -> @toolbar
  getOmniboxView:            -> @toolbar?.getOmniboxView()
  setOmniText:        (text) -> @toolbar?.setOmniText text
  setFaviconDomain: (domain) -> @toolbar?.setFaviconDomain domain
  
  destroyToolbar: -> 
    @toolbar.destroy()
    @toolbar = null
    
  createPage: (url) ->
    @toolbar ?= new Toolbar @
    atom.workspace.getActivePane().activateItem new Page @, url

  setLocation: (url) ->
    @toolbar ?= new Toolbar @
    @toolbar.setOmniText url
    if @getActivePage()?.setLocation url
    else @createPage url
      
  getActivePage: ->
    page = atom.workspace.getActivePaneItem()
    if page instanceof Page then @page = page; return @page

  back:    -> @getActivePage()?.back()
  forward: -> @getActivePage()?.forward()
  refresh: -> @getActivePage()?.refresh()
  
  deactivate: ->
    @subs.dispose()
    
module.exports = new WebBrowser
