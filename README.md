# Cal Months
Allows for importing ical format calendars to the database with some default calendar views.

## Installing

Install the gem:
`gem cal_months`

Install the required files in your rails app:
`$ rails g cal_months:install`

Run migrations:
`$ rake db:migrate`

## Importing icalendar

```
ical = File.open('path_to_ical.ics', 'r')
CalEvent.import_from_ical(ical)
```
