$(window).bind 'hashchange', (e) ->
  nav_pane = $.param.fragment()
  nav_pane = 'home' unless nav_pane
  
  $( 'li.active' ).removeClass( 'active' )
  $( '.nav_pane:visible' ).hide()

  $( 'a[href="#' + nav_pane + '"]' ).parent('li').addClass( 'active' )
  $("##{nav_pane}").show()

# the event is only triggered when the hash changes, we need to trigger
# event now, to handle the hash the page may have loaded with.
$(document).ready -> $(window).trigger( 'hashchange' )


