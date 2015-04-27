*Rails 3*
# Cal Months
Allows for importing ical format calendars to the database with some default calendar views.

## Installing

Install the gem:
`gem cal_months`

Install the required files in your rails app:
`$ rails g cal_months:install`

Run migrations:
`$ rake db:migrate`

## Manually installing assets

Stylesheet:
`// require cal_month`

Javascript:
`//= require cal_month`

## Add Default Calendar Partial to a View
Add this to your view:
`render 'cal_months/calendar'`

Add this to your controller:
```
@cal_month = CalMonth.current_month
@current_event = CalMonth.upcoming_events.first
```

Note: `@cal_month` can be any `CalMonth`, and `@current_event` can be any item in the `CalMonth.upcoming_events` array.

## Importing icalendar

```
ical = File.open('path_to_ical.ics', 'r')
CalEvent.import_from_ical(ical)
```


