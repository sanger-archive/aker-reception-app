(function($,undefined) {
  var HEADERS =[];
  var NODE = ".claiming-display .email-input";
  var SUBMISSIONS_NODE = ".claiming-display .submission-list"

  function onFindReception(e, data, status, xhr) {
    $('.table', $(SUBMISSIONS_NODE)).bootstrapTable('destroy');
    $('.table', $(SUBMISSIONS_NODE)).bootstrapTable({data: data, columns: HEADERS});
    $('.table tbody tr', $(SUBMISSIONS_NODE)).each(function(pos, node) {
      $(node).attr('draggable', true);
      $(node).on('dragstart', function(event) {
        var submissionIds = $($('table', $(SUBMISSIONS_NODE))).bootstrapTable('getAllSelections').map(function(node, pos) {
          return node.id;
        });
        if (submissionIds.length>0) {
          event.originalEvent.dataTransfer.setData("text", event.target.id);
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

    $('[data-field]', $(SUBMISSIONS_NODE)).each(function(pos, element) {
      if (HEADERS.length == 0) {
        HEADERS.push({field: $(element).data('field'), title: $(element).text()})
      }
    });

  }
  $(document).on('turbolinks:load', init);
  $(document).ready(init);

}(jQuery))
