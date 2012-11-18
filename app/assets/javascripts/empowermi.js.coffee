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
  description = $("<span />",
    text: value.description
  )
  slug = value.recommendation.toLowerCase().replace(/\s/g, "-")
  image = $("<img />",
    src: "images/#{slug}.jpg"
  )
  $('<li class="recommended-item">').append(image).append(box).append(label).append(description)

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
  Raphael.color h.colors[name] or "#4AE371"

keyStat = "Energy bill"

#main object
h =
  toDraw: {}
  recommendations: {}
  colors: {}
  check: (key, value) ->
    @toDraw[key] = value
    @toDraw[keyStat] -= value

  unCheck: (key, value) ->
    @toDraw[keyStat] += value
    delete @toDraw[key]

  apiCall: (personaId) ->
    personaId ||= 'rbfish'
    $.ajax "/api#{personaId}",
      dataType: "json"
      success: (personaData) ->
        parse personaData
        showRec()
        h.drawChart()

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
