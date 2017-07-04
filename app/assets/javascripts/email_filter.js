(function($,undefined) {
  var HEADERS =[];
  var NODE = ".claiming-display .email-input";
  var SUBMISSIONS_NODE = ".claiming-display .submission-list"

  function onFindReception(e, data, status, xhr) {
    $('.table', $(SUBMISSIONS_NODE)).bootstrapTable('destroy');

    $('.table', $(SUBMISSIONS_NODE)).bootstrapTable({data: data, uniqueId: 'id', columns: HEADERS});

    $('.table tbody tr', $(SUBMISSIONS_NODE)).each(function(pos, node) {
      $(node).attr('draggable', true);
      $(node).on('dragstart', function(event) {

        var submissionIds = $($('table', $(SUBMISSIONS_NODE))).bootstrapTable('getAllSelections').map(function(node, pos) {
          return node.id;
        });

        // If there aren't currently selected submissions, get the one being dragged
        if (submissionIds.length == 0) {
          submissionIds = [$(event.target).data('uniqueid')];
        }

        // Should always be greater than 0...
        if (submissionIds.length > 0) {
          event.originalEvent.dataTransfer.setData("text/plain", JSON.stringify(submissionIds));
          var img = document.createElement('img');
          img.src = "/assets/move.png";
          event.originalEvent.dataTransfer.setDragImage(img, 10, 10);
        }
      });

      var td = $($("td", $(node))[0]);
      var tdId = td.text();
      $(td).html($(["<a>",tdId, "</a>"].join('')));
    })

    $(data).each(function(node) {
      node.id = ['<a>', node.id, '</a>'].join('');
    });

  }

  function init() {
    $('form', $(NODE)).on('ajax:success', onFindReception);

    if (HEADERS.length==0) {
      $('[data-field]', $(SUBMISSIONS_NODE)).each(function(pos, element) {
        HEADERS.push({field: $(element).data('field'), title: $(element).text()})
      });
    }
  }
  $(document).on('turbolinks:load', init);

}(jQuery))
