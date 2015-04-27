require 'rails/generators/base'

module CalMonths
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      def copy_locale
        copy_file '../../../config/locales/cal_months_en.yml', 'config/locales/cal_months_en.yml'
        copy_file '../../../config/locales/cal_months_cs.yml', 'config/locales/cal_months_cs.yml'
      end

      def copy_stylesheets
        copy_file '../../../app/assets/javascripts/cal_months.js.coffee', 'app/assets/javascripts/cal_months.js.coffee'
        copy_file '../../../app/assets/stylesheets/cal_months.css.sass', 'app/assets/stylesheets/cal_months.css.sass'
        insert_into_file "app/assets/stylesheets/application#{detect_css_format[0]}", "\n#{detect_css_format[1]} require cal_months\n", :after => "require_self"
      end

      def detect_css_format
        return ['.css', ' *='] if File.exist?('app/assets/stylesheets/application.css')
        return ['.css.sass', ' //='] if File.exist?('app/assets/stylesheets/application.css.sass')
        return ['.sass', ' //='] if File.exist?('app/assets/stylesheets/application.sass')
        return ['.css.scss', ' //='] if File.exist?('app/assets/stylesheets/application.css.scss')
        return ['.scss', ' //='] if File.exist?('app/assets/stylesheets/application.scss')
      end

      def copy_views
        copy_file '../../../app/views/cal_months/_calendar.html.haml', 'app/views/cal_months/_calendar.html.haml'
        copy_file '../../../app/views/cal_months/_month.html.haml', 'app/views/cal_months/_month.html.haml'
        copy_file '../../../app/views/cal_months/_upcoming_events.html.haml', 'app/views/cal_months/_upcoming_events.html.haml'
        copy_file '../../../app/views/cal_months/show.js.erb', 'app/views/cal_months/show.js.erb'
        copy_file '../../../app/views/cal_months/show_current_event.js.erb', 'app/views/cal_months/show_current_event.js.erb'
      end

      def add_routes
        route "get '/cal_months/calendar/:year-:month', to: 'cal_months#show', as: :cal_month"
        route "get '/cal_months/current-events/:id', to: 'cal_months#show_current_event', as: :current_event"
      end

      def add_migrations
        copy_file '../../../db/migrate/create_cal_events.rb', "db/migrate/#{Time.now.to_i}_create_cal_events.rb"
        copy_file '../../../db/migrate/create_cal_months.rb', "db/migrate/#{Time.now.to_i + 1}_create_cal_months.rb"
      end
    end
  end
end
