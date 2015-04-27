class CalMonthsController < ApplicationController

  def show
    @cal_month = CalMonth.fetch_month(params[:year], params[:month])
  end

  def show_current_event
    @current_event = CalMonth.upcoming_events[params[:id].to_i]
  end
end
