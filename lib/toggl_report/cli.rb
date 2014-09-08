require 'thor'
require 'terminal-table'
require 'toggl_report/report_generator'
require 'mathn'

module TogglReport
  class CLI < Thor

    desc 'week WEEK [YEAR]', 'Show time-use report for the given week'

    def week(week, year=Time.now.year)
      token = ENV['TOGGL_TOKEN']

      unless token do
        puts 'Toggl token enviroment variable not set.',
             'Export the `TOGGL_TOKEN` enviroment variable',
             'or create a `.env` file containing `TOGGL_TOKEN=<token>`'
        return
      end

        report_generator = TogglReport::ReportGenerator.new token

        entries = report_generator.get_week_report(week.to_i, year.to_i)

        entries.each do |entry|
          options = {}

          options[:title] = entry[:date].strftime('%A %B %e') + ' – ' + format('%02.2f hours', (entry[:total_duration] / (60*60)).rationalize(1/60))
          options[:headings] = %w(Hours Description)

          options[:rows] = entry[:durations].map do |description, duration|
            [
                format('%02.2f', (duration / (60*60)).rationalize(1/60)),
                #duration.total_hours,
                description
            ]
          end

          options[:style] = {width: 76}

          table = Terminal::Table.new options

          puts table
        end
      end
    end
  end
end