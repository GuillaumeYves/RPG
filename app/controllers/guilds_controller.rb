class GuildsController < ApplicationController

  def new
    @guild = Guild.new
    @guilds = Guild.all
  end

  def show
    @guild = Guild.find(params[:id])
  end

  def create
    @guild = Guild.new(guild_params)
    @guild.leader = current_user.selected_character

    if @guild.save
      # Assign the guild to the character
      current_user.selected_character.update(guild: @guild)
      redirect_to @guild, notice: 'Guild was successfully created.'
    else
      render :new
    end
  end

  def disband
    @guild = Guild.find(params[:id])
    if @guild.leader == current_user.selected_character
      @guild.members.update_all(guild_id: nil)
      @guild.destroy
      redirect_to root_path, notice: "Guild disbanded successfully."
    else
      redirect_to @guild, alert: "Only the guild leader can disband the guild."
    end
  end

  def invite_member
    invited_character = Character.find(params[:character_id])
    if @guild.members.size < Guild::MAX_MEMBERS && @guild.invite_only?
      Invitation.create(guild: @guild, invited_character: invited_character, inviting_character: current_user.character)
      redirect_to @guild, notice: 'Invitation sent successfully.'
    else
      redirect_to @guild, alert: 'Unable to send invitation.'
    end
  end

  def respond_to_invitation
    invitation = @guild.invitations.find(params[:invitation_id])
    if params[:response] == 'accept'
      invitation.accepted!
      invitation.invited_character.update(guild: @guild)
      redirect_to @guild, notice: 'Invitation accepted.'
    elsif params[:response] == 'reject'
      invitation.rejected!
      redirect_to @guild, notice: 'Invitation rejected.'
    else
      redirect_to @guild, alert: 'Invalid response.'
    end
  end

  def apply_to_join_guild
    @guild = Guild.find(params[:guild_id])
    if current_user.selected_character.guild.nil?
      current_user.selected_character.update(guild: @guild)
      redirect_to @guild, notice: "#{@guild.name} Joined."
    else
      redirect_to @guild, alert: "You are already a member of a guild."
    end
  end

  private

  def guild_params
    params.require(:guild).permit(:name, :membership_status)
  end

end
