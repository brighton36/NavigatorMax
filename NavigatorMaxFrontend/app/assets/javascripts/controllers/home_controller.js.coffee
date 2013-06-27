class NavigatorMaxFrontend.HomeController extends Batman.Controller
  routingKey: 'home'

  index: (params) ->
    console.log "In the home index!"
    @render false
