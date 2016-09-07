class InstancesController < ApplicationController
  
  def show
    if params[:experiment_id]
      @experiment = Experiment.friendly.find(params[:experiment_id])
      @instance = @experiment.instances.friendly.find(params[:id])
    end
  end
  
  def index
    if params[:experiment_id]
      @experiment = Experiment.friendly.find(params[:experiment_id])
      @future = @experiment.instances.current.or(@experiment.instances.future).order(:start_at).uniq
      @past = @experiment.instances.past.order(:start_at).uniq.reverse
    end
  end
  
end