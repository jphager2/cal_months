# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


add_on_calendar_date_on_hover_event = ->
  $('.day.circled').hover(
    (->
      events = $(this).data('event-names')
      html = "<ul><li>" + events.join('</li><li>') + "</li></ul>"
      $('.month .more-info').html(html)
    ),
    (-> $('.month .more-info').html('')))

$(document).on 'ready page:load', ->
  add_on_calendar_date_on_hover_event()

$(document).ajaxComplete ->
  add_on_calendar_date_on_hover_event()
