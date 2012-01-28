$(document).ready(function() { 
  $("#slow-queries").tablesorter();

  $("#change-profiling-level").bind("click", function(){
    $("#modal-change-profiling-level").modal();
    return false;
  })
  
  $("#show-collections").bind("click", function(){
    $("#modal-show-collections").modal({
		  overlayClose: true, 
			minWidth: 200
		});
    return false;
  })
  
  $("#reset-query-log").bind("click", function(){
    $("#modal-reset-query-log").modal();
    return false;
  })

  $("#slow-queries tr").bind("click", function(){
    if ($(this).hasClass("tr-highlighted")) {
      $(this).removeClass("tr-highlighted");
    } else {
      $(this).addClass("tr-highlighted");
    }
  })
   
  $(".query-explain").click(function(){
		tr = $(this).parent();
		params = {
			ns: tr.find('.query-ns:first').text(),
			// op:
			query: JSON.parse(tr.find('.query-dump:first').text()) // bad?
		};
    
		body = "<table>" + tr.parent().text() + "</table>";
		body += "<h2>Explain:</h2><div id='explain-result'></div>";
		$.modal(body, {
		  overlayClose: true, 
			minHeight: 200, 
			minWidth: 650
		});
		$.post("/explain/" + $('#database_name').text(), params)
			.success(function(data) {	$('#explain-result').html(data);});
    return false;
	})

  $(".confirm-link").bind("click", function(){
    if (confirm("Really?")) {
      window.location($(this).attr("href"));
    } else {
      return false;
    }
  })

}); 
