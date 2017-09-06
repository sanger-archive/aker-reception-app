(function($,undefined) {
  var SUBMISSIONS_NODE = ".claiming-display"

  function getSelectedRowsIds(submissionTable) {
    return submissionTable.bootstrapTable('getAllSelections').map(function(node, pos) {
      return node.id;
    });
  }

  function setupClaiming(){
    // Cache the jQuery elements
    var submissionTable = $('.table', $(SUBMISSIONS_NODE));
    var stampSelect     = $('#stamp_id');
    var stampButton     = $('#stamp_button');
    var submissionIds   = $('#_submission_ids');

    // Initialise it as a Bootstrap table
    submissionTable.bootstrapTable();

    // On any check events we want to either enable the Stamp button (if something is selected)
    // or disable it if nothing is selected. We also want to build the list of submission ids as
    // hidden inputs from the bootstrap table
    var checkEvents = "check.bs.table uncheck.bs.table check-all.bs.table uncheck-all.bs.table";
    submissionTable.on(checkEvents, function(e) {
      var selectedRowIds = getSelectedRowsIds(submissionTable);

      $('input.hidden-submission-id').remove();

      selectedRowIds.forEach(function(submissionId) {
        submissionIds.clone()
                     .removeAttr("id")
                     .addClass("hidden-submission-id")
                     .val(submissionId)
                     .insertAfter(submissionIds);
      });

      stampButton.prop("disabled", (selectedRowIds.length == 0));
    });

  }

  $(document).on('turbolinks:load', setupClaiming);

}(jQuery))
