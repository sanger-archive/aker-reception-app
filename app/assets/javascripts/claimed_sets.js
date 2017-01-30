(function($,undefined) {
  var HEADERS =[];
  var NODE = '.claimed-sets';
  var SUBMISSIONS_NODE = ".claiming-display .submission-list"

  function onClaimedSetsReception(data, status, xhr) {
    $('.table', $(NODE)).bootstrapTable('destroy');
    $('.table', $(NODE)).bootstrapTable({data: data, columns: HEADERS});


    $('.table tbody tr', $(NODE)).each(function(pos, node) {
      var list = $('td', node);
      var collectionId = data[pos].uuid;
      var form = $("<form method='post' class='form' data-remote='true' action='/material_submissions/claim'></form>") //claim url
      var claimingButton = $('<button class="btn btn-default">Claim</button>');
      form.append(claimingButton);
      claimingButton.on('click', $.proxy(claim, this, form, collectionId));
      $(list[list.length - 1]).html(form);
    });
    if (data.length > 0) {
      $(NODE).trigger('dragAndDrop.attachHandlers');
    }
  }

  function claim(form, collectionId) {
    var submissionIds = $($('table', $(SUBMISSIONS_NODE))).bootstrapTable('getAllSelections').map(function(node, pos) {
      return node.id;
    });
    $(form).append($("<input name='submission_ids' type='hidden' value='"+JSON.stringify(submissionIds)+"' />"));
    $(form).append($("<input name='collection_id' type='hidden' value='"+collectionId+"' />"));

    $(form).on('ajax:success', function() { 
      window.reload();
    });
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
