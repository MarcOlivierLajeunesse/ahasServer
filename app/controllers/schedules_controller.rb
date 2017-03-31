<<<<<<< HEAD
class SchedulesController < ApplicationController

=======
# Controls access to the schedule instances stored in the API database
#
#
# @author Mackenzie Bligh
# @see https://github.com/CMPUT401/vettr_server/wiki/API-Documentation#clients
class SchedulesController < ApplicationController
  before_action :authenticate_user

  # Handles HTTP POST request sent to /api/client.
  # @example request body
  #   {
  #   schedule:
  #     {
  #     appointmentStartDate: '1489077477',
  #     clientId: @client.id,
  #     reason: 'bitey dog',
  #     notes: '',
  #     location: '1234 fake st',
  #     appointmentEndDate: '1489077477'
  #     }
  #    }
  # @example failure response
  #   {
  #   "success": false,
  #   "errors": [....] // list of errors
  #   }
  # @return HTTP 201 if success: true JSON
  # @return HTTP 5XX if failure: false JSON
  def create
    schedule = schedule_params
    # extract the schedule id from the JSON to a Client object
    @schedule = Schedule.new(schedule)

    if @schedule.save
      render status: 201, json: { success: true }
    else

      render status: :error, json: { success: false, errors: @schedule.errors.full_messages }
    end
  end

  # Handles HTTP GET request sent to /api/schedules/{id}, and replies with specific client's info, or an error in a JSON.
  # @example success response
  # @example failure response
  #   {
  #    "success": false,
  #    "errors": [....] // list of errors
  #    }
  # @return HTTP 200 if success: true JSON
  # @return HTTP 404 if failure: false on failure
  def show
    schedule = Schedule.find_by(id: params[:id])

    if schedule
      render json: { success: true, schedule: schedule }
    else
      render status: 404, json: { success: false, error: 'Schedule not found' }
    end
  end

  # Handles HTTP GET request sent to /api/schedules and replies with an index containing a list of id, appointmentStartDate, appointmentEndDate, clientId, reason}
  # @example success response
  #   {
  #   "success": "boolean",
  #   "schedule": [{"id": "integer", "appointmentStartDate": "datetime", "appointmentEndDate": "datetime"}...]
  #   }
  # @return HTTP 200 if success: true JSON
  # @return HTTP 500 if failure: false JSON
  def index
    schedules = Schedule.all
    schedule_list = filter_schedule_keys schedules
    render json: { success: true, schedules: schedule_list }
  end

  # Handles HTTP PATCH or PUT request sent to /api/schedules/{id}, and replies with a true response, or an error in a JSON.
  # @example request body
  # @example success response
  #   {"success":true}
  # @example failure response
  #   {
  #    "success": false,
  #    "errors": [....] // list of errors
  #    }
  #
  # @todo add to wiki page.
  #
  # @return HTTP 200 if success: true JSON
  # @return HTTP 404 if schedule instance not found: false JSON
  # @return HTTP 500 if error updating schedule instance: false JSON
  def update
    @schedule = Schedule.find_by(id: params[:id])

    if @schedule.nil?
      render status: 404, json: {success: false, error: "Schedule not found"}
    elsif @schedule.update(schedule_params)
      render json: { success: true}
    else
      render status: 500, json: {success: false, errors: @schedule.errors.full_messages}
    end
  end

  # Handles HTTP DELETE request sent to /api/schedules/{id}, and replies with a true response, or an error in a JSON.
  # @example request body
  # @example success response
  #   {"success":true}
  # @example failure response
  #   {
  #    "success": false,
  #    "errors": [....] // list of errors
  #    }
  #
  # @todo add to wiki page.
  #
  # @return HTTP 200 if success: true JSON
  # @return HTTP 404 if schedule instance not found: false JSON
  # @return HTTP 500 if error updating schedule instance: false JSON

  def destroy
    @schedule = Schedule.find_by(id: params[:id])

    if @schedule.nil?
      render status: 404, json: {success: false, error: "Schedule not found"}
    elsif @schedule.destroy
      render json: { success: true}
    else
      render status: 500, json: {success: false, errors: @schedule.errors.full_messages}
    end

  end

  private
  def filter_schedule_keys(schedules)
    schedules.map do |schedule|
      @client = Client.find_by(id: schedule.clientId)
      { id: schedule.id,   appointmentStartDate: schedule.appointmentStartDate, appointmentEndDate: schedule.appointmentEndDate, clientId: schedule.clientId, firstName: @client.firstName, lastName: @client.lastName, reason: schedule.reason}
    end
  end

  def schedule_params
    params.require(:schedule).permit(:appointmentStartDate, :appointmentEndDate, :scheduleId, :reason, :notes, :location, :duration, :clientId)
  end
end
