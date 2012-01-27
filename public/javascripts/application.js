$(document).ready(function() { 
  $("#slow-queries").tablesorter();

  $("#change-profiling-level").bind("click", function(){
    $("#modal-change-profiling-level").modal();
    return false;
  })
  
  $("#show-collections").bind("click", function(){
    $("#modal-show-collections").modal();
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
  
  $(".query-summary").bind("click", function(){
		tr = $(this).parent();
		params = {
			ns: $(this).find('.query-ns:first').text(),
			query: JSON.parse($(this).find('.query-dump:first').text()) // bad?
		};
    
		body = "<table>" + tr.text()
		body += "<h2>" + params['query'] + " </h2>";
		body += "</table>";
		body += "<h2>Explain:</h2><div id='explain-result'></div>";
		$.modal(body, {
		  overlayClose: true, 
			minHeight: 200, 
			minWidth: 400
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
