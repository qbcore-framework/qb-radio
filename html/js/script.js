$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "open") {
            QBRadio.SlideUp()
        }

        if (event.data.type == "close") {
            QBRadio.SlideDown()
        }
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('https://qb-radio/escape', JSON.stringify({}));
            QBRadio.SlideDown()
        } else if (data.which == 13) { // Enter key
            $.post('https://qb-radio/joinRadio', JSON.stringify({
                channel: $("#channel").val()
            }));
        }
    };
});

QBRadio = {}
$(document).on('click', '#list', function(e){

    fetch("https://qb-radio/getPlayers", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({}),
  }).then((resp) =>
    resp.json().then((resp) => {
        const pdada = resp;
        const playerParent = document.getElementById("playerlistcontaner");
        playerParent.innerHTML = ``;
        if (pdada) {
            for (let i = 0; i < pdada.length; i++) {
                const playerdata = pdada[i];
                
                const playerCart = document.createElement("div");
                playerCart.id = playerdata.pid;
                playerCart.innerHTML = `[${playerdata.pid}] ${playerdata.name}`;
                playerParent.appendChild(playerCart);
            }
        }
    })
  );

    $("#playerlistcontaner").toggle();
});

$(document).on('click', '#submit', function(e){
    e.preventDefault();

    $.post('https://qb-radio/joinRadio', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#disconnect', function(e){
    e.preventDefault();

    $.post('https://qb-radio/leaveRadio');
});

$(document).on('click', '#volumeUp', function(e){
    e.preventDefault();

    $.post('https://qb-radio/volumeUp', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#volumeDown', function(e){
    e.preventDefault();

    $.post('https://qb-radio/volumeDown', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#decreaseradiochannel', function(e){
    e.preventDefault();
    var current =  $("#channel").val() - 1;
    if(current > 0)
    {
        $.post('https://qb-radio/decreaseradiochannel', JSON.stringify({
            channel: $("#channel").val()
        }));
        $("#channel").val("");
        $("#channel").val(current);
    }
});

$(document).on('click', '#increaseradiochannel', function(e){
    e.preventDefault();
    var current =  parseInt($("#channel").val()) + 1;
    if (current > 0)
    {
        $.post('https://qb-radio/increaseradiochannel', JSON.stringify({
            channel: $("#channel").val()
        }));
        $("#channel").val("");
        $("#channel").val(current);
    }
});

$(document).on('click', '#poweredOff', function(e){
    e.preventDefault();

    $.post('https://qb-radio/poweredOff', JSON.stringify({
        channel: $("#channel").val()
    }));
});

QBRadio.SlideUp = function() {
    $(".container").css("display", "block");
    $(".radio-container").animate({bottom: "6vh",}, 250);
}

QBRadio.SlideDown = function() {
    $(".radio-container").animate({bottom: "-110vh",}, 400, function(){
        $(".container").css("display", "none");
    });
}
