class CalMonth < ActiveRecord::Base

  validates :month, presence: true
  validates :year, presence: true
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
    month = where('year >= ? AND month >= ?', date.year, date.month)
      .order(:year).order(:month).limit(1).first 

    if month
      events = month.date_events[(date.day-1)..-1].find { |day, data| 
        !data.empty? && 
          data.any? { |event| 
            event[:end_datetime] > Time.zone.now
          }
      }.last.sort_by { |event| event[:start_datetime] }
      events.delete_if { |event| event[:end_datetime] < Time.zone.now }
    else
      [{ 
        start_datetime: Date.today.to_datetime, 
        end_datetime: Date.today.to_datetime, 
        name: '' 
      }]
    end
  end

  def to_a
    [year, month]
  end

  def next_month_array
    n_year  = year
    n_month = month + 1
    if n_month == 13
      n_year += 1
      n_month = 1
    end
    [n_year, n_month]
  end

  def prev_month_array
    n_year  = year
    n_month = month - 1
    if n_month == 0 
      n_year -= 1
      n_month = 12
    end
    [n_year, n_month]
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
end
