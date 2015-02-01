
# lib/page-view

{$, View} = require 'atom-space-pen-views'
SubAtom   = require 'sub-atom'

module.exports =
class PageView extends View
  
  @content: ->
    @div class:'browser-page', tabindex:-1, =>
      @tag 'webview', 
        outlet:            'webview'
        plugins:            yes
        disablewebsecurity: yes
  
  initialize: (page) ->
    @subs = new SubAtom
    page.setView @
    browser     = page.getBrowser()
    omniboxView = browser.getOmniboxView()
    tabBarView  = $(atom.views.getView(atom.workspace.getActivePane())).find('.tab-bar').view()
    tabView     = tabBarView.tabForItem page
    $tabView    = $ tabView
    url         = page.getPath()
    
    @setLocation url
    
    @subs.add @webview, 'did-start-loading', =>
      url   = @webview[0].getUrl()
      title = @webview[0].getTitle()
      page.locationChanged url
      page.setTitle title
      
    @$tabFavicon = $ '<img class="tab-favicon">'
    $tabView.append @$tabFavicon
    $tabView.find('.title').css paddingLeft: '2.7em'
  
  setFaviconDomain: (domain) -> 
    @$tabFavicon.attr src: "http://www.google.com/s2/favicons?domain=#{domain}"
    
  setLocation: (url) -> @webview.attr src: url
    
  destroy: ->
    @subs.dispose?()
    @detach()

