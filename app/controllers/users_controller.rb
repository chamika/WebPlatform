class UsersController < ApplicationController
  before_action :require_login

  def show
    authorized_user
    @user = User.find(params[:id])
    setup_project(@user)
  end

  def edit
    authorized_user
    setup_project(current_user)
  end

  def dashboard
    setup_project(current_user)
    @partner = current_user.partner
    @week = find_week
    @tasks = @week.nil? ? @project.tasks.not_deleted : @project.week_tasks(@week.number).not_deleted
  end

  def update
    setup_project(current_user)

    if current_user.update_attributes(user_params)
      redirect_to @after_update_path, notice: "Details have been succesfuly updated."
    else
      render "edit"
    end
  end

  def user_status
    @user = User.find(params[:mentee_profile_id].to_i) || User.find(params[:mentor_profile_id].to_i)
    if request.post?
      if @user && params[:user][:warning_email_date].present? && @user.update_attribute(:send_warning_email_after, params[:user][:warning_email_date])
        flash[:notice] = 'User details updated successfully'
      else
        flash[:alert] = "User or Date invalid"
      end
    end
    redirect_to case @user.role
    when "mentee" then mentee_profile_path(@user)
    when "mentor" then mentor_profile_path(@user)
    when "organizer" then organisers_path
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :country, :program_country, :timezone, :avatar,
      :mentee_project_attributes => [:id, :title,:description,:github_link]
    )
  end

  def authorized_user
    unless User.find(params[:id]) == current_user || current_user.organizer? || current_user.partner.id == params[:id].to_i
      redirect_to root_path, alert: "You don't have permission to access this site", status: 401
    end
  end
end
