// Listen to scroll to change navbar opacity
function checkScroll() {
  var startY = $('.navbar').height() * 2; // Line the navbar changes (in px)

  if ($(window).scrollTop() > startY) {
    $('.navbar').addClass("scrolled");
  } else{
    $('.navbar').removeClass("scrolled");
  }
}
$(document).ready(function() {
  if ($('.navbar').length > 0) {
    $(window).on("scroll load resize", function() {
      checkScroll();
    });
  }
});
