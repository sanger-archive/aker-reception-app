import $ from 'jquery'

$(document).ready(function() {
  $('#previouslyPrinted').one('show.bs.collapse', function() {
    $.ajax('/material_submissions/print.js?status=printed', {
      timeout: 10000,
      dataType: 'html',
      success: function(response) {
        $('#previouslyPrinted').html(response);
        $('table', '#previouslyPrinted').DataTable({ ordering: false })
      },
      error: function() {
        $('#previouslyPrinted').html('There was an error while trying to load these Submissions.');
      }
    });
  });
});