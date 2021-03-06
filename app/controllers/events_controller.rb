class EventsController < ApplicationController

	before_filter :authenticate_user!, except: [:index, :show]

	def index
		if params['address'].nil?
			@events = Event.all
		else
			radius = params['radius'].nil? ? 50 : params['radius']

			@events = Event.near(params['address'], radius)
		end
	end

	def show
		@event = Event.find(params[:id])
	end

	def new
		@event = Event.new
		@user = current_user
	end

	def create
		@event = Event.new(event_params)
		@event.host_id = params['event']['host_id']

		if @event.save
			redirect_to @event
		else
			redirect_to events_path
		end
	end

	def find
	end

	def map_api
		@min_lat = params['minLat']
		@max_lat = params['maxLat']

		@min_lng = params['minLng']
		@max_lng = params['maxLng']

		@entries = Event.find_by_sql("SELECT * FROM events WHERE latitude > %s AND latitude < %s AND longitude > %s AND longitude < %s" % [@min_lat, @max_lat, @min_lng, @max_lng])
		
		render :json => @entries.to_json
	end

	def nearby
	end

	def destroy
		@event = Event.find(params[:id])

		@event.destroy

		redirect_to events_path
	end

	private
	def event_params 
		params.require(:event).permit(:name, :address, :time, :max_occup)
	end
end
