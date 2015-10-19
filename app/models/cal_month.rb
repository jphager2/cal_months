class CalMonth < ActiveRecord::Base

  attr_accessible :event_data, :month, :year

  validates_presence_of :month, :year
  validate :unique_month

  def self.find_month(year, month)
    CalMonth.where(year: year, month: month).limit(1).first
  end

  def self.current_month
    date = Date.today
    fetch_month(date.year, date.month)
  end

  def self.fetch_month(year, month)
    if found = find_month(year, month)
      found
    else
      CalMonth.new(year: year, month: month)
    end
  end

  def self.create_or_update(attributes = {})
    month = find_month(attributes[:year], attributes[:month]) || 
      CalMonth.new(year: attributes[:year], month: attributes[:month])

    month.update_event_data(attributes[:event_data])
  end

  # Returns event data: array of hash, sorted by start datetime
  # e.g. [{"id" => 1, "name" => "Next Event", "start_datetime" =>
  def self.upcoming_events(date = nil)
    date  ||= Date.today
    months = where('year >= ? AND month >= ?', date.year, date.month)
      .order(:year).order(:month).limit(2)

    unless months.empty?
      events = months.first.events_after_day(date.day)
      if events.empty?
        months.last.events_after_day
      else
        events
      end
    else
      [{ 
        start_datetime: Date.today.to_datetime, 
        end_datetime: Date.today.to_datetime, 
        name: '' 
      }]
    end
  end

  def events_after_day(day = 1)
    eventful_day = date_events[(day-1)..-1].find { |day, data| 
      !data.empty? && 
        data.any? { |event| 
          event[:end_datetime] > Time.zone.now
        }
    }
    return [] unless eventful_day

    events = eventful_day.last.sort_by {|event| event[:start_datetime]}
    events.delete_if { |event| event[:end_datetime] < Time.zone.now }
  end

  def next_cal_month
    CalMonth.fetch_month(*next_month_array)
  end

  def prev_cal_month
    CalMonth.fetch_month(*prev_month_array)
  end

  def to_a
    [year, month]
  end

  def next_month_array
    next_month = to_date + 1.month
    [next_month.year, next_month.month]
  end

  def prev_month_array
    prev_month = to_date - 1.month
    [prev_month.year, prev_month.month]
  end

  def next_month_key
    key_from_array(next_month_array)
  end

  def prev_month_key
    key_from_array(prev_month_array)
  end

  def key
    key_from_array(to_a)
  end

  def to_date
    Date.new(year, month)
  end

  def days
    (1..to_date.end_of_month.day).to_a
  end

  def events_for_day?(day)
    !events_for_day(day).empty?
  end

  def events_for_day(day)
    date_events_hash[day.to_s]
  end

  def date_events
    date_events_hash.sort_by { |date,_| date.to_i } 
  end

  def update_event_data(new_data)
    new_data.stringify_keys
    old_data = JSON.parse(event_data || '{}')
    data     = merge_default_data(old_data).merge(new_data)

    update_attribute(:event_data, data.to_json)
  end

  def replace_event_data(new_data)
    update_attribute(:event_data, merge_default_data(new_data).to_json)
  end

  def each_week
    date = to_date
    data = date_events
    day_of_week_offset = date.wday - 1
    day_of_week_offset.times { data.unshift([nil, []]) }

    if block_given?
      data.each_slice(7) { |week| yield(week) }
    else
      data.each_slice(7)
    end
  end

  private
  def merge_default_data(to_merge)
    blank_days_hash.merge(to_merge)
  end

  def date_events_hash
    @date_events_hash ||= merge_default_data(parsed_event_data)
  end 

  def parsed_event_data
    data = JSON.parse(event_data || '{}')
    data = create_hash_with_indifferent_access(data)
    data.each do |day, value|
      value.each_with_index do |event, index| 
        [:start_datetime, :end_datetime].each do |key|
          data[day][index][key] = DateTime.parse(data[day][index][key]) 
        end
      end
    end
  end

  def create_hash_with_indifferent_access(hash)
    ActiveSupport::HashWithIndifferentAccess.new(hash)
  end

  def blank_days_hash
    days.each_with_object({}) { |day, hash| hash[day] = [] }
      .stringify_keys!
  end

  def unique_month
    found = CalMonth.where(year: year, month: month)
      .where('NOT(id = ?)', id)
    if found.first
      errors[:base] << "Unique month required. If you are reading this, there is a bug in the creation or updating of CalMonth models." 
    end
  end

  def key_from_array(array)
    app_name = Rails.application.class.to_s.split('::').first
    "_#{app_name}_month_#{array.join('_')}"
  end
end
