require 'icalendar'
class CalEvent < ActiveRecord::Base

  validates :system_uid, presence: true
  validates :system_updated_at, presence: true

  scope :for_month, ->(year, month) {
    ids = all.map { |event| 
      event.id if event.months_affected.include?([year,month]) 
    }.compact
    where(id: ids)
  }

  def self.months_affected
    all.flat_map(&:months_affected).uniq.sort
  end

  def self.create_or_update(attributes = {})
    new_event = CalEvent.new(attributes)
    raise ActiveRecord::RecordInvalid unless new_event.valid?

    found = CalEvent.find_by_system_uid(new_event.system_uid)

    if found 
      if found.system_updated_at < new_event.system_updated_at
        found.update_attributes(
          name:              new_event.name,
          description:       new_event.description,
          system_updated_at: new_event.system_updated_at
        )
      end
      found
    else
      new_event.save
      new_event
    end
  end

  def self.import_from_ical(ical)
    ids = []
    cals = Icalendar.parse(ical)
    cals.each do |cal|
      cal.events.each do |event|
        db_event = CalEvent.create_or_update(
          name:              event.summary.to_s,
          description:       event.description.to_s,
          system_uid:        event.uid.to_s,
          system_updated_at: event.last_modified.to_datetime,
        )
        if event.rdate.empty?
          db_event.rdate = [
            [event.dtstart.to_datetime, event.dtend.to_datetime]
          ].to_json
        else
          db_event.rdate = event.rdate[0].to_json
        end
        db_event.save
        ids << db_event.id
      end
    end 
    events = CalEvent.where(id: ids)
    events.months_affected.each do |year, month|
      data = events.for_month(year, month).to_event_data(year, month)
      CalMonth.create_or_update(
        year: year, month: month, event_data: data
      )
    end
    events
  end

  def self.to_event_data(year, month)
    all.each_with_object(Hash.new {|h,k| h[k] = []}) { |event, data| 
      event.to_event_data[[year, month]].each do |day, event_data|
        data[day] << event_data
      end 
    } 
  end

  def to_event_data
    data = Hash.new { |h,k| h[k] = {} }
    datetimes.each {|start_datetime, end_datetime|
      (start_datetime..end_datetime).each do |day|
        data[[day.year, day.month]][day.day] = { 
          id:             id, 
          name:           name, 
          start_datetime: start_datetime, 
          end_datetime:   end_datetime
        }
      end
    }
    data
  end

  # array of array [[start_datetime, end_datetime],...]
  def datetimes
    data = JSON.parse(rdate)
    data.map { |pair| pair.map { |str| DateTime.parse(str) } }
  end

  def months_affected
    datetimes.flatten.map { |date| [date.year, date.month] }.uniq.sort
  end
end
