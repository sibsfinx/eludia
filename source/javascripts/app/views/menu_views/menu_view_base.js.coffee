class Eludia.Views.MenuViewBase extends Marionette.CollectionView
  tagName: 'ul'

  # Определяется в наследующих классах:
  #
  #itemView: Eludia.Views.MenuItem
  #submenuView: Eludia.Views.MenuViewLevel2
  #submenuRegion: 'menu_region_level2'

  collectionEvents:
    'itemview:click' : 'onSelect'

  initialize: ->
    @submenu_region = App[@submenuRegion]


  onSelect: (item_view) ->
    if item_view!=@menu_item_view
      @hideSubmenu()
      @activateItem item_view
      @gotoCurrentItem()
    else
      if @submenu_view
        @deactivateCurrentItem()
        @hideSubmenu()
      else
        @gotoCurrentItem()

  deactivateCurrentItem: ->
    @menu_item_view?.deactive()
    @menu_item_view = null

  activateItem: (item_view) ->
    @deactivateCurrentItem()
    @menu_item_view = item_view
    @menu_item_view.active()
    @submenu_item = @menu_item_view.model

  onClose: ->
    @hideSubmenu()

  hideSubmenu: ->
    @submenu_view = null
    @submenu_region.close()

  gotoCurrentItem: ->
    if  @submenu_item.get('items')
      @showSubmenu @menu_item_view
    else
      #window.App.goto @submenu_item.get('href')
      App.main_menu_view.resetMenu()
      @iframe_show @submenu_item.get('href')


  showSubmenu: (item_view) ->
    @prepareSubmenu(item_view)
    @showSubmenuRegion(item_view)

  showSubmenuRegion: ->
    @submenu_region.show @submenu_view 
  
  prepareSubmenu: (item_view) ->
    @submenu_item = item_view.model
    @submenu_view = new @submenuView collection: @_submenu_collection(item_view), parent_item_view: item_view, parent_collection_view: @

  setPositionLeft: (el, left, duration = 0) ->
    if (!$.support.transition)
      el.css('left', left + 'px')
    else
      el.transition
        x: left
        duration: duration

  transitionDuration: ->
    500

  _submenu_collection: (item_view)->
    new Eludia.Collections.MenuCollection item_view.model.get('items')

  childrenHeight: ->
    if @.children.length > 0
      lastChildBottom = @.children.last().$el.offset().top + (@.children.last().$el.height() * 2)
      childrenHeight = lastChildBottom - @.children.first().$el.offset().top
      childrenHeight
    else
      0

  childrenOverflow: ->
    if (@childrenHeight() > @windowHeight() - @$el.offset().top)
      true

