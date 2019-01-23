import $ from 'jquery'

// enable/disable the decapper option on the labware page
(function () {
  window.isDecappableSelected = function () {
    return $('.labwaretype:checked').hasClass('decappable')
  }

  window.isSupplyLabwareSelected = function () {
    return ($('.supplylabware').val() === 'true')
  }

  window.enableDecapper = function () {
    if (window.isDecappableSelected() && window.isSupplyLabwareSelected()) {
      $('.supplydecapper').parent().show()
    } else {
      $('.supplydecapper').parent().hide()
    }
  }

  $(document).on('turbolinks:load', function () {
    $('.labwaretype').change(window.enableDecapper)
    $('.supplylabware').change(window.enableDecapper)
    window.enableDecapper()
  })
}())
