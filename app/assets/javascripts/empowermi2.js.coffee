#internals
#
r = {
   "name": "scale",
   "children": [
    {"name": "IScaleMap", "size": 2105},
    {"name": "LinearScale", "size": 1316},
    {"name": "LogScale", "size": 3151},
    {"name": "OrdinalScale", "size": 3770},
    {"name": "QuantileScale", "size": 2435},
    {"name": "QuantitativeScale", "size": 4839},
    {"name": "RootScale", "size": 1756},
    {"name": "Scale", "size": 4268},
    {"name": "ScaleType", "size": 1821},
    {"name": "TimeScale", "size": 5833}
   ]
  }
      
recTemplate = (text, value) ->
  id = _.uniqueId("rec-item-")
  box = $("<input />",
    id: id
    name: id
    type: "checkbox"
    value: value
  ).change(->
    if $(this).is(":checked")
      h.check text, value
    else
      h.unCheck text, value
    h.drawChart()
  )
  label = $("<label />",
    for: id
    text: text
  )
  $('<li class="recommended-item">').append(box).append label

showRec = ->
  container = $("#recommendations ul")
  $.each h.recommendations, (text, value) ->
    container.append recTemplate(text, value)

parse = (personaData) ->
  h.toDraw[keyStat] = personaData.spendings[0].cost
  $.each personaData.recommendations, (i, r) ->
    h.recommendations[r.recommendation] = r.saving
    h.colors[r.recommendation] = r.color

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
    $.ajax "/api",
      dataType: "json"
      success: (personaData) ->
        parse personaData
        showRec()
        h.drawChart()
  
  intoNode: (name, value )->
    name: name
    size: parseInt(value * 100)


  drawChart: ->
    children = (h.intoNode(name, value) for name, value of h.toDraw)
    h.draw
      name: 'not sure',
      children: children

  draw: (root)->
    $("#chart").html('')
    diameter = 480
    format = d3.format(",d")
    pack = d3.layout.pack().size([diameter - 4, diameter - 4]).value((d) ->
      d.size
    )
    svg = d3.select("#chart").append("svg").attr("width", diameter).attr("height", diameter).append("g").attr("transform", "translate(2,2)")

    node = svg.datum(root).selectAll(".node").data(pack.nodes).enter().append("g").attr("class", (d) ->
      (if d.children then "node" else "leaf node")
    ).attr("transform", (d) ->
      "translate(" + d.x + "," + d.y + ")"
    )
    node.append("title").text (d) ->
      d.name + ((if d.children then "" else ": " + format(d.size)))

    node.append("circle").attr('class', ((d) -> if d.name == keyStat then "spending" else "saving" )).attr "r", (d) ->
      d.r

    node.filter((d) ->
      not d.children
    ).append("text").attr("dy", ".3em").style("text-anchor", "middle").text (d) ->
      d.name.substring 0, d.r / 3


    d3.select(self.frameElement).style "height", diameter + "px"

#on-load
$ ->
  h.apiCall ""

window.h = h
