require 'restclient'
require 'json'
require 'date'

module TogglReport

  class ReportGenerator

    def initialize(toggl_token)
      @token = toggl_token
    end

    # Get time entry report for a given week
    #
    # @param [Integer] week
    # @param [Integer] year
    # @return [Hash]
    def get_week_report(week, year)

      week_start = Date.commercial(year, week)

      time_entries(week_start, week_start + 7).group_by { |e| e[:start].wday }.map do |_, date_entries|

        date = date_entries.first[:start]
        durations = date_entries.group_by { |e| e[:description] }
                                .map { |desc, entries| [desc, entries.map { |e| e[:duration] }.reduce(&:+)] }
        total_duration = durations.map { |_, d| d }.reduce(&:+)

        {
            date: date,
            total_duration: total_duration,
            durations: durations
        }
      end
    end

    private

    # Fetch all time entries for a date range
    #
    # @param [Date] start_date
    # @param [Date] end_date
    # @return [Array<Hash>]
    def time_entries(start_date, end_date)
      opts = {
          params: {
              start_date: start_date.to_datetime.iso8601,
              end_date: end_date.to_datetime.iso8601
          }
      }

      begin
        response = toggl_resource['time_entries'].get(opts)
      rescue => e
        raise 'Error getting Toggl data: ' + e.response
      end
      data = JSON.parse response

      data.map do |entry|
        duration = entry['duration'].to_f

        # Negative duration means the task is currently running.
        # In this case, we'll set duration to how long it's been running
        if duration < 0
          duration = Time.now - Time.at(duration.abs)
        end

        {
            description: entry['description'],
            start: Date.parse(entry['start']),
            duration: duration
        }
      end
    end

    def toggl_resource
      RestClient::Resource.new('https://www.toggl.com/api/v8', @token, 'api_token')
    end
  end
end