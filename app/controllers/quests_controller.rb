class QuestsController < ApplicationController
  before_action :authenticate_user!

    def index
      @character = Character.find(session[:selected_character_id])
      @accepted_quests = @character.accepted_quests
      @available_quests = Quest.where.not(id: @accepted_quests&.ids).where('level_requirement <= ?', @character.level)
    end

    def accept_quest
      @character = Character.find(session[:selected_character_id])
      @quest = Quest.find(params[:id])

        if @character.accepted_quests.present? && @quest.quest_type == "Main Quest"
          redirect_to quests_path, alert: 'You have already accepted a main quest.'
        elsif @character.accepted_quests.size >= 10
          redirect_to quests_path, alert: 'You cannot have more quests.'
        else
            if @character.level < @quest.level_requirement
              redirect_to quests_path, alert: 'Your level is too low for this quest.'
            elsif @quest.quest_type == "Daily Quest"
              @character.update(daily_quest: @character.daily_quest - 1)
              # Update the character_id for the accepted quest
              @quest.update(character_id: @character.id)
              redirect_to quests_path, notice: 'Your quest begins.'
            else
              # Update the character_id for the accepted quest
              @quest.update(character_id: @character.id)
              redirect_to quests_path, notice: 'Your quest begins.'
            end
        end
    end

    def cancel_quest
        @character = Character.find(session[:selected_character_id])
        quest_id = params[:quest_id]
        quest = @character.accepted_quests.find_by(id: quest_id)
        quest.update(character_id: nil)
        redirect_to quests_path, notice: 'Quest canceled.'
    end

end
