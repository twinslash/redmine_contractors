// Observ field function
$(document).ready(function() {

  var internal_field = $('.internal_fields');
  var external_field = $('.external_fields');

  if ($('[id^="person_contact_type"][checked="checked"]').val() == 'internal') {
    internal_field.show();
    external_field.hide();
  } else {
    internal_field.hide();
    external_field.show();
  }

  $('#person_contact_type_internal').click(function() {
    $('.internal_fields').show('slow');
    $('.external_fields').hide('slow');
    $('.external_fields').find('select, input').attr('disabled', 'disabled');
    $('.internal_fields').find('select, input').removeAttr('disabled');
  });

  $('#person_contact_type_external').click(function() {
    $('.internal_fields').hide('slow');
    $('.external_fields').show('slow');
    $('.internal_fields').find('select, input').attr('disabled', 'disabled');
    $('.external_fields').find('select, input').removeAttr('disabled');
  });

});



(function( $ ){

  jQuery.fn.observe_field = function(frequency, callback) {

    frequency = frequency * 100; // translate to milliseconds

    return this.each(function(){
      var $this = $(this);
      var prev = $this.val();

      var check = function() {
        if(removed()){ // if removed clear the interval and don't fire the callback
          if(ti) clearInterval(ti);
          return;
        }

        var val = $this.val();
        if(prev != val){
          prev = val;
          $this.map(callback); // invokes the callback on $this
        }
      };

      var removed = function() {
        return $this.closest('html').length == 0
      };

      var reset = function() {
        if(ti){
          clearInterval(ti);
          ti = setInterval(check, frequency);
        }
      };

      check();
      var ti = setInterval(check, frequency); // invoke check periodically

      // reset counter after user interaction
      $this.bind('keyup click mousemove', reset); //mousemove is for selects
    });

  };

})( jQuery );
