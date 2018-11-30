/*global $*/
/*global app*/

// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require rails-ujs
//= require selectize
//= require bootstrap-datepicker
//= require activestorage
//= require turbolinks
//= require_tree .
//= require popper
//= require bootstrap-sprockets
//= require moment 
//= require fullcalendar

function eventCalendar() {
  return $('#calendar').fullCalendar({ 
        lang: 'en',
        defaultView: 'agendaWeek',
        firstDay: 1,
        nowIndicator: true,
        timeFormat: 'H(:mm)',
        scrollTime: '08:00:00',
        minTime: "06:00:00",
        maxTime: "22:00:00",
        allDaySlot: false,
        slotMinutes: 30,
        events: app.vars.jobs,
        header: {
            center: 'month,basicWeek,basicDay,agendaWeek,agendaDay'
        }


  });
};
function clearCalendar() {
  $('#calendar').fullCalendar('delete'); 
  $('#calendar').html('');
};

$(document).on('turbolinks:load', function(){

    $(function () {
      $('[data-toggle="tooltip"]').tooltip()
    })

  if ($('.selectize')){
      $('.selectize').selectize({
          sortField: 'text'
      });
  }


	$('.datepicker').datepicker({
     orientation: 'auto bottom',
     format: 'yyyy-mm-dd'
	});
 	$('.input-daterange').datepicker({
     orientation: 'auto bottom',
     format: 'yyyy-mm-dd'
    });

  eventCalendar();  
});
$(document).on('turbolinks:before-cache', clearCalendar);

