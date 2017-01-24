(function($,undefined) {
  var HEADERS =[];
  var NODE = '.claimed-sets';
  var SUBMISSIONS_NODE = ".claiming-display .submission-list"

  function onClaimedSetsReception(data, status, xhr) {
    $('.table', $(NODE)).bootstrapTable('destroy');
    $('.table', $(NODE)).bootstrapTable({data: data, columns: HEADERS});


    $('.table tbody tr', $(NODE)).each(function(pos, node) {
      var list = $('td', node);
      var form = $("<form method='post' class='form' data-remote='true' action='"+data[pos].uuid+"''></form>")
      var claimingButton = $('<button class="btn btn-default">Claim</button>');
      form.append(claimingButton);
      claimingButton.on('click', $.proxy(claim, this, form));
      $(list[list.length - 1]).html(form);
    });
    if (data.length > 0) {
      $(NODE).trigger('dragAndDrop.attachHandlers');
    }
  }

  function claim(form) {
    var submissionIds = $($('table', $(SUBMISSIONS_NODE))).bootstrapTable('getAllSelections').map(function(node, pos) {
      return node.id;
    });
    $(form).append($("<input name='claimedSubmissions' type='hidden' value='"+JSON.stringify(submissionIds)+"' />"));

    $(form).on('ajax:success', function() { 
      window.reload();
    });
  }

  function init() {
    var serviceUrl = $(NODE).data('service-url');
    $.get(serviceUrl, onClaimedSetsReception)

    if (HEADERS.length == 0) {
      $('[data-field]', $(NODE)).each(function(pos, element) {
        HEADERS.push({field: $(element).data('field'), title: $(element).text()})
      });      
    }

  }
  $(document).on('turbolinks:load', init);
  $(document).ready(init);
  
}(jQuery))
