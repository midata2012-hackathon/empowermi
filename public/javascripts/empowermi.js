(function($){

  //internals
  var keyStat = 'Energy bill';
  
  function recTemplate(text, value) {
    var id = _.uniqueId('rec-item-')
    var box = $('<input />', {id: id, name: id, type: 'checkbox', value: value}).change(function(){
      if($(this).is(':checked')) {
        h.check(text, value);
      } else {
        h.unCheck(text, value);
      }
      h.drawChart();
    });
    var label = $('<label />', {for: id, text: text});
    return $('<li class="recommended-item">').append(box).append(label)
  };

  function showRec() {
    var container = $("#recommendations ul");
    $.each(h.recommendations, function(text, value){
      container.append(recTemplate(text, value));
    });
  };

  function parse(personaData) {
    h.toDraw[keyStat] = personaData.spendings[0].cost
    $.each(personaData.recommendations, function(i,r){
      h.recommendations[r.recommendation] = r.saving;
      h.colors[r.recommendation] = r.color;
    });
  };

  function colorForItem(name) {
    return Raphael.color(h.colors[name]||"#4AE371");
  };
  
  //main object
  var h = {
    toDraw: {},
    recommendations: {},
    colors: {},
    check: function(key, value) {
      this.toDraw[key] = value;
      this.toDraw[keyStat] -= value;
    },
    unCheck: function(key, value) {
      this.toDraw[keyStat] += value;
      delete this.toDraw[key]; 
    },
    apiCall: function(personaId) {
      $.ajax('/api', {
        dataType: 'json',
        success: function(personaData){
          parse(personaData)
          showRec();
          h.drawChart();
        }
      });
    },
    drawChart: function() {
      $("#chart").html('')
      var r = Raphael("chart"),
      data = [],
      colors = [],
      txtattr = { font: "12px sans-serif" };

      //r.text(480, 250, 'Multiline Series Stacked Vertical Chart. Type "round"').attr(txtattr);

      for(var key in (h.toDraw)) {
        data.push([h.toDraw[key]]);
        colors.push(colorForItem(key))
      }
      r.barchart(0, 0, 300, 400, data, {stacked: true, colors: colors});
    }
  };
  
  //on-load
  $(function(){
    h.apiCall('');
  });
  
  window.h = h;
})(jQuery)
