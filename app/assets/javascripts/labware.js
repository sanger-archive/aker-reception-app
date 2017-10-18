// enable/disable the decapper option on the labware page

function isDecappableSelected() {
  return $(".labwaretype:checked").hasClass("decappable");
}

function isSupplyLabwareSelected() {
  return ($(".supplylabware").val()=="true");
}

function enableDecapper() {
  if (isDecappableSelected() && isSupplyLabwareSelected()) {
    $(".supplydecapper").parent().show();
  } else {
    $(".supplydecapper").parent().hide();
  }
}

$(document).on("turbolinks:load", function() {
  $(".labwaretype").change(enableDecapper);
  $(".supplylabware").change(enableDecapper);
  enableDecapper();
});
