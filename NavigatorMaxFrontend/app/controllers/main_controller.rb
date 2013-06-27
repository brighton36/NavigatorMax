class MainController < ApplicationController
  SITE_NAVIGATION = [ 'home', 'orientation-kalman', 'spatial-data-raw',
    'gps-location', 'system' ]

#  layout :application

  def index
    @site_navigation = SITE_NAVIGATION
  end
end
