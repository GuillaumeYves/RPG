class ApplicationController < ActionController::Base
before_action :set_selected_character

  private

    def set_selected_character
        if session[:selected_character_id]
            @selected_character = Character.find_by(id: session[:selected_character_id])
        else
            @selected_character = nil
        end
    end
end
