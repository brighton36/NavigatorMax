class MainController < ApplicationController
  SITE_NAVIGATION = [ 'home', 'orientation-kalman', 'spatial-data-raw',
    'gps-location', 'system' ]

  #layout 'application', :only => :index
  layout false, :except => :index

  CATCHALL_REQUESTURI_PARTS = /\A[\/]?(.*)[\/]?\Z/

  SITE_NAVIGATION = [ 'home', 'orientation-kalman', 'spatial-data-raw',
    'gps-location', 'system' ]

  def index
    @site_navigation = SITE_NAVIGATION
  end

  def catchall
    requested_path = params[:anything] || params[:action]

    raise StandardError if /\.\./.match requested_path

    raise ActionController::UnknownAction if /\/_/.match requested_path

    @requested_action = $1 if CATCHALL_REQUESTURI_PARTS.match requested_path

    @site_navigation = SITE_NAVIGATION

    begin
      logger.error "Trying: "+@requested_action.inspect
      action_as_path = Rails.root.join 'app','views','main', @requested_action
      logger.error "Trying: "+action_as_path.inspect

      render :file => action_as_path
    rescue ActionView::MissingTemplate
      # This if statement will check to see if there's a directory by the name 
      # of the requested resource, and if so, we'll pull the index action out of 
      # there ...
      if File::directory? action_as_path
        @requested_action += "index" 
        retry
      end

      render :file => Rails.root.join('public','404.html'), :status => 404
    end
  end

end
