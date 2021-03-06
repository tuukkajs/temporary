class ExperimentsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  
  def archive
    @past = Instance.includes([:translations, :users, :onetimers]).past.published.order(start_at: :desc).uniq
    set_meta_tags title: 'Experiment archive'
  end

  def calendar
    experiments = Experiment.where(nil)
    experiments = Experiment.published.between(params['start'], params['end']) if (params['start'] && params['end'])
    @experiments = []
    @experiments += experiments.map(&:instances).flatten
    @experiments += Instance.published.between(params['start'], params['end']) if (params['start'] && params['end'])
    @experiments.uniq!
    @experiments.flatten!
    # @experiments += experiments.reject{|x| !x.one_day? }
    if params[:format] == 'ics'
      require 'icalendar/tzinfo'
      @cal = Icalendar::Calendar.new
      @cal.prodid = '-//Temporary, Helsinki//NONSGML ExportToCalendar//EN'

      tzid = "Europe/Helsinki"
      tz = TZInfo::Timezone.get tzid
      @experiments.each do |event|
        @cal.event do |e|
          e.dtstart     = Icalendar::Values::DateTime.new(event.start_at, 'tzid' => tzid)
          e.dtend       = Icalendar::Values::DateTime.new(event.end_at, 'tzid' => tzid)
          e.summary     = event.name
          e.location  = 'Temporary, Kolmas linja 7, Helsinki'
          e.description = strip_tags event.description
          e.ip_class = 'PUBLIC'
          e.url = e.uid = 'https://temporary.fi/experiments/' + event.experiment.slug + '/' + event.slug
        end
      end
      @cal.publish
    end
    set_meta_tags title: 'Calendar'
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @experiments }
      format.ics { render :text => @cal.to_ical }
    end
  end
  
  
  def hierarchy
    # @experiments = Experiment.roots.order(sequence: :asc)
#     respond_to do |format|
#       format.json
#     end
    render json: {name: "0 : Biathlon ", children: [name: "1 : Temporary" , children:  Experiment.collection_to_json ] }
  end
  
  def index
    
    # @experiments = Instance.future.published.order(sequence: :asc).group_by(&:experiment)
    @experiments = Instance.includes(:translations).current.published.or(Instance.future.published.includes(:translations)).order(:start_at).uniq
    @past = Instance.includes([:translations, :users, :onetimers]).past.published.order(start_at: :desc).limit(8).uniq
    set_meta_tags title: 'Experiments'
  end
  

  
  def radial
    
  end
  
  def show
    @experiment = Experiment.friendly.find(params[:id])
    set_meta_tags title: @experiment.name
  end
  
  def tree
    @experiments = Experiment.published.order(sequence: :asc).to_json
  end
  
  private

  def set_item
    @experiment = Experiment.friendly.find(params[:id])
    redirect_to action: action_name, id: @experiment.friendly_id, status: 301 unless @experiment.friendly_id == params[:id]
  end
end
    