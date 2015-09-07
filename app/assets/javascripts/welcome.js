
$(document).ready(function(){
});

function data_upload_callback(){
  $.ajax({
    url: "/upload_status"
  }).done(function() {
    alert("file imported");
  }).fail(function() {
    setTimeout(data_upload_callback, 2000);
  });
  
}