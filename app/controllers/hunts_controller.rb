class HuntsController < ApplicationController
before_action :authenticate_user!

    def index
        @selected_character = Character.find(session[:selected_character_id])
        @accepted_hunt = @selected_character.accepted_hunt
        @available_hunts = Hunt.where.not(id: @accepted_hunt&.id)
    end

    def accept_hunt
        @selected_character = Character.find(session[:selected_character_id])

        if @selected_character.accepted_hunt.present?
            redirect_to hunts_path, alert: 'You have already accepted a hunt.'
        else
            @hunt = Hunt.find(params[:id])

            if @selected_character.level < @hunt.level_requirement
            redirect_to hunts_path, alert: 'Your level is too low for this hunt.'
            else
            # Update the character_id for the accepted hunt
            @hunt.update(character_id: @selected_character.id)

            # Set the @hunt variable explicitly
            @hunt = Hunt.find(params[:id])

            redirect_to hunts_path, notice: 'Your hunt begins.'
            end
        end
        Rails.logger.debug("@hunt after accepting: #{@hunt.inspect}")
    end

    def cancel_hunt
        @selected_character = Character.find(session[:selected_character_id])
        @selected_character.update(accepted_hunt: nil)
        redirect_to hunts_path, notice: 'Hunt canceled.'
    end

end