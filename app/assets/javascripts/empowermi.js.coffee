#internals
recTemplate = (text, value) ->
  console.log(value)
  id = _.uniqueId("rec-item-")
  box = $("<input />",
    id: id
    name: id
    type: "checkbox"
    value: value.saving
  ).change(->
    if $(this).is(":checked")
      h.check text, value.saving
    else
      h.unCheck text, value.saving
    h.drawChart()
  )
  label = $("<label />",
    for: id
    text: text
  )
  how_it_works = "<div class='how_it_works'><strong>How it works:</strong> #{value.how_it_works}</div>" 
  help_available = "<div class='help_available'><strong>Help available:</strong> #{value.help_available}</div>" 

  slug = value.recommendation.toLowerCase().replace(/\s/g, "-")
  image = $("<img />",
    src: "images/#{slug}.jpg"
  )
  $('<li class="recommended-item">').append(image).append(box).append(label).append(how_it_works).append(help_available)

showRec = ->
  container = $("#recommendations ul")
  $.each h.recommendations, (text, value) ->
    container.append recTemplate(text, value)

showPersonalInformation = (personaData) ->
  $("#name").html(personaData.name)
  $("#postcode").html(personaData.postcode)
  $("#property").html(personaData.property_type)

parse = (personaData) ->
  showPersonalInformation(personaData)
  h.toDraw[keyStat] = personaData.spendings[0].cost
  $.each personaData.recommendations, (i, r) ->
    h.recommendations[r.recommendation] = r 
    h.colors[r.recommendation] = r.color

colorForItem = (name) ->
  Raphael.color h.colors[name] or "#A74A45"

keyStat = "Energy bill"

#main object
h =
  maxSpending: 0
  toDraw: {}
  recommendations: {}
  colors: {}
  check: (key, value) ->
    @toDraw[key] = value
    @toDraw[keyStat] -= value
    h.updateSavings() 

  unCheck: (key, value) ->
    @toDraw[keyStat] += value
    delete @toDraw[key]
    h.updateSavings() 

  apiCall: (personaId) ->
    personaId ||= 'rbfish'
    $.ajax "/api#{personaId}",
      dataType: "json"
      success: (personaData) ->
        parse personaData
        showRec()
        h.drawChart()
        h.updateTotalSpending()
  
  updateTotalSpending: ->
    h.maxSpending = h.toDraw[keyStat]
    $("h4:first").html("Last year you spent £#{h.toDraw[keyStat]} on your energy")
  updateSavings: ->
    $("h4.new_figure").html("Projected savings £#{Math.abs (h.toDraw[keyStat] - h.maxSpending).toFixed(2)} on your energy")
  drawChart: ->
    $("#chart").html ""
    r = Raphael("chart")
    data = []
    colors = []
    txtattr = font: "12px sans-serif"
    
    #r.text(480, 250, 'Multiline Series Stacked Vertical Chart. Type "round"').attr(txtattr);
    for key of (h.toDraw)
      data.push [h.toDraw[key]]
      colors.push colorForItem(key)
    r.barchart 0, 0, 300, 400, data,
      stacked: true
      colors: colors

#on-load
$ ->
  h.apiCall window.personaId

window.h = h
