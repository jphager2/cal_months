require 'rails/generators/base'

module CalMonths
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def copy_locale
        copy_file '../../../config/locales/cal_months_en.yml', 'config/locales/cal_months_en.yml'
        copy_file '../../../config/locales/cal_months_cs.yml', 'config/locales/cal_months_cs.yml'
      end


      def copy_views
        copy_file '../../../app/views/_calendar.html.haml', 'app/views/cal_months/_calendar.html.haml'
        copy_file '../../../app/views/_month.html.haml', 'app/views/cal_months/_month.html.haml'
        copy_file '../../../app/views/_upcoming_events.html.haml', 'app/views/cal_months/_upcoming_events.html.haml'
        copy_file '../../../app/views/show.js.erb', 'app/views/cal_months/show.js.erb'
        copy_file '../../../app/views/show_current_event.js.erb', 'app/views/cal_months/show_current_event.js.erb'
      end

      def add_routes
        route "'/cal_months/calendar/:year-:month', to: 'cal_months#show', as: :cal_month"
        route "'/cal_months/current-events/:id', to: 'cal_months#show_current_event', as: :current_event"
      end
    end
  end
end
