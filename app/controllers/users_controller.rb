class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def edit
    # users can edit their own profile, somewhat
    @user = User.friendly.find(params[:id])
    if cannot? :update, @user
      flash[:error] = 'You cannot edit another user profile'
      redirect_to '/'
    end
    set_meta_tags title: 'Edit your profile'
  end
  
  def show
    @user = User.friendly.find(params[:id])
    set_meta_tags title: @user.display_name
  end
  
  def update
    @user = User.friendly.find(params[:id])
    if can? :update, @user
      if @user.update_attributes(user_params)
        flash[:error] = ''
        flash[:warning] = ''
        flash[:notice] = 'Profile info saved.'
        redirect_to edit_user_path(@user)
      else
        flash[:error] = @user.errors.full_messages.join('. ')
        render template: 'users/edit'
      end
    else
      flash[:error] = 'You cannot edit another user profile'
      redirect_to '/'
    end
  end
  
  protected
  
  def user_params
    params.require(:user).permit(:email, :name, :username, :show_name,  :avatar,  :opt_in, :website, :twitter_name, 
    :address, :postcode, :city, :country, :show_twitter_link, :show_facebook_link,
                      accounts_attributes: [:address, :primary_account, :external])
  end
end
