module CalMonthsHelper
  def pretty_from_to(event)
    dtstart, dtend =  event[:start_datetime], event[:end_datetime]
    if dtstart.to_date == dtend.to_date
      "#{dtstart.strftime('%A, %d %b, %H:%M')} - " +
        "#{dtend.strftime('%H:%M')}"
    else
      [dtstart, dtend].map { |dt| dt.strftime('%A, %d %b, %H:%M') }
        .join(' - ')
    end
  end
end
