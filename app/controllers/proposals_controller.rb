class ProposalsController < ApplicationController
  
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def create
    current_user.update_balance_from_blockchain if @api_status
    @proposal = Proposal.new(proposal_params)
    if @proposal.save
      flash[:notice] = 'Your proposal has been submitted! Now, you can pledge some of your Temps to it.'
      redirect_to proposals_path
    else
      flash[:error] = 'There was an error saving your proposal'
    end

  end
  
  def edit
    @proposal = Proposal.friendly.find(params[:id])
    if @proposal.user != current_user && !current_user.has_role?(:admin)
      flash[:error] = "You cannot edit someone else's proposal."
      redirect_to @proposal
    end
  end
  
  def index
    @next_meeting = Instance.next_meeting
    @current_rate = Rate.get_current.experiment_cost
    @proposals = Proposal.all
  end

  def new
    if current_user.email =~ /change@me/
      flash[:error] = 'You must enter a valid email address in order to propose an experiment.'
      redirect_to proposals_path
    else
      current_user.update_balance_from_blockchain if @api_status
      @current_rate = Rate.get_current.experiment_cost
      @proposal = Proposal.new(user: current_user)
    end
  end
  
  def show
    @current_rate = Rate.get_current.experiment_cost
    @proposal = Proposal.find(params[:id])
  end
  
  def update
    @proposal = Proposal.friendly.find(params[:id])
    if @proposal.user != current_user && !current_user.has_role?(:admin)
      flash[:error] = "You cannot edit someone else's proposal."
      redirect_to @proposal
    else
      if @proposal.update_attributes(proposal_params)
        flash[:notice] = 'Your proposal has been edited!'
        redirect_to proposals_path
      else
        flash[:error] = 'There was an error saving your edited proposal.'
      end
    end
  end
  
  protected
  
  def proposal_params
    params.require(:proposal).permit(:user_id, :name, :short_description, :timeframe, :goals,:intended_participants,
                                      images_attributes: [:image, :_destroy, :proposal_id, :remove_image])
  end
  
end