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
        if (data.key == "Escape") { // Escape key
            $.post('https://qb-radio/escape', JSON.stringify({}));
        } else if (data.key == "Enter") { // Enter key
            $.post('https://qb-radio/joinRadio', JSON.stringify({
                channel: $("#channel").val()
            })).then((data) => {
                if (data.canaccess) {
                    $("#channel").val(data.channel)
                }
            });
        }
    };
});

QBRadio = {}

$(document).on('click', '#submit', function(e){
    e.preventDefault();

    $.post('https://qb-radio/joinRadio', JSON.stringify({
        channel: $("#channel").val()
    })).then((data) => {
        if (data.canaccess) {
            $("#channel").val(data.channel)
        }
    });
});

$(document).on('click', '#disconnect', function(e){
    e.preventDefault();

    $.post('https://qb-radio/leaveRadio');
});

$(document).on('click', '#volumeUp', function(e){
    e.preventDefault();

    $.post('https://qb-radio/volumeUp', JSON.stringify({
        channel: $("#channel").val()
    }))
});

$(document).on('click', '#volumeDown', function(e){
    e.preventDefault();

    $.post('https://qb-radio/volumeDown', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#decreaseradiochannel', function(e){
    e.preventDefault();

    $.post('https://qb-radio/decreaseradiochannel', JSON.stringify({
        channel: $("#channel").val()
    })).then((data) => {
        if (data.canaccess) {
            $("#channel").val(data.channel)
        }
    });
});

$(document).on('click', '#increaseradiochannel', function(e){
    e.preventDefault();

    $.post('https://qb-radio/increaseradiochannel', JSON.stringify({
        channel: $("#channel").val()
    })).then((data) => {
        if (data.canaccess) {
            $("#channel").val(data.channel)
        }
    });
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
