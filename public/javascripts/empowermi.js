$(function() {
    console.log(data);
    $('#name').html(data.name);
    displayRecomendations(data.recomendations);
});

var displayRecomendations = function(recomendations) {
    var recomendationsEl = document.createElement("ul");
    $.each(recomendations, function(index, value) { 
        alert(index + ': ' + value);
        var listEl = document.createElement("li");       
    });
}
