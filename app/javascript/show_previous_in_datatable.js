function attachCollapseEvent($node, path) {
  $node.one('show.bs.collapse', function() {
    $.ajax(path, {
      timeout: 10000,
      dataType: 'html',
      success: function(response) {
        $node.html(response);
        $('table', $node).DataTable({ ordering: false })
      },
      error: function() {
        $node.html('There was an error while trying to load these Submissions.');
      }
    });
  });
};

$(document).ready(function() {
  attachCollapseEvent($('#previouslyDispatched'), '/material_submissions/dispatch.js?status=dispatched')
  attachCollapseEvent($('#previouslyPrinted'), '/material_submissions/print.js?status=printed')
});