class HuntsController < ApplicationController
before_action :authenticate_user!

    def index
        @selected_character = Character.find(session[:selected_character_id])
        @accepted_hunt = @selected_character.accepted_hunt
        @available_hunts = Hunt.where.not(id: @accepted_hunt&.id).where('level_requirement <= ?', @selected_character.level)
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
                # Check if character has enough energy for the hunt
                if @selected_character.energy >= @hunt.energy_cost
                    # Deduct energy_cost from character's energy
                    @selected_character.energy -= @hunt.energy_cost
                    @selected_character.save
                    # Update the character_id for the accepted hunt
                    @hunt.update(character_id: @selected_character.id)

                    redirect_to hunts_path, notice: 'Your hunt begins.'
                else
                    redirect_to hunts_path, alert: 'Not enough energy.'
                end
            end
        end
    end

    def cancel_hunt
        @selected_character = Character.find(session[:selected_character_id])
        @selected_character.update(accepted_hunt: nil)
        redirect_to hunts_path, notice: 'Hunt canceled.'
    end

end
