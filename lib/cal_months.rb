gem_app_path = File.expand_path('../..', __FILE__)
autoload :CalMonthsController, "#{gem_app_path}/app/controllers/cal_months_controller"
autoload :CalEvent, "#{gem_app_path}/app/models/cal_event"
autoload :CalMonth, "#{gem_app_path}/app/models/cal_month"

autoload :InstallGenerator, "#{gem_app_path}lib/generators/cal_months/install_generator"
