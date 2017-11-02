(function($,undefined) {
  var HEADERS =[];
  var NODE = '.claimed-sets';
  var SUBMISSIONS_NODE = ".claiming-display .submission-list"

  function onClaimedSetsReception(data, status, xhr) {
    $('.table', $(NODE)).bootstrapTable('destroy');
    $('.table', $(NODE)).bootstrapTable({data: data, uniqueId: 'uuid', columns: HEADERS});


    $('.table tbody tr', $(NODE)).each(function(pos, node) {
      var list = $('td', node);
      var collectionId = data[pos].uuid;
      var claimingButton = $('<button class="btn btn-default">Claim</button>');

      claimingButton.on('click', function(e) {
        var submissionIds = $($('table', $(SUBMISSIONS_NODE))).bootstrapTable('getAllSelections').map(function(node, pos) {
          return node.id;
        });

        Aker.claim(submissionIds, collectionId);
      });

      $(list[list.length - 1]).html(claimingButton);
    });
    if (data.length > 0) {
      $(NODE).trigger('dragAndDrop.attachHandlers');
    }
  }

  function init() {
    if (HEADERS.length == 0) {
      $('[data-field]', $(NODE)).each(function(pos, element) {
        HEADERS.push({field: $(element).data('field'), title: $(element).text()})
      });
    }
    var serviceUrl = $(NODE).data('service-url');
    $.get(serviceUrl, onClaimedSetsReception)

  }

  function turbolinksLoad(){
    $('.table').bootstrapTable({data: [], columns: HEADERS});
    init();
  }

  $(document).on('turbolinks:load', turbolinksLoad);
  $(document).ready(init);

}(jQuery))