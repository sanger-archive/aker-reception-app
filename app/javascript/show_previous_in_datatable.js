import Reception from './routes'

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
        $node.html('There was an error while trying to load these Manifests.');
      }
    });
  });
};

$(document).ready(function() {
  attachCollapseEvent($('#previouslyPrinted'), Reception.manifests_print_index_path({ format: 'js', status: 'printed' }))
  attachCollapseEvent($('#previouslyDispatched'), Reception.manifests_dispatch_index_path({ format: 'js', status: 'dispatched' }))
});