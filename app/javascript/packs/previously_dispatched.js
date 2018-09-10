import $ from 'jquery';

$(document).ready(function() {
  $('#previouslyDispatched').one('show.bs.collapse', function() {
    $.ajax('/material_submissions/dispatch.js?status=dispatched', {
      timeout: 10000,
      dataType: 'html',
      success: function(response) {
        $('#previouslyDispatched').html(response);
        $('table', '#previouslyDispatched').DataTable({ ordering: false })
      },
      error: function() {
        $('#previouslyDispatched').html('There was an error while trying to load these Submissions.');
      }
    });
  });
});