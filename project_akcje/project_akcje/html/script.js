var companyName;
var companyShort;
var ownedCount;

$(function() {
    function display(bool) {
        if (bool) {
            $("#container").show();
        } else {
            close();
        }
    }
    display(false)

    function close(){
        $('tbody').html('');
        $("#container").hide();
    }

    window.addEventListener('message', function(event) {
        if (event.data.type === "ui") {
            if (event.data.status == true) {
                display(true)
            } else {
                display(false)
            }
        }
        if (event.data.type === 'actions') {
            $('tbody').prepend('<tr><th class="company-short" style="width: 100px">'+ event.data.short +'</th><th class="company-name" style="width: 300px">'+ event.data.companyName +'</th><th class="count" style="width: 100px">'+ event.data.count +'</th><th style="width: 40px; background-color: #474a46;"></th><th background-color: #474a46;"><button type="button" class="sellbtn">Sprzedaj</button></th></tr>')
        }
        if (event.data.type === 'showGielda') {
            $('#tableGielda').css('display', 'table')
            $('tbody').prepend('<tr><th class="company-short" style="width:100px">'+ event.data.short +'</th><th class="company-name" style="width: 300px">'+ event.data.companyName +'</th><th style="width:100px">'+ event.data.price + '$'+'</th><th style="width:100px">'+ event.data.changePer +'%'+'</th><th style="width:100px">'+ event.data.changeDol +'$'+'</th><th style="width: 40px; background-color: #474a46;"></th><th style="background-color: #474a46;"><button type="button" class="buybtn">Kup</button></th></tr>')
        }
    });

    $(document).on('click', '.buybtn', function() {
        var tr = $(this).closest('tr');
        companyName = tr.find(".company-name").text();
        companyShort = tr.find('.company-short').text();

        $('table').hide();
        $('.buySell').css('display', 'block');
        $('#title').html('Kup akcje firmy '+companyName);
    })

    $(document).on('click', '.sellbtn', function() {
        var tr = $(this).closest('tr');
        companyName = tr.find(".company-name").text();
        companyShort = tr.find('.company-short').text();
        ownedCount = tr.find('.count').text();

        $('table').hide();
        $('.buySell').css('display', 'block');
        $('#title').html('Sprzedaj akcje firmy '+companyName);
    })

    document.onkeyup = function(data) {
        if (data.which == 27) {
            $.post('https://project_akcje/NUIClose', JSON.stringify({}));
            $('#tableGielda').css('display', 'none')
            $('#tableOwned').css('display', 'table')
         }
    };

    $('#gielda').click(function(){
        $.post('https://project_akcje/insertGielda', JSON.stringify({}));
        $('.buySell').hide();
        $('#tableOwned').css('display', 'none')
        $('tbody').html('');
    })

    $('#akcje').click(function(){
        $.post('https://project_akcje/insertAkcje', JSON.stringify({}));
        $('.buySell').hide();
        $('#tableGielda').css('display', 'none')
        $('#tableOwned').css('display', 'table')
        $('tbody').html('');
    })
    
    $('#submit').click(function(){
        var buyorsell = $('#title').html()
        if (buyorsell.includes('Kup')) {
            var count = $('.value').val()
            if (count > 0) {
                $.post('https://project_akcje/buyActions', JSON.stringify({count: count, name: companyName, short: companyShort}));
            }
        } else {
            var count = $('.value').val()
            if (parseInt(count) > 0 && parseInt(count) <= parseInt(ownedCount)) {
                $.post('https://project_akcje/sellActions', JSON.stringify({count: count, name: companyName, short: companyShort, ownedCount: ownedCount}));
            }
        }
        $.post('https://project_akcje/NUIClose', JSON.stringify({}));
        $('.buySell').hide();
        $('#tableOwned').css('display', 'table')
        $('tbody').html('');
    })
})