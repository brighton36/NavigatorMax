class ViewHandlerController < ApplicationController

  CATCHALL_REQUESTURI_PARTS = /\A[\/]?(.*)[\/]?\Z/

  SITE_NAVIGATION = [ '/spatial-data-raw', '/orientation-kalman', '/gps-location',
    '/system' ]

  def catchall
    raise StandardError if /\.\./.match(request.fullpath)

    raise ActionController::UnknownAction if /\/_/.match request.fullpath

    @requested_action = $1 if CATCHALL_REQUESTURI_PARTS.match request.fullpath 

    @site_navigation = SITE_NAVIGATION

    begin
      action_as_path = Rails.root.join 'app','views','view_handler', @requested_action

      render :file => action_as_path
    rescue ActionView::MissingTemplate
      # This if statement will check to see if there's a directory by the name 
      # of the requested resource, and if so, we'll pull the index action out of 
      # there ...
      if File::directory? action_as_path
        @requested_action += "/index" 
        retry
      end

      render :file => Rails.root.join('public','404.html'), :status => 404
    end
  end

  alias :index :catchall
end
