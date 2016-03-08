
//#region Global Variables

/**** Timeline global variables ****/

var _TL_DATA = null;
var _TL_STARTDATE = "";
var _TL_ENDDATE = "";

/**** FBS Player global variables ****/

var previousSecs = 0;

/**** General global variables ****/

var MAX_DOWNLOAD_FILES = 6;
var GLOBALPLAY_DEFAULT_DURATION = 6;
var GLOBALPLAY_DEFAULT_DURATION_EXTRA = 1;
var GLOBALPLAY_LABEL_DEFAULT_DURATION = 16; 
var GLOBALPLAY_MAX_COLLISION_ELEMENTS = 6;
var SVG_Height = 170;
var addComment_active = false;
var addFile_active = false;
var globalplay_active = false;
var oldPlayer_activeElement_type = "";
var oldPlayer_activeElement_extension = "";
var oldPlayer_activeElement_duration = "";
var comment_popup_timestamp = "";
var initial_size = 0;
var selectedElementID = 0;
var currentPointerPositionDate_str;
var elementsInMemory = [];
var globalplay_remove_elements = [];
var globalplay_stack_elements = [[], []]; // [object, already_taken: bool]
var globalplay_playback_active = false;

// Timeline Global Pointer
var TIMELINE_POINTER = $("#sm2-progress-ball_TIMELINE");
var PLAYER_BOX = $("#divPanel_PlayerControl div[id*='playerBox']");


// Get screen resolution
var MONITOR_WIDTH = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
var MONITOR_HEIGHT = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);

// GLOBAL PLAY variables
var GLOBALPLAY_seconds_current = 0;
var GLOBALPLAY_seconds_total = 0;

/**** Extras variables ****/

// Variable object types
var TYPES = {
    'undefined': 'undefined',
    'number': 'number',
    'boolean': 'boolean',
    'string': 'string',
    '[object Function]': 'function',
    '[object RegExp]': 'regexp',
    '[object Array]': 'array',
    '[object Date]': 'date',
    '[object Error]': 'error'
},
 TOSTRING = Object.prototype.toString;


//#endregion 

//#region ON READY

/**** On page init ****/

$(document).ready(function () {

    // Check JS Message file loaded OK, if not load default values
    try {
        if (!hashMessages) {
            console.log("Importante: Alert_Messages.js ==> hashMessages no encontrado.")
            LoadAlertMessagesBackup();
        }
    } catch (err) {
        console.log("Importante: Alert_Messages.js ==> hashMessages no encontrado.")
        LoadAlertMessagesBackup();
    }

    // Load alert message: Get Webchimera install url from web.config
    var Webchimera_Install_URL = "https://github.com/RSATom/WebChimera/releases/download/v0.2.9/WebChimera_0.2.9_vlc_2.2.1.msi";
    var _hdnWebchimera_Install_URL = $("#_hdnWebchimera_Install_URL");
    if (_hdnWebchimera_Install_URL != null && _hdnWebchimera_Install_URL.val() != null && _hdnWebchimera_Install_URL.val().length > 0) {
        Webchimera_Install_URL = _hdnWebchimera_Install_URL.val();
    }
    hashMessages["InstallWebchimera_url"] = Webchimera_Install_URL;

    getElementsInMemory();
    loadHiddenFields();
    initVariables();

    initial_size = $('#divPanel_Busqueda').css('width');
    var pnlTagTypes = $("#divPanel_Busqueda div[id$='pnlTagTypes']");
    if (pnlTagTypes != null && pnlTagTypes.length) {
        pnlTagTypes.css("margin-top", "-13px");
    }

    // Initial focus
    $("#divPanel_Busqueda input[id*='_txbSearchBox1']").focus();

    // Events on Ready ---------------------------------------------------

    /**** Date time picker control: comment date ****/
    $('#commentDate').inputmask({
        mask: "1-2-y h:s:s",
        placeholder: "dd-mm-yyyy HH:mm:ss",
        alias: "datetime",
        separator: "-",
        hourFormat: "24"
    });
    $("#divUpload input[id*='uploadDate']").inputmask({
        mask: "1-2-y h:s:s",
        placeholder: "dd-mm-yyyy HH:mm:ss",
        alias: "datetime",
        separator: "-",
        hourFormat: "24"
    });

    $("#divCamaras input[id*='camarasDate1']").inputmask({
        mask: "1-2-y h:s",
        placeholder: "dd-mm-yyyy HH:mm",
        alias: "datetime",
        separator: "-",
        hourFormat: "24"
    });

    $("#divCamaras input[id*='camarasDate2']").inputmask({
        mask: "1-2-y h:s",
        placeholder: "dd-mm-yyyy HH:mm",
        alias: "datetime",
        separator: "-",
        hourFormat: "24"
    });

    /**** Event: OnClick check all elements at left grid ****/ // TEST THIS COMMENT
    //loadGridCheckboxAll_event();

    /**** Event: OnClick Load on click event remove button ****/ // TEST THIS COMMENT
    //loadClickRemoveElementSelected_event();

    /**** Event: OnClick Load on click event fullscreen button for Screen recording elements ****/
    loadClickFullscreen_event();

    /**** Slider control: comment duration ****/
    $("#sliderSingle1").slider({
        from: 1,
        to: GLOBALPLAY_seconds_total, // 3600 seg
        step: 1,
        round: 1,
        format: {
            format: '##',
            locale: 'de'
        },
        dimension: '&nbsp;' // seg
        //skin: "round"
    });

    /**** Progress Pointer settings ****/
    currentPointerPositionDate_str = _TL_STARTDATE;

    // If the folio selected is not valid, then hides the Pointer from timeline
    TIMELINE_POINTER.hide();

    // If there are elements loaded, show timeline pointer
    var first_tapeID = 0;
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        first_tapeID = elementsInMemory[0].tapeID;
        var first_tapeID_int = parseInt(first_tapeID, 10);

        if (first_tapeID_int > 0) {
            TIMELINE_POINTER.show();
            timeline_pointer_setLocation(first_tapeID_int);
        }
    }

    TIMELINE_POINTER.css("top", "5px");
    $('.popbox4').popbox4();

    // Event Drag & Drop ********

    // Source: http://www.elated.com/articles/drag-and-drop-with-jquery-your-essential-guide/
    if (TIMELINE_POINTER != null) {
        TIMELINE_POINTER.draggable({
            containment: '#divTimelineProgress',
            axis: "x",
            scroll: false,
            cursor: 'move',
            stop: handleDragStop,
            drag: handleDragging
        });
    }

    // If timeline is already drawn, set to divTimelineProgress the main line real width 
    divTimelineProgress_SetWidth();

    /**** Load Globalplay settings ****/
    loadGlobalplay_settings();

    // Remove padding, set opening and closing animations, close if clicked and disable overlay
    $("#btnOpenFancybox").fancybox({
        padding: 0,
        closeClick: false,

        openEffect: 'elastic',
        openSpeed: 150,

        closeEffect: 'elastic',
        closeSpeed: 150,

        beforeShow: function () {
            $("#divgp_sc").show();
            $('<div id="timer-labels"><label id="lblGlobalplay_timer_current" class="label" style="font-size:100%; color:black;">00:00:00</label> / <label id="lblGlobalplay_timer_total" class="label" style="font-size:100%; color:black;">00:00:00</label></div>').appendTo("#divgp_sc");
        },

        afterClose: function () {
            $("#divgp_sc").hide();
            $("#divgp_sc #timer-labels").remove();
            $("#globalPlayer_popup").show();            
        },

        helpers: {
            overlay: null
        }
    });

    if (typeof $(".flex").flex != "undefined") {
        $(".flex").flex();
    }

    // Fancybox Source 1: http://fancybox.net/
    // Fancybox Source 2: http://devtroce.com/2011/07/19/como-manejar-un-iframe-con-fancybox-y-jquery-en-modo-popup/

    // Flex Source: http://www.jsonenglish.com/projects/flex/

    // Image player styles
    var playerBox_h = parseInt(PLAYER_BOX.css("height"), 10);
    $("#imgPlayer").css("max-height", playerBox_h);

    // Globalplay play button click effects
    $("#globalplay_play").click(function () {
        $(this).effect("scale", {}, 10);
    });

    $("#globalplay_stop").click(function () {
        $(this).effect("scale", {}, 10);
    });

    /*
    // Locate Popbox3 - Remove element TODO
    var divPopbox3 = $("#divPopbox3");
    var btn_left = $("#btnRemoveElement").offset().left;
    var width_int = parseInt(divPopbox3.css("width"), 10);
    var left_final = btn_left - width_int;
    divPopbox3.offset({ left: left_final });


    $("#divPopbox3").offset({ left: $("#btnRemoveElement").offset().left - parseInt($("#divPopbox3").css("width"), 10) });
    */

}); // END On Ready


/**** Load Folios ID to UploadFile and AddComment ****/
function loadFoliosID() {

    // Clear previous Folios ID
    $("#divFolioSelection_fileUpload").empty();
    $("#divFolioSelection_addComment").empty();

    var folioID = "";
    var _hdnFolioID = $("input[id*='_hdnFolioID']");
    if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {
        folioID = _hdnFolioID.val();

        var folio_split = folioID.split(',');
        if (folio_split != null && folio_split.length > 0) {
            for (var i = 0; i < folio_split.length; i++) {
                if (folio_split[i] != null) {
                    if (i == 0) {
                        $("#divFolioSelection_fileUpload").append('<input type="radio" name="rbFolios_fileUpload" style="margin-left:5px;" value="' + folio_split[i] + '" checked="true"> ' + folio_split[i] + '</input>')
                        $("#divFolioSelection_addComment").append('<input type="radio" name="rbFolios_addComment" style="margin-left:5px;" value="' + folio_split[i] + '" checked="true"> ' + folio_split[i] + '</input>')
                    } else {
                        $("#divFolioSelection_fileUpload").append('<input type="radio" name="rbFolios_fileUpload" style="margin-left:5px;" value="' + folio_split[i] + '"> ' + folio_split[i] + '</input>')
                        $("#divFolioSelection_addComment").append('<input type="radio" name="rbFolios_addComment" style="margin-left:5px;" value="' + folio_split[i] + '"> ' + folio_split[i] + '</input>')
                    }
                }
            }
        }
    }
}

function loadGlobalplay_settings() {

    // ************* Globalplay Timer settings *************

    var date_str2 = moment(_TL_ENDDATE, "DD-MM-YYYY HH:mm:ss");

    var actual_duration = getDuration_onDatetime(date_str2)

    GLOBALPLAY_seconds_total = actual_duration;

    // Get duration format: HH:mm:ss
    var total_sec_format = getFormatDuration(actual_duration);

    // Set timeline total duration
    $("#lblGlobalplay_timer_total").text(total_sec_format);
}

/**** Event: OnClick Load on click event fullscreen button for Screen recording elements ****/
function loadClickFullscreen_event() {

    $("#aBtnFullscreen").click(function (event) {
        event.preventDefault();
        var $this = $(this);

        var timer = 0;
        if (document.fbsviewer != null) {
            try {
                timer = (document.fbsviewer.getCurrTimeOffsetInMSec() / 1000).toString();
                document.fbsviewer.pause();
            } catch (err) {
                console.log("l:299 Error getCurrTimeOffsetInMSec fbsviewer");
                console.log(err);
            }
        }

        $(this).attr("data-popup", "width=" + FBS_POPUP_Width + ",height= " + FBS_POPUP_Height + ",scrollbars=yes");
        var url = "Fullscreen.aspx?segId=" + screenRecording_segmentID + "&width=" + FBS_FULLSCREEN_Width + "&height=" + FBS_FULLSCREEN_Height + "&currentSecs=" + timer;
        //var url = "http://localhost:7070/Fullscreen.aspx?segId=" + screenRecording_segmentID + "&width=" + FBS_FULLSCREEN_Width + "&height=" + FBS_FULLSCREEN_Height + "&currentSecs=" + timer;

        var windowName = "popUp";
        var windowSize = $this.data("popup");

        window.open(url, windowName, windowSize);
    });
}

/**** Event: OnClick Load on click event remove button ****/
function loadClickRemoveElementSelected_event() {

    $("#btnRemoveElementSelected").bind("click", function () {

        // Get only visible and checked checkboxes to remove
        var list_elements = [];
        $('tr:visible td input:checked').each(function () {
            list_elements.push($(this).attr('value'));
        });
        if (list_elements.length > 0) {

            $("#dialog p").text(hashMessages["ConfirmarBorrarElementos1"]);
            $("#dialog").dialog({
                resizable: false,
                height: 140,
                modal: true,
                buttons: {
                    "Confirmar": function () {
                        $(this).dialog("close");

                        // Confirma 1

                        $("#dialog p").text(hashMessages["ConfirmarBorrarElementos2"]);
                        $("#dialog").dialog({
                            resizable: false,
                            height: 140,
                            modal: true,
                            buttons: {
                                "Confirmar": function () {
                                    $(this).dialog("close");

                                    // Confirma 2

                                    $.ajax({
                                        type: "POST",
                                        url: "Dashboard.aspx/RemoveElementSelected",
                                        data: '{list_elements: "' + list_elements + '"}',
                                        contentType: "application/json; charset=utf-8",
                                        dataType: "json",
                                        success: function (response) {

                                            $("#dialog p").text(hashMessages["ElementosBorrados"]);
                                            $("#dialog").dialog({
                                                buttons: {
                                                    "Confirmar": function () {
                                                        $(this).dialog("close");
                                                    }
                                                }
                                            });

                                            // Hide elements from search panel
                                            $('tr:visible td input:checked').parent().parent().hide();

                                            // Disable element in memory elements 
                                            var _hdnIsUpdateNeeded = $("#_hdnIsUpdateNeeded");
                                            if (
                                                _hdnIsUpdateNeeded != null) {
                                                _hdnIsUpdateNeeded.val("true");
                                            }

                                            // Clear player image
                                            $("#imgPlayer").attr("src", "");

                                            if (list_elements.length > 0) {

                                                //
                                                $("#timeframe").empty(); // Clean div content
                                                var new_timeline_data = jQuery.extend(true, {}, _TL_DATA); // It clones the object, does not references it
                                                for (var i = 0; i < list_elements.length; i++) {
                                                    if (list_elements[i] != null) {
                                                        var attrs_array = list_elements[i].split("#"); // Element attributes
                                                        if (attrs_array.length > 1) {
                                                            var tapeID = attrs_array[0];
                                                            if (tapeID != null && tapeID.length) {
                                                                if (new_timeline_data.spans != null && new_timeline_data.spans.length > 0) {
                                                                    new_timeline_data.spans = $
                                                                        .grep(
                                                                            new_timeline_data.spans,
                                                                            function (item, index) {
                                                                                return item.id != tapeID;
                                                                            }
                                                                        );
                                                                }
                                                            }
                                                        }
                                                    }
                                                } // for
                                                _TL_DATA = new_timeline_data;
                                                prepareTimelineReload(_TL_DATA);
                                            }

                                            // Update elements count
                                            $("#divPanel_Busqueda span[id*='lblResultsCount']").text($("#tblLeftGridElements tr[id*='tape_']:visible").length.toString());

                                        }, // end success
                                        failure: function (response) {
                                            alert(response.d);
                                        }
                                    });

                                },
                                Cancel: function () {
                                    $(this).dialog("close");
                                }
                            }
                        });
                    },
                    Cancel: function () {
                        $(this).dialog("close");
                    }
                }

            });

        } else {

            $("#dialog p").text(hashMessages["SeleccioneElemento"]);
            $("#dialog").dialog({
                buttons: {
                    "Confirmar": function () {
                        $(this).dialog("close");
                    }
                }
            });
        }
    });
}

/**** Event: OnClick check all elements at left grid ****/
function loadGridCheckboxAll_event() {
    $('#chbSelectAll').click(function (e) {

        // Clear div player
        removeDivPlayerContentExcept();

        // Stop fbs player if is active
        stopFBSPlayer();
        var table = $(e.target).closest('table');

        /* Warning: --- This is a Workaround to avoid click event changing the property --- */
        // Disable click events
        $('tr:visible td input:checkbox', table).attr('disabled', 'true');

        // Get only visible checkboxes
        $('tr:visible td input:checkbox', table).prop('checked', this.checked);

        // Enable click events
        $('tr:visible td input:checkbox', table).removeAttr('disabled');
        /* --- Workaround --- */

        var timeline_data = _TL_DATA; // Copy original timeline elements as reference
        var new_timeline_data = jQuery.extend(true, {}, _TL_DATA); // Clone the object, do not reference it
        var new_object = {};
        new_object.name = "Elements";
        new_object.color = "#000000";
        if (!this.checked) {
            if (new_timeline_data.spans != null &&
                new_timeline_data.spans.length > 0) {
                new_timeline_data.spans = $.grep(_TL_DATA.spans,
                    function (item, index) {
                        return item.id == "";
                    });
            }
        } else {
            var objects = [];
            $("#tblLeftGridElements input:checked:visible").each(
                function () {
                    var ids = $(this).attr("value");
                    if (ids != null) {
                        var id_array = ids.split("#");
                        if (id_array.length > 1) {
                            objects.push(id_array[0]);
                        }
                    }
                })
            var element_checks = [];

            // Loop into types
            for (obj in objects) {
                if (elementsInMemory != null && elementsInMemory.length > 0) {
                    for (var i = 0; i < elementsInMemory.length; i++) {
                        var element = elementsInMemory[i];
                        if (element != null) {
                            var tapeID = element.tapeID;

                            if (objects[obj] == tapeID) {
                                var groupName = element.groupName;
                                var tapeType = element.tapeType;
                                var duration = element.duration;
                                var timestamp = element.timestamp;
                                var segmentID = element.segmentID;
                                var count = element.count;
                                var fileName = element.fileName;
                                var endDate = element.endDate;
                                var filePath = element.filePath;
                                var duration_formatStr = element.duration_formatStr;
                                var fileStatus = element.fileStatus;

                                var tapeType_str = tapeType;
                                if (tapeType == "S") {
                                    tapeType_str = "P";
                                }

                                // Create object
                                var object_group = {};
                                object_group.name = tapeType_str; //
                                object_group.start = timestamp;
                                object_group.end = endDate;
                                object_group.id = tapeID;
                                object_group.role = groupName;
                                object_group.type = tapeType;
                                element_checks.push(object_group);
                            }
                        }
                    } //for
                }
            } //for

            // Append role elements to original elements
            var allTags = [];
            allTags.push.apply(allTags, _TL_DATA.spans);
            allTags.push.apply(allTags, element_checks);
            new_object.spans = allTags;
            new_timeline_data = new_object;
        }
        _TL_DATA = new_timeline_data;
        prepareTimelineReload(new_timeline_data);
    });
}


// If timeline is already drawn, set to divTimelineProgress the main line real width 
function divTimelineProgress_SetWidth() {
    var MAIN_LINE = $("#svg_timeframe > g:first > line:first");
    if (MAIN_LINE != null && MAIN_LINE.length) {
        var x1 = parseInt(MAIN_LINE.attr("x1"), 10);
        var x2 = parseInt(MAIN_LINE.attr("x2"), 10);

        $('#divTimelineProgress').css("width", (x2 - x1 + 4) + "px");
        $("#divTimelineProgress").offset({
            left: $("#svg_timeframe").offset().left + 42 
        })
    }
}

// Event Drag & Drop: Stop Dragging
function handleDragStop(event, ui) {
    var posX = ui.offset.left - $("#svg_timeframe").offset().left;
    var position_date = window.timeframe_live.getTickDate(posX); // Datetime position - Formato: AÑO DIA MES
    if (position_date != null) {
        var position_date_moment = moment(position_date, "YYYY-MM-DD HH:mm:ss");
        currentPointerPositionDate_str = position_date_moment.format('DD-MM-YYYY HH:mm:ss');

        // Update popup dates: FileUpload and CommentUpload
        $("#commentDate").val(currentPointerPositionDate_str);
        $("#divUpload input[id*='uploadDate']").val(currentPointerPositionDate_str);

        if (globalplay_active) {

            /******** Globalplay ********/

            // Set current timer

            var actual_duration = getDuration_onDatetime(position_date_moment)
            GLOBALPLAY_seconds_current = actual_duration;

            // Clear global timer
            $('#divGlobalplay_timer').timer('remove');

            // Set global timer current progress
            $('#divGlobalplay_timer').timer({
                format: '%H:%M:%S',
                seconds: actual_duration
            });

            // Set current timer
            $("#lblGlobalplay_timer_current_longFormat").text(position_date_moment.format('DD-MM-YYYY HH:mm:ss'));

            // Pause global timer 
            $('#divGlobalplay_timer').timer('pause');

            // Set player mask pause
            $("#globalplay_play").removeClass("globalplay_pause"); 
            $("#globalplay_play").addClass("globalplay_play");

            globalplay_pausePlayingElements(false); 

            globalplay_loadElementSeek(actual_duration);

            // DO PLAY *new*
            setTimeout(function () {
                $("#globalplay_play").click();
            }, 200); 

        } 
    }
}

// Event Drag & Drop: While Dragging
function handleDragging(event, ui) {
    var posX = ui.offset.left - $("#svg_timeframe").offset().left;
    var posY = ui.offset.top;
    var posXfinal = posX + 80;
    var posYfinal = posY - 78;
    var pop4_width = parseInt($(".box4.popbox4").css("width"), 10);
    if (posXfinal + pop4_width > $(window).width()) {
        posXfinal = $(window).width() - pop4_width;
    }
    $(".box4.popbox4").show("scale", 300);

    if (!globalplay_active) {

        $(".box4.popbox4").offset({
            left: posXfinal - 11, // 28 Quitar?
            top: posYfinal
        });

    } else {
        $(".box4.popbox4").offset({
            left: posXfinal + 9, // 28 Quitar?
            top: posYfinal
        });
    }

    var date = window.timeframe_live.getTickDate(posX); // Datetime position - Formato: AÑO DIA MES
    if (date != null) {
        var date_str = moment(date, "YYYY-MM-DD HH:mm:ss");
        $("#lblPopbox4").text(date_str.format('DD-MM-YYYY HH:mm:ss'));
    }

    /******** Globalplay ********/

    // Stop timer 
    //globalplay_abort();
    globalplay_playback_active = false;
}


// Load Alert messages default values
function LoadAlertMessagesBackup() {

    hashMessages = {};

    hashMessages["ElementosBorrados"] = "Los elementos se borraron correctamente.";
    hashMessages["SeleccioneElemento"] = "Por favor, seleccione un elemento del folio.";
    hashMessages["ElementoBorrado"] = "Elemento correctamente borrado.";
    hashMessages["UtilizarNavegador1"] = "Por favor, utilice IE o Firefox para continuar con esta función.";
    hashMessages["UtilizarNavegador2"] = "Por favor, utilice IE o Firefox para reproducir este elemento.";
    hashMessages["MaximoElementosDescarga1"] = "Se permite un máximo de";
    hashMessages["MaximoElementosDescarga2"] = "elementos en simultáneo para descargar.";
    hashMessages["SeleccioneArchivo"] = "Por favor, seleccione un archivo.";
    hashMessages["IngreseNumeroCamara"] = "Por favor, ingrese el número de cámara.";
    hashMessages["ComentarioGuardado"] = "Comentario correctamente guardado.";
    hashMessages["InstallWebchimera"] = "Por favor, descargue WebChimera plugin desde: ";
    hashMessages["ConfirmarDesgargaElementos"] = "¿Desea descargar TODOS los elementos seleccionados?";
    hashMessages["ConfirmarBorrarElementos1"] = "¿Desea borrar TODOS los elementos seleccionados?";
    hashMessages["ConfirmarBorrarElementos2"] = "¿Está seguro?";
    hashMessages["SeleccioneFolio"] = "Por favor, ingrese un folio válido.";
    hashMessages["InstallWebchimera_Aux"] = "Por favor, instale el plugin WebChimera para reproducir el elemento. ";
    hashMessages["MaxElementsSimultaneous"] = "Atención, máxima cantidad de elementos en simultáneo alcanzadainstale el plugin WebChimera para reproducir el elemento. ";
    hashMessages["OrekaPlayerError"] = "Ocurrió un error cargando el Player Oreka, por favor, verifique Java y su conexión con el servidor de Oreka.";
    hashMessages["ConfirmarBorrarUnElemento"] = "Está a punto de borrar el elemento, confirme su contraseña para continuar.";
    hashMessages["SeleccioneFolioID"] = "Por favor, seleccione un número de Folio.";
    hashMessages["DatosIncorrectos"] = "Datos incorrectos.";
    
}

function initVariables() {

    TIMELINE_POINTER = $("#sm2-progress-ball_TIMELINE");
    PLAYER_BOX = $("#divPanel_PlayerControl div[id*='playerBox']");

    // Set Username and Date info
    currentDateToday = new Date();
    var dd = currentDateToday.getDate();
    var mm = currentDateToday.getMonth() + 1; //January is 0!
    var yyyy = currentDateToday.getFullYear();

    if (dd < 10) {
        dd = '0' + dd
    }

    if (mm < 10) {
        mm = '0' + mm
    }

    currentDateToday = dd + '/' + mm + '/' + yyyy;

    var text = " " + globalUserName + ", " + currentDateToday;
    $('.usernameInfo').html(text);

    // Load alert message: Get Max Elements download from web.config
    MAX_DOWNLOAD_FILES = 6;
    var _hdnMaxElementsDownload = $("#_hdnMaxElementsDownload");
    if (_hdnMaxElementsDownload != null && _hdnMaxElementsDownload.val() != null && _hdnMaxElementsDownload.val().length > 0) {
        MAX_DOWNLOAD_FILES = parseInt(_hdnMaxElementsDownload.val(), 10);
    }

    // Load Globalplay default duration on elements 
    GLOBALPLAY_DEFAULT_DURATION = 6;
    var _hdnGlobalplay_defaultDuration = $("#_hdnGlobalplay_defaultDuration");
    if (_hdnGlobalplay_defaultDuration != null && _hdnGlobalplay_defaultDuration.val() != null && _hdnGlobalplay_defaultDuration.val().length > 0) {
        GLOBALPLAY_DEFAULT_DURATION = parseInt(_hdnGlobalplay_defaultDuration.val(), 10);
    }

    // Load Globalplay default duration on elements 
    GLOBALPLAY_MAX_COLLISION_ELEMENTS = 8;
    var _hdnGlobalplay_maxCollisionElements = $("#_hdnGlobalplay_maxCollisionElements");
    if (_hdnGlobalplay_maxCollisionElements != null && _hdnGlobalplay_maxCollisionElements.val() != null && _hdnGlobalplay_maxCollisionElements.val().length > 0) {
        GLOBALPLAY_MAX_COLLISION_ELEMENTS = parseInt(_hdnGlobalplay_maxCollisionElements.val(), 10);
    }


}

function loadHiddenFields() {

    // IS INCONCERT - EXTRA ------------

    // WS: /RecordingIntegration/WebServices
    // param 1: id --> segmentID
    // param 1: isExtra --> 0/1

    // Get INCONCERT SERVER from web.config
    WS_InConcert_Server = "http://192.168.10.31";
    var _hdnWS_InConcert_Server = $("#_hdnWS_InConcert_Server");
    if (_hdnWS_InConcert_Server != null && _hdnWS_InConcert_Server.val() != null && _hdnWS_InConcert_Server.val().length > 0) {
        WS_InConcert_Server = "http://" + _hdnWS_InConcert_Server.val();
    }

    // Get INCONCERT WS PORT from web.config
    WS_InConcert_Port = "8081";
    var WS_Port = $("#_hdnWS_InConcert_Port");
    if (WS_Port != null && WS_Port.val() != null && WS_Port.val().length > 0) {
        WS_InConcert_Port = WS_Port.val();
    }

    // Get INCONCERT WS URL from web.config
    WS_InConcert_URL_download = "/RecordingIntegration/WebServices/Download.aspx";
    var WS_URL = $("#_hdnWS_InConcert_URL_download");
    if (WS_URL != null && WS_URL.val() != null && WS_URL.val().length > 0) {
        WS_InConcert_URL_download = WS_URL.val();
    }

    // IS OREKA ------------
    // Get OREKA SERVER from web.config
    WS_Oreka_Server = "http://192.168.10.31";
    var _hdnWS_Oreka_Server = $("#_hdnWS_Oreka_Server");
    if (_hdnWS_Oreka_Server != null && _hdnWS_Oreka_Server.val() != null && _hdnWS_Oreka_Server.val().length > 0) {
        WS_Oreka_Server = "http://" + _hdnWS_Oreka_Server.val();
    }

    // Get OREKA WS PORT from web.config
    WS_Oreka_Port = "8080";
    var _hdnWS_Oreka_Port = $("#_hdnWS_Oreka_Port");
    if (_hdnWS_Oreka_Port != null && _hdnWS_Oreka_Port.val() != null && _hdnWS_Oreka_Port.val().length > 0) {
        WS_Oreka_Port = _hdnWS_Oreka_Port.val();
    }

    // Get OREKA WS URL from web.config
    WS_Oreka_URL = "/icweb/replay";
    var _hdnWS_Oreka_URL = $("#_hdnWS_Oreka_URL");
    if (_hdnWS_Oreka_URL != null && _hdnWS_Oreka_URL.val() != null && _hdnWS_Oreka_URL.val().length > 0) {
        WS_Oreka_URL = _hdnWS_Oreka_URL.val();
    }

    // Get FBS Default screen properties
    FBS_DEFAULT_Width = "557px", FBS_DEFAULT_Height = "390px";
    var vWidth = $("#_hdnFbs_width");
    var vHeight = $("#_hdnFbs_height");
    if (vWidth != null && vWidth.val().length > 0 && vHeight != null && vHeight.val().length > 0) {
        FBS_DEFAULT_Width = vWidth.val();
        FBS_DEFAULT_Height = vHeight.val();
    }

    // Get FBS Fullscreen screen properties
    FBS_FULLSCREEN_Width = "557px", FBS_FULLSCREEN_Height = "390px";
    var vWidth1 = $("#_hdnPlayerFBS_fullscreen_width");
    var vHeight1 = $("#_hdnPlayerFBS_fullscreen_height");
    if (vWidth1 != null && vWidth1.val().length > 0 && vHeight1 != null && vHeight1.val().length > 0) {
        FBS_FULLSCREEN_Width = vWidth1.val();
        FBS_FULLSCREEN_Height = vHeight1.val();
    }

    // Get FBS Popup screen properties
    FBS_POPUP_Width = "1366", FBS_POPUP_Height = "768";
    var vWidth2 = $("#_hdnPlayerFBS_popup_width");
    var vHeight2 = $("#_hdnPlayerFBS_popup_height");
    if (vWidth2 != null && vWidth2.val().length > 0 && vHeight2 != null && vHeight2.val().length > 0) {
        FBS_POPUP_Width = vWidth2.val();
        FBS_POPUP_Height = vHeight2.val();
    }

}



function getFormattedDate(date) {
    var day = date.getDate();
    var month = date.getMonth() + 1;
    var year = date.getFullYear().toString().slice(2);
    return day + '-' + month + '-' + year;
}

//#endregion 

//#region JS Methods 1: openFullscreen | closeFullscreen | openUploadModal | addCommentClick | removeElement | closeModal 

// Change Roles and Types filter checkboxes to checked value 
function checkRolesAndTypesFilters() {
    $("#divTypes input:not(:checked)").click()
    $("#divRoles input:not(:checked)").click()
}


function openFullscreen() {

    if (oldPlayer_activeElement_type != null && oldPlayer_activeElement_type.length > 0) {
        switch (oldPlayer_activeElement_type) {
            case "I": {

                /* ------------------  IMAGE CASE ------------------ */
                $("#imgPlayer").photobox();
                $("#imgPlayer").click();

                // Remove all images but first
                $("#photobox-container img").not(":first").remove();

                break;
            }

            case "S":
            case "V": {

                if (oldPlayer_activeElement_extension != null && oldPlayer_activeElement_extension.length > 0) {
                    switch (oldPlayer_activeElement_extension) {

                        // HTML5 support:
                        case "mp4":
                        case "webm":
                        case "ogg": {

                            openFullscreen_video(true, "html_video");

                            break;
                        }

                            // Webchimera Plugin Player or else:
                        case "avi":
                        case "crypt":
                        case "bin":
                        default: {

                            if (getIsIE()) {
                                openFullscreen_video(true, "video_object1");
                            } else {
                                openFullscreen_video(false, null);
                            }

                            break;
                        }
                    }
                }

                break;
            }
        }
    }

}

function openFullscreen_video(isHTML5, videoID) {

    var light = $("#light");
    var fade = $("#fade");
    var divPlayer_VIDEO = $("#divPlayer_VIDEO");
    var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");

    if (light != null && light.length && fade != null && fade.length && divPlayer_VIDEO != null && divPlayer_VIDEO.length && divControlsMask_VIDEO != null && divControlsMask_VIDEO.length) {

        var width = MONITOR_WIDTH - (MONITOR_WIDTH * 40 / 100);
        var height = MONITOR_HEIGHT - (MONITOR_HEIGHT * 40 / 100);

        if (isHTML5) {

            var video_player = null;
            if (videoID != null) {
                video_player = $("#" + videoID);
            }

            if (videoID != null) {
                video_player.css("width", width);
                video_player.css("height", height);
            }

        } else {
            document.getElementById("webchimera1").width = width;
            document.getElementById("webchimera1").height = height;

            var player_top = parseInt(divPlayer_VIDEO.css('top'), 10);
            divPlayer_VIDEO.css('top', (player_top + 6) + "px");
        }

        light.css('width', '70%');
        light.css('height', '80%');

        ///
        light.css('position', 'fixed');
        light.css('top', '50%');
        light.css('left', '50%');

        var top1 = light.css('top');
        var top2 = parseInt(top1, 10);
        light.css('top', top2 + 'px');

        light.css('margin', '0 auto');
        light.css('left', '0');
        light.css('right', '0');

        // -------------------------------------------------------------

        // Move player and banner to modal box
        divPlayer_VIDEO.prependTo($("#light_row"));
        divControlsMask_VIDEO.prependTo($("#light_row"));

        // Styles
        divControlsMask_VIDEO.css('height', '71px');

        // Show effect
        // Source: https://jqueryui.com/show/
        fade.show();
        light.show("blind", 500);

    }

}

function closeFullscreen() {
    var light = $("#light");
    var fade = $("#fade");
    var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");
    var divPlayer_VIDEO = $("#divPlayer_VIDEO");

    if (oldPlayer_activeElement_type != null && oldPlayer_activeElement_type.length > 0) {
        switch (oldPlayer_activeElement_type) {
            case "I": {

                if (light != null && light.length && fade != null && fade.length && PLAYER_BOX != null && PLAYER_BOX.length && divControlsMask_VIDEO != null && divControlsMask_VIDEO.length && divPlayer_VIDEO != null && divPlayer_VIDEO.length) {

                    // Move player and banner to div container
                    divControlsMask_VIDEO.appendTo(PLAYER_BOX);
                    divPlayer_VIDEO.appendTo(PLAYER_BOX);

                    // styles
                    light.css('display', 'none');
                    fade.css('display', 'none');
                    divControlsMask_VIDEO.css('height', '54px');
                }
                break;
            }

            case "S":
            case "V": {

                if (oldPlayer_activeElement_extension != null && oldPlayer_activeElement_extension.length > 0) {
                    switch (oldPlayer_activeElement_extension) {

                        // HTML5 support:
                        case "mp4":
                        case "webm":
                        case "ogg": {

                            closeFullscreen_video(true, divControlsMask_VIDEO, divPlayer_VIDEO, light, fade, "html_video");

                            break;
                        }

                        // Webchimera Plugin Player or else:
                        case "avi":
                        case "crypt":
                        case "bin":
                        default: {

                            if (getIsIE()) {
                                closeFullscreen_video(true, divControlsMask_VIDEO, divPlayer_VIDEO, light, fade, "video_object1");
                            } else {
                                closeFullscreen_video(false, divControlsMask_VIDEO, divPlayer_VIDEO, light, fade, null);
                            }

                            break;
                        }
                    }
                }

                break;
            }

        }
    }
}

function closeFullscreen_video(isHTML5, divControlsMask_VIDEO, divPlayer_VIDEO, light, fade, videoID) {

    // Move player and banner to div container
    divControlsMask_VIDEO.appendTo(PLAYER_BOX);
    divPlayer_VIDEO.appendTo(PLAYER_BOX);

    // styles
    light.css('display', 'none');
    fade.css('display', 'none');
    divControlsMask_VIDEO.css('height', '54px');


    // -------------------------------------------------------------

    var manual_offset = 52;
    var extra = 2;
    var playerBox_h = parseInt(PLAYER_BOX.css("height"), 10);
    var height_final = playerBox_h - manual_offset - extra;

    // divPlayer_VIDEO size
    divPlayer_VIDEO.css("height", height_final + "px");
    divPlayer_VIDEO.offset({ top: PLAYER_BOX.offset().top + manual_offset });

    // Video player size
    var divPlayer_VIDEO_w = parseInt(divPlayer_VIDEO.css("width"), 10);
    var divPlayer_VIDEO_h = parseInt(divPlayer_VIDEO.css("height"), 10);

    if (isHTML5) {

        var video_player = null;
        if (videoID != null) {
            video_player = $("#" + videoID);
        }

        if (videoID != null) {
            video_player.css("width", divPlayer_VIDEO_w);
            video_player.css("height", divPlayer_VIDEO_h);
        }

    } else {
        document.getElementById("webchimera1").width = divPlayer_VIDEO_w;
        document.getElementById("webchimera1").height = divPlayer_VIDEO_h;
    }
}

function addCommentClick() {

    // Check if folio is selected
    var _hdnFolioID = $("input[id*='_hdnFolioID']");
    if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {

        if (!$('#btnAddComment').hasClass("opened")) {
            var posXoff = $("#btnAddComment").offset().left;
            var posYoff = $("#btnAddComment").offset().top + 60;
            $('.popbox').popbox();
            $("#txbComment").val("");
            $("#txbComment").focus();

            // Hide other popups
            $(".box2.popbox2").hide();
            var date_str = moment(currentPointerPositionDate_str, "DD-MM-YYYY HH:mm:ss");
            $("#commentDate").val(date_str.format('DD-MM-YYYY HH:mm:ss'));
            $(".jslider-pointer").css("left", "0%");

            // Popup styles
            $(".box.popbox").show("highlight", 700);

            var pop_w = parseInt($(".box.popbox").css("width"), 10);
            var arrow_w = parseInt($(".box.popbox .arrow").css("width"), 10);
            var btn_w = parseInt($("#btnAddComment").css("width"), 10);

            //$(".box.popbox").offset({ left: posXoff });
            $(".box.popbox").offset({ left: posXoff - pop_w + (btn_w / 2) + (arrow_w / 2) });
            $(".box.popbox .arrow").css("left", (pop_w - arrow_w - 3) + "px");
            $(".box.popbox .arrow-border").css("left", (pop_w - arrow_w - 3) + "px");

            $(".box.popbox").offset({ top: posYoff });
            $('#btnAddComment').addClass("opened");
        } else {
            $(".box.popbox").hide(200);
            $('#btnAddComment').removeClass("opened");
        }

    } else {
        $("#dialog p").text(hashMessages["SeleccioneFolio"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
    }
}

function removeElement() {

    $("#dialog p").text(hashMessages["SeleccioneElemento"]);
    $("#dialog").dialog({
        buttons: {
            "Confirmar": function () {
                $(this).dialog("close");
            }
        }
    });
}

function closeModal() {
    $.modal.close();
    return false;
}
//#endregion 
//#region JS Methods 2: prepareFilterTimelineElements | extend | changeTab1 | changeTab2
/* ************* Method: Click on filters Roles or Types ************* */

function prepareFilterTimelineElements(caller, filterType, filterValue) {
    if (caller != null && filterType != null && filterValue) {

        /* ************* Folio element results ************* */
        if (elementsInMemory != null) {
            var checked = $(caller).prop('checked');
            var objects_group_role = [];
            var objects_group_type = [];
            if (elementsInMemory.length > 0) {
                for (var i = 0; i < elementsInMemory.length; i++) {
                    var element = elementsInMemory[i];
                    if (element != null) {
                        var tapeID = element.tapeID;
                        var groupName = element.groupName;
                        var tapeType = element.tapeType;
                        var duration = element.duration;
                        var timestamp = element.timestamp;
                        var segmentID = element.segmentID;
                        var count = element.count;
                        var fileName = element.fileName;
                        var endDate = element.endDate;
                        var filePath = element.filePath;
                        var duration_formatStr = element.duration_formatStr;
                        var fileStatus = element.fileStatus;

                        var tapeType_str = tapeType;
                        if (tapeType == "S") {
                            tapeType_str = "P";
                        }
                        // Create object
                        var object_group = {};
                        object_group.name = tapeType_str; //
                        object_group.start = timestamp;
                        object_group.end = endDate;
                        object_group.id = tapeID;
                        object_group.role = groupName;
                        object_group.type = tapeType;

                        /* ************* Hide or show each element in the grid panel ************* */
                        if (filterType === "role") {
                            // Roles
                            if (filterValue === groupName || groupName === "") {
                                objects_group_role.push(object_group);
                            }
                            if (checked) {
                                if (filterValue === groupName || groupName === "") {
                                    $("#tblLeftGridElements #tape_" + tapeID).show();
                                }
                            } else {
                                if (filterValue === groupName) {
                                    $("#tblLeftGridElements #tape_" + tapeID).hide(); // hide row
                                }
                            }
                        } else if (filterType === "type") {
                            // Types
                            if (filterValue === tapeType) {
                                objects_group_type.push(object_group);
                            }
                            if (checked) {
                                if (filterValue === tapeType) {
                                    $("#tblLeftGridElements #tape_" + tapeID).show();
                                }
                            } else {
                                if (filterValue === tapeType) {
                                    $("#tblLeftGridElements #tape_" + tapeID).hide(); // hide row
                                }
                            }
                        }
                    }
                } //for
            }

            /* ************* Re-load timeline logic ************* */

            $("#timeframe").empty(); // Clean div content
            var new_timeline_data = jQuery.extend(true, {}, _TL_DATA); // Clone the object, do not reference it
            var new_object = {};
            new_object.name = "Elements";
            new_object.color = "#000000";
            if (filterType === "role") {
                if (checked) {

                    // Append role elements to original elements
                    var allTags = [];
                    allTags.push.apply(allTags, _TL_DATA.spans);
                    allTags.push.apply(allTags, objects_group_role);
                    new_object.spans = allTags;
                    new_timeline_data = new_object;
                } else {

                    // Grep: selecciona elementos que coincidan con la condición
                    if (new_timeline_data.spans != null &&
                        new_timeline_data.spans.length > 0) {
                        new_timeline_data.spans = $.grep(_TL_DATA.spans,
                            function (item, index) {
                                return item.role != filterValue;
                            });
                    }
                }
            } else if (filterType === "type") {
                if (checked) {

                    // Append type elements to original elements
                    var allTags = [];
                    allTags.push.apply(allTags, _TL_DATA.spans);
                    allTags.push.apply(allTags, objects_group_type);
                    new_object.spans = allTags;
                    new_timeline_data = new_object;
                } else {
                    if (new_timeline_data.spans != null &&
                        new_timeline_data.spans.length > 0) {
                        new_timeline_data.spans = $.grep(_TL_DATA.spans,
                            function (item, index) {
                                return item.type != filterValue;
                            });
                    }
                }
            }
            _TL_DATA = new_timeline_data;
            prepareTimelineReload(_TL_DATA);

            /* ************* Labels and Messages ************* */
            $("#divPanel_Busqueda span[id*='lblResultsCount']").text($("#tblLeftGridElements tr[id*='tape_']:visible").length.toString());
        }
    }
}

function extend(obj, src) {
    for (var key in src) {
        if (src.hasOwnProperty(key)) obj[key] = src[key];
    }
    return obj;
}

function changeTab1(caller) {
    $("#nav_tabs1").find('li').removeClass("active");
    $(caller).addClass("active");
    var type = $(caller).attr("id");
    if (type != null) {

        //$("#divFolios").hide();
        $("#divRoles").hide();
        $("#divTypes").hide();

        if (type === "liFolio") {

            //$("#divFolios").show();
            $("#divElementos").css("max-height", "437px");
        } else if (type === "liRoles") {
            $("#divRoles").show();
            $("#divElementos").css("max-height", "414px");
        } else if (type === "liTipos") {
            $("#divTypes").show();
            $("#divElementos").css("max-height", "335px");
        }
    }
}

function changeTab2(caller) {
    $("#nav_popbox2").find('li').removeClass("active");
    $(caller).addClass("active");
    var type = $(caller).attr("id");
    if (type != null) {
        $("#divUpload").hide();
        $("#divCamaras").hide();
        if (type === "liUpload") {
            $("#divUpload").show();

            // Clear tab values
            $("#divUpload input[id*='MyFileUpload']").val("");
        } else if (type === "liCamera") {
            $("#divCamaras").show();

            // Clear tab values
            $("#divCamaras input[id*='txbInputCameraNumber']").val("");
        }
    }
}

function setCurrentPointerPositionDate(event) {
    var target = event.target;
    var x = getClickPosition1(event); // Click position
    var date = window.timeframe_live.getTickDate(x); // Datetime position
    if (date != null) {
        var date_str = moment(date, "YYYY-MM-DD HH:mm:ss");
        currentPointerPositionDate_str = date_str.format('DD-MM-YYYY HH:mm:ss');
    }
}

function events_line_click(event) {
    var MAIN_LINE = $("#svg_timeframe > g:first > line:first");
    if (MAIN_LINE != null && MAIN_LINE.length && TIMELINE_POINTER != null && TIMELINE_POINTER.length) {

        // Show timeline pointer
        TIMELINE_POINTER.show();

        // Set current pointer date, to the add-comment & upload-file functions
        setCurrentPointerPositionDate(event);

        // TODO: Check in Chrome 

        // Locate pointer in new position
        var parentPosition = getPosition2(event.currentTarget); //2
        var xPosition = event.clientX - parentPosition.x;
        var yPosition = event.clientY - parentPosition.y;

        var pointer_width = parseInt(TIMELINE_POINTER.css("width"), 10);

        TIMELINE_POINTER.offset({ left: xPosition - (pointer_width / 2) });
    }
}

function getClickPosition1(e) {
    var parentPosition = getPosition1(e.currentTarget);
    var xPosition = e.clientX - parentPosition.x;
    var yPosition = e.clientY - parentPosition.y;
    return xPosition;
}

function getPosition1(element) {
    var xPosition = 0;
    var yPosition = 0;
    while (element) {

        // NOTE: Chrome way
        //xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
        //yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
        //element = element.offsetParent;

        // NOTE: Firefox / Chrome way 1
        xPosition += (XY(element).x - element.scrollLeft + element.clientLeft);
        yPosition += (XY(element).y - element.scrollTop + element.clientTop);
        element = element.offsetParent;
    }
    return {
        x: xPosition,
        y: yPosition
    };
}
//#endregion 

//#region JS Methods 3: timeframe_prepare | timeframe_draw | fire_event | locateEveryElementByType | onTick | clearAllStyleSettings | paintSelectionClick | getOffset | relMouseCoords | 

function clear_timeline() {

    // Clean div content
    $("#timeframe").empty();
    $("#timeframe").hide();
    $("#playerContainer").addClass("disabled");

    TIMELINE_POINTER.hide();

    // Clear previous Folios ID
    $("#divFolioSelection_fileUpload").empty();
    $("#divFolioSelection_addComment").empty();
}

function pre_timeframe_prepare() {
    var hdnJSonList = $("input[id*='_hdnJSonList']").val();
    var hdnJSonStart = $("input[id*='_hdnJSonStart']").val();
    var hdnJSonEnd = $("input[id*='_hdnJSonEnd']").val();

    if (hdnJSonList != null && hdnJSonList.length && hdnJSonStart != null && hdnJSonStart.length && hdnJSonEnd != null && hdnJSonEnd.length) {
        timeframe_prepare(JSON.parse(hdnJSonList), hdnJSonStart, hdnJSonEnd);
    }

    // Show timeline pointer
    TIMELINE_POINTER.show();

    // Re Load all grid button events, because Ajax call removes them

    /**** Event: OnClick check all elements at left grid ****/
    loadGridCheckboxAll_event();

    /**** Event: OnClick Load on click event remove button ****/
    loadClickRemoveElementSelected_event();

    /**** Event: OnClick Load on click event fullscreen button for Screen recording elements ****/
    loadClickFullscreen_event();

    /**** Load Globalplay settings ****/
    loadGlobalplay_settings();

    /**** Load Folios ID to UploadFile and AddComment ****/
    loadFoliosID();

    /**** Slider control: comment duration ****/
    $("#sliderSingle1").slider({
        from: 1,
        to: GLOBALPLAY_seconds_total, // 3600 seg
        step: 1,
        round: 1,
        format: {
            format: '##',
            locale: 'de'
        },
        dimension: '&nbsp;',
        skin: "round"
    });
}

function timeframe_prepare(timeline_data, start, end) {
    getElementsInMemory();

    _TL_DATA = timeline_data;
    _TL_STARTDATE = start;
    _TL_ENDDATE = end;

    // **** DRAW TIMELINE ****
    timeframe_draw(timeline_data, start, end);

    // If timeline is already drawn, set to divTimelineProgress the main line real width 
    divTimelineProgress_SetWidth();

    // If there are elements loaded, show timeline pointer
    var first_tapeID = 0;
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        first_tapeID = elementsInMemory[0].tapeID;
        var first_tapeID_int = parseInt(first_tapeID, 10);

        if (first_tapeID_int > 0) {
            TIMELINE_POINTER.show();
            timeline_pointer_setLocation(first_tapeID_int);
        }
    }

}
/* ************* Method: draw Timeline - CSS Custom Styles ************* */

function timeframe_draw(timeline_data, start, end) {
    if (timeline_data != null && start != null && start.length > 0 && end != null && end.length > 0) {

        // Clean div content
        $("#timeframe").empty();
        $("#timeframe").hide();

        // Create timeframe object
        var t = Timeframe("#timeframe").addCategory(timeline_data).start(start).end(end).draw();

        /* ************* Elements style settings ************* */

        var rectColor_values = {};
        var rectTitle_values = {};
        var MAIN_LINE_height = 105; // 90
        var MAIN_LINE_top = 78; // 60

        rectColor_values = {
            grabacion: "blue",
            video: "purple",
            audio: "red",
            documento: "green",
            comentario: "orange",
            imagen: "Violet"
        }

        rectTitle_values = {
            grabacion: "Grabación",
            video: "Video",
            audio: "Audio",
            documento: "Documento",
            comentario: "Comentario",
            imagen: "Imagen"
        }

        /* ************* Main line style settings ************* */

        /* **** MAIN LINE **** */

        var MAIN_LINE = $("#svg_timeframe > g:first > line:first");
        if (MAIN_LINE != null && MAIN_LINE.length) {
            MAIN_LINE.attr("stroke-opacity", 0.8);
            MAIN_LINE.attr("stroke", "SlateGray ");
            MAIN_LINE.attr("y1", MAIN_LINE_top);
            MAIN_LINE.attr("y2", MAIN_LINE_top);
            MAIN_LINE.attr("stroke-width", MAIN_LINE_height);

        }

        /* **** EVENTS LINE **** */
        var EVENTS_LINE = $("#svg_timeframe > g:first > line:nth(1)");
        if (EVENTS_LINE != null && EVENTS_LINE.length) {
            EVENTS_LINE.css('cursor', 'crosshair');
        }
        var svg = $("#svg_timeframe");
        if (svg != null && svg.length) {
            svg.attr("height", SVG_Height);
        }
        // Click over Events line
        EVENTS_LINE.on("click", events_line_click);

        /* ************* Style settings ************* */

        if (elementsInMemory.length > 0) {

            // Enable Globalplay
            $("#playerContainer").removeClass("disabled");


            // Loop into elements in memory
            for (var i = 0; i < elementsInMemory.length; i++) {
                var element = elementsInMemory[i];
                if (element != null) {
                    var tapeID = element.tapeID;
                    var groupName = element.groupName;
                    var tapeType = element.tapeType;
                    var duration = element.duration;
                    var timestamp = element.timestamp;
                    var segmentID = element.segmentID;
                    var count = element.count;
                    var fileName = element.fileName;
                    var endDate = element.endDate;
                    var filePath = element.filePath;
                    var fileStatus = element.fileStatus;
                    var duration_formatStr = element.duration_formatStr;

                    /* ************* Objects: timeline features and styles by element types ************* */

                    // IsExtra = If filePath is NOT empty, then is extra from incextras table
                    var isExtra = filePath.length == 0 ? false : true;
                    var color_str = rectColor_values.grabacion;
                    var tapeType_longStr = rectTitle_values.grabacion;
                    var line_opacity = 0.7;
                    var x_extra = 5;
                    var ELEMENT = $("#tlTape_" + tapeID);
                    var ELEMENT_rect = $("#tlTape_" + tapeID + " > rect");
                    var ELEMENT_text = $("#tlTape_" + tapeID + " > text");

                    // Border not rounded
                    if (ELEMENT_rect != null && ELEMENT_rect.length) {
                        ELEMENT_rect.attr("rx", 0);
                        ELEMENT_rect.attr("ry", 0);
                    }
                    var toolTip_title = "";
                    switch (tapeType) {
                        case "S":
                            {
                                tapeType_longStr = rectTitle_values.grabacion;
                                color_str = rectColor_values.grabacion;
                                toolTip_title = "Elemento #" + count + " (Grabación de pantalla)";

                                // Border rounded
                                if (ELEMENT_rect != null && ELEMENT_rect.length) {
                                    ELEMENT_rect.attr("rx", 4);
                                    ELEMENT_rect.attr("ry", 4);
                                }
                                break;
                            }
                        case "V":
                            {
                                tapeType_longStr = rectTitle_values.video;
                                toolTip_title = "Elemento #" + count + " (" + tapeType_longStr + ")";
                                color_str = rectColor_values.video;

                                // Border rounded
                                if (ELEMENT_rect != null && ELEMENT_rect.length) {
                                    ELEMENT_rect.attr("rx", 4);
                                    ELEMENT_rect.attr("ry", 4);
                                }
                                break;
                            }
                        case "A":
                            {
                                tapeType_longStr = rectTitle_values.audio;
                                toolTip_title = "Elemento #" + count + " (" + tapeType_longStr + ")";
                                color_str = rectColor_values.audio;

                                // Border rounded
                                if (ELEMENT_rect != null && ELEMENT_rect.length) {
                                    ELEMENT_rect.attr("rx", 4);
                                    ELEMENT_rect.attr("ry", 4);
                                }
                                break;
                            }
                        case "D":
                            {
                                tapeType_longStr = rectTitle_values.documento;
                                toolTip_title = "Elemento #" + count + " (" + tapeType_longStr + ")";
                                color_str = rectColor_values.documento;
                                line_opacity = 1;
                                break;
                            }
                        case "C":
                            {
                                tapeType_longStr = rectTitle_values.comentario;
                                color_str = rectColor_values.comentario;

                                // Special styles
                                ELEMENT_rect.attr("y", Math.floor(ELEMENT_rect.attr("y")) + MAIN_LINE_top - 85);
                                ELEMENT_rect.attr("height", MAIN_LINE_height - 5);
                                var new_y = parseInt(ELEMENT_rect.attr("y"), 10) + parseInt(ELEMENT_rect.attr("height"), 10) + 17;
                                ELEMENT_text.attr("y", new_y);
                                toolTip_title = "Elemento #" + count + ": " + fileName + " (Comentario)";
                                break;
                            }
                        case "I":
                            {
                                tapeType_longStr = rectTitle_values.imagen;
                                toolTip_title = "Elemento #" + count + " (" + tapeType_longStr + ")";
                                color_str = rectColor_values.imagen;
                                line_opacity = 1;
                                break;
                            }
                    }
                    if (ELEMENT != null && ELEMENT.length) {

                        // Set special tooltip
                        ELEMENT.qtip({
                            position: {
                                corner: {
                                    target: 'topRight',
                                    tooltip: 'bottomLeft'
                                }
                            },
                            style: {
                                name: 'cream',
                                padding: '7px 13px',
                                width: {
                                    max: 210,
                                    min: 0
                                },
                                tip: true
                            }
                        });
                        if (fileName.length > 0) {
                            ELEMENT.attr("title", toolTip_title);
                        }
                    }
                    if (ELEMENT != null && ELEMENT.length && ELEMENT_rect != null && ELEMENT_rect.length) {

                        // Set element type to element
                        ELEMENT.attr("type_name", tapeType);

                        // Set default cursor
                        ELEMENT.css('cursor', 'default');

                        // Hide Element letters
                        ELEMENT_text.css('display', 'none');

                        // Elements no comments - comment exception
                        if (tapeType != "C") {

                            // Set cursor
                            ELEMENT_rect.css('cursor', 'pointer');
                            ELEMENT_rect.css('z-index', 10);

                            ELEMENT.css('z-index', 10);

                            // Element click bottom
                            // Carga los parámetros con el valor actual de sus parámetros para que se envíen dinámicamente con el evento click
                            ELEMENT_rect.on("click", {
                                _tapeID: tapeID,
                                _count: count,
                                _duration: duration,
                                _timestamp: timestamp,
                                _tapeType_longStr: tapeType_longStr,
                                _segmentID: segmentID,
                                _isExtra: isExtra.toString().toLowerCase(),
                                _fileName: fileName,
                                _filePath: filePath,
                                _duration_formatStr: duration_formatStr,
                                _tapeType: tapeType,
                                _fileStatus: fileStatus
                            }, fire_event);

                        } else {

                            // Is Comment type Element
                            ELEMENT.css('z-index', -10); //50
                            ELEMENT_rect.css('z-index', -10); //50

                            // new
                            line_opacity = 0.6;
                        }
                        // Get Tape text, set bold
                        if (ELEMENT_text != null && ELEMENT_text.length) {
                            var x = Math.floor(ELEMENT_text.attr("x")) + x_extra;
                            ELEMENT_text.attr("x", x);
                            ELEMENT_text.css('z-index', 99);
                            ELEMENT_text.attr("font-weight", "Bold");
                        }
                    }

                    /* **** ELEMENTS Styles **** */

                    if (ELEMENT_rect != null && ELEMENT_rect.length) {
                        ELEMENT_rect.attr("fill", color_str);
                        ELEMENT_rect.attr("fill-opacity", line_opacity);

                        // Sacar?
                        // Si el elemento es demasiado corto (pintado), fija un largo mínimo en px
                        // Si hay un sólo elemento, deja que se pinte todo el timeline con el, aunque no tenga duración
                        var elements_selected_count = $('tr:visible td input:checked').length;
                        if (elements_selected_count != 1) {
                            var w1 = ELEMENT_rect.attr("width");
                            if (parseInt(w1, 10) <= 1) {
                                ELEMENT_rect.attr("width", "6");
                            }
                        } else {
                            if (duration == 0) {
                                var x1 = parseInt(MAIN_LINE.attr("x1"), 10);
                                var x2 = parseInt(MAIN_LINE.attr("x2"), 10);
                                ELEMENT_rect.attr("width", x2 - x1);
                            }
                        }
                    }
                }
            } // for
        }

        // Visual effect
        $("#timeframe").show("blind", 50);
        locateEveryElementByType();
    }
}

// Send element details
function fire_event(event) {
    $("#tblLeftGridElements button[name='btnTimelineElement']").removeClass("active");
    clickTimelineElement1(event.data._tapeID, event.data._count, event.data._duration, event.data._timestamp, event.data._tapeType_longStr,
        event.data._segmentID, event.data._isExtra, event.data._fileName, event.data._filePath, event.data._duration_formatStr, event,
        event.data._tapeType, event.data._fileStatus);
}

function clicked(evt) {
    // Source: http://jsfiddle.net/fLo4uatw/
}

// Locates all elements in timeline
function locateEveryElementByType() {
    var objects = [];
    $("#divTypes input:checked").each(function () {
        if ($(this).attr("type_name") != "C") {
            objects.push($(this).attr("type_name"));
        }
    })
    var basic_height = 0;
    var extra_top = 30;

    // Element distinct types 
    switch (objects.length) {
        case 1:
            {
                basic_height = 50;
                extra_top = 30;
                break;
            }
        case 2:
            {
                basic_height = 40;
                extra_top = 50;
                break;
            }
        case 3:
            {
                basic_height = 30;
                extra_top = 30;
                break;
            }
        case 4:
            {
                basic_height = 25;
                extra_top = 25;
                break;
            }
        case 5:
            {
                basic_height = 17;
                extra_top = 20;
                break;
            }
        case 6:
            {
                basic_height = 10;
                extra_top = 30;
                break;
            }
    }



    // Type letter location
    var border_start = $("#timeframe line[name='timeframe_start']");
    var x_extra = parseInt(border_start.attr('x1'), 10) - 12;
    var initial_top = 31; //42

    // Loop into types
    for (obj in objects) {
        var y_extra = initial_top + 20;

        // Left vertical element type letter
        if (border_start != null && border_start.length && border_start !=
            null && border_start.length) {
            var letter = objects[obj];
            letter = letter === "S" ? "P" : letter;
            var text = makeSVG('text', {
                x: x_extra,
                y: y_extra,
                r: 40,
                fill: 'black',
                'font-size': 19,
                'text-anchor': 'middle',
                'font-weight': 'Bold'
            }, letter);
            document.getElementById('svg_timeframe').appendChild(text);
        }

        var type = objects[obj];

        // rect
        $("#timeframe g[type_name='" + type + "'] > rect").attr("y", initial_top);
        $("#timeframe g[type_name='" + type + "'] > rect").attr("height", basic_height);

        // text
        $("#timeframe g[type_name='" + type + "'] > text").attr("y", initial_top - 7);
        initial_top += extra_top;
    }
}

function makeSVG(tag, attrs, value) {
    var el = document.createElementNS('http://www.w3.org/2000/svg', tag);
    for (var k in attrs) {
        el.setAttribute(k, attrs[k]);
    }
    el.textContent = value;
    return el;
}

function onTick(value) {
    var text = "Elemento #" + value;
    //$('#lblElementName').text("Elemento: # " + text);
}

function clearAllStyleSettings(type_longStr) {
    var color_str = "blue";
    switch (type_longStr) {
        case "Grabación":
            {
                color_str = "blue";
                break;
            }
        case "Video":
            {
                color_str = "purple";
                break;
            }
        case "Audio":
            {
                color_str = "red";
                break;
            }
        case "Documento":
            {
                color_str = "green";
                break;
            }
        case "Comentario":
            {
                color_str = "orange";
                break;
            }
        case "Imagen":
            {
                color_str = "Violet";
                break;
            }
    }
    /******** Paint timeline elements ********/
    $("#tblLeftGridElements button[name='btnTimelineElement']").css("background-color", color_str);
    $("#svg_timeframe g[id^='tlTape_']").attr("fill", color_str);
}

function paintSelectionClick(tapeID, timestamp) {

    /******** Clear other element styles ********/

    // Left panel
    $("#tblLeftGridElements button[name='btnTimelineElement']").removeClass("active");
    $("#tblLeftGridElements tr[id*='tape_'] > td > h5").attr("style", "color:black;");
    $("#tblLeftGridElements tr[id*='tape_']").not("[name='Extra']").css("background-color", "inherit"); // white
    $("#tblLeftGridElements tr[id*='tape_'][name='Extra']").css("background-color", "rgb(187, 226, 217)"); // white

    // Bottom
    var vAllBottom_texts = $("g[id*='tlTape_'] > text");
    var vAllBottom_rects = $("g[id*='tlTape_'] > rect");
    if (vAllBottom_texts != null && vAllBottom_texts.length &&
        vAllBottom_rects != null && vAllBottom_rects.length) {
        vAllBottom_texts.attr("fill", "black");
        vAllBottom_rects.attr("stroke", "none");
        vAllBottom_rects.attr("stroke-width", 0);
        vAllBottom_rects.attr("stroke-opacity", 0);
    }
    /******** Set new styles ********/

    // Left panel
    $("#tblLeftGridElements #tape_" + tapeID + " > td > h5").attr("style", "color:DodgerBlue");
    $("#tblLeftGridElements #tape_" + tapeID).css("background-color", "lightgray");


    // Bottom
    var vBottom_text = $("#tlTape_" + tapeID + " > text");
    var vBottom_rect = $("#tlTape_" + tapeID + " > rect");
    if (vBottom_text != null && vBottom_text.length && vBottom_rect != null && vBottom_rect.length) {
        vBottom_text.attr("fill", "DodgerBlue ");
        vBottom_rect.attr("stroke", "DodgerBlue ");
        vBottom_rect.attr("stroke-width", 4);
        vBottom_rect.attr("stroke-opacity", 0.9);
    }

}

function getOffset(evt) {
    var el = evt.target,
        x = 0,
        y = 0;
    while (el && !isNaN(el.offsetLeft) && !isNaN(el.offsetTop)) {
        x += el.offsetLeft - el.scrollLeft;
        y += el.offsetTop - el.scrollTop;
        el = el.offsetParent;
    }
    x = evt.clientX - x;
    y = evt.clientY - y;
    return {
        x: x,
        y: y
    };
}

function relMouseCoords(event) {
    var totalOffsetX = 0;
    var totalOffsetY = 0;
    var canvasX = 0;
    var canvasY = 0;
    var currentElement = this;
    do {
        totalOffsetX += currentElement.offsetLeft - currentElement.scrollLeft;
        totalOffsetY += currentElement.offsetTop - currentElement.scrollTop;
    }
    while (currentElement = currentElement.offsetParent)
    canvasX = event.pageX - totalOffsetX;
    canvasY = event.pageY - totalOffsetY;
    return {
        x: canvasX,
        y: canvasY
    }
}
//#endregion 

//#region JS Methods 4: setImgPointerLocation | getObjects | loadElementPlayer 

/******** Set location of Pointer over the timeline element initial position ********/

function timeline_pointer_setLocation(tapeID) {
    var timeline = $(".background");
    var sm2_inline_element = $("#sm2-inline-element");
    var sm2_progress_bd = $("#sm2-progress-bd");
    var sm2_progress = $("#sm2-progress");
    var sm2_progress_track = $("#sm2-progress-track");
    var divTimelineProgress = $("#divTimelineProgress");

    if (TIMELINE_POINTER != null && sm2_inline_element != null && sm2_inline_element.length &&
        sm2_progress_bd != null && sm2_progress_bd.length && sm2_progress != null && sm2_progress.length &&
        sm2_progress_track != null && sm2_progress_track.length && timeline != null) {

        TIMELINE_POINTER.show();

        // Check if if exists at least one element
        if (tapeID > 0) {
            var vElement = $("#tlTape_" + tapeID);
            var vElementRect = $("#tlTape_" + tapeID + " > rect");

            // Check if timeline is already drawn
            if (vElement != null && vElement.length && vElementRect != null && vElementRect.length) {

                // Set progress bar width
                var _width_int = parseInt(vElementRect.attr('width'), 10);
                var _width_percentage = (5 / 100) * _width_int;
                var _width = _width_int + _width_percentage + "px";

                sm2_progress_bd.css("padding", "0px");

                sm2_progress.css('height', 15);

                sm2_inline_element.css('width', _width);

                sm2_inline_element.offset({ left: divTimelineProgress.offset().left });                

                sm2_progress_bd.css('width', _width);

                sm2_progress_bd.css('left', _width);

                sm2_progress_track.css('height', 15);

                sm2_inline_element.offset({ top: $("#divTimelineProgress").offset().top })

            } else {
                // TODO: Timeline is not drawn yet
            }
        } else {
            // It does not exists elements

            // Set progress bar width
            var _width_int = parseInt(timeline.attr('width'), 10);
            var _width_percentage = (5 / 100) * _width_int;
            var _width = _width_int + _width_percentage + "px";

            sm2_progress.css('height', 15);
            sm2_inline_element.css('width', _width);
            sm2_inline_element.css('left', timeline.offset().left + 3);
            sm2_progress_bd.css('width', _width);
            sm2_progress_track.css('height', 15);

            // Pointer left position
            TIMELINE_POINTER.offset({ left: timeline.offset().left });
            sm2_inline_element.offset({ top: timeline.offset().top + 15 }); // + 25
        }
    }
}

function getObjects(obj, key, val) {
    var objects = [];
    for (var i in obj) {
        if (!obj.hasOwnProperty(i)) continue;
        if (typeof obj[i] == 'object') {
            objects = objects.concat(getObjects(obj[i], key, val));
        } else if (i == key && obj[key] == val) {
            objects.push(obj);
        }
    }
    return objects;
}

function downloadElementClick(event) {
    var filePath = event.data._filePath;
    var fileName = event.data._fileName;
    if (filePath != null && fileName != null) {
        window.location.href = "Extras/DownloadFile.ashx?filePath=" +
            filePath + "&fileName=" + fileName;
    }
}
/************************ Event: OnClick over timeline Element ************************/

function loadElementPlayer(tapeID, count, duration, timestamp, type_longStr, segmentID, isExtra, fileName, filePath, duration_formatStr, tapeType, fileStatus) {

    /************************ General variables START ************************/

    var divPlayer_VIDEO = $("#divPlayer_VIDEO");
    var divControlsMask_AUDIO = $("#divControlsMask_AUDIO");
    var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");
    var divPanel_PlayerControl = $("#divPanel_PlayerControl");
    var lnkElementDownload = $("#lnkElementDownload");
    var btnRemoveElement = $("#btnRemoveElement");
    var btnConfirmRemoveElement = $("button[id*='btnConfirmRemoveElement']");
    var divRemoveElementMessage = $("div[id*='divRemoveElementMessage']");
    var aPlayPause_AUDIO = $("#aPlayPause_AUDIO");
    var aPlayPause_VIDEO = $("#aPlayPause_VIDEO");
    var lnkSound_AUDIO = $("#lnkSound_AUDIO");
    var lnkSound_VIDEO = $("#lnkSound_VIDEO");

    // Get file extension
    var file_extension = getFileExtension(fileName);

    /************************ General variables END ************************/

    /************************ General events START ************************/
    oldPlayer_activeElement_type = "";
    oldPlayer_activeElement_extension = "";
    oldPlayer_activeElement_duration = "";

    // Remove click event
    aPlayPause_VIDEO.attr('onclick', '');
    aPlayPause_VIDEO.off("click");

    // Clear previous onclick events
    lnkElementDownload.attr('onclick', '');
    lnkElementDownload.off("click");

    // Load on click event to download element link
    if (tapeType != "C") {
        var filePath_str = "";

        // If audio is from incextras (isExtra = true) then use localPath, if not use oreka web service

        //////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////   DOWNLOAD FILE URL   /////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////
        if (isExtra != null && isExtra.length > 0) {
            var isExtra_str = isExtra.toString();
            if (isExtra_str.toLowerCase() === "true") {
                filePath_str = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=1";

            } else {
                filePath_str = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=0";
            }
        }
        lnkElementDownload.attr("href", filePath_str);
    }

    // ------- Remove element click

    // Clear previous onclick or click events
    btnRemoveElement.attr('onclick', '');
    btnRemoveElement.off("click");

    /**** Event: OnClick Load on click event remove button (btnRemoveElement) ****/
    loadClickRemoveButton_event();

    divRemoveElementMessage.text(hashMessages["ConfirmarBorrarUnElemento"]);
    divRemoveElementMessage.removeClass("alert-danger");
    divRemoveElementMessage.addClass("alert-warning");

    // ------- Confirm Remove element click

    // Clear previous onclick or click events
    btnConfirmRemoveElement.attr('onclick', '');
    btnConfirmRemoveElement.off("click");

    /**** Event: OnClick Load on click event confirm remove button (btnConfirmRemoveElement) ****/
    loadClickConfirmRemoveButton_event(tapeID, isExtra);

    /************************ General events END ************************/

    /************************ General styles START ************************/

    // Set video player visible
    divPlayer_VIDEO.css("visibility", "visible");
    $("#divControlsMask_VIDEO").removeClass("disabled");

    // Show fullscreen button
    $("#btnFullscreen").show();

    // Hide fullscreen button for Screen recording elements
    $("#aBtnFullscreen").hide();

    // Clear Player box images
    loadPlayerBoxImage("");

    // Enable functions logic
    divPanel_PlayerControl.removeClass("disabled");
    divControlsMask_AUDIO.removeClass("disabled");

    // If it is NOT extra, then disable remove button
    if (isExtra.toLowerCase() === "false") {
        $("#btnRemoveElement").addClass("disabled");
    } else {
        $("#btnRemoveElement").removeClass("disabled");
    }

    // Disable functions logic
    $("#btnFullscreen").addClass("disabled"); // Any other video Fullscreen
    $("#aBtnFullscreen").addClass("disabled"); // FBS Fullscreen  

    // Empty video and audio progress
    $(".sm2-progress-bar").css("width", 0);
    $("#sm2-progress-ball_VIDEO").css("left", "0%");
    $("#sm2-progress-ball_AUDIO").css("left", "0%");

    var sound_player = window.sm2BarPlayers[1];
    if (sound_player != null && soundManager != null) {
        sound_player.actions.stop();
        sound_player.dom.progress.style.left = "0%";
        sound_player.dom.progressBar.style.width = "0%";
    }

    // Empty title
    $("#lblSoundTitle1_AUDIO, #lblSoundTitle2_AUDIO").text("");

    // Set pause icon to players
    divControlsMask_AUDIO.addClass("paused");
    divControlsMask_AUDIO.removeClass("playing");
    divControlsMask_VIDEO.addClass("paused");
    divControlsMask_VIDEO.removeClass("playing");

    // Hide comments
    $("div[name='divComment']").hide();

    // Empty screen recording applet or avi video plugin
    if (divPlayer_VIDEO != null && divPlayer_VIDEO.length) {
        divPlayer_VIDEO.empty();
        divPlayer_VIDEO.hide();
    }

    // Remove all images if exist
    $("#photobox-container img").remove();

    // Remove all objects if exist (including wav_object activeX audio)
    $("#audioContainer object").each(function () {
        var audio_player = $(this)[0];
        if (audio_player != null && audio_player.controls != null) {
            audio_player.controls.pause();
        }
    });

    $("#audioContainer object").remove();

    // Remove progress click event - Audio ActiveX object  - 
    if (playPauseInterval != null) {
        clearInterval(playPauseInterval);
    }


    /************************ General styles END ************************/

    /************************ General info START ************************/

    // Set isPlaying false to all elements
    setAllElementsInMemoryNotPlaying();

    // Remove previous info
    removeDivPlayer();

    // Load global timestamp to use in comment popup
    comment_popup_timestamp = timestamp;

    // Right side element details --------------------
    var lblType = type_longStr === "Grabación" ? "Grabación de pantalla" : type_longStr;

    $("#lblType").val(lblType);
    $("#lblName").val(fileName);
    $("#lblTimestamp").val(timestamp);


    var duration_int = parseInt(duration, 10);
    if (duration_int == 0) {
        duration_formatStr = "No tiene";
    }
    $("#lblDuration").val(duration_formatStr);

    var fileStatus_str = fileStatus;
    if (fileStatus === "") {
        fileStatus_str = "OK";
    }

    $("#lblStatus").val(fileStatus_str);

    /************************ General info END ************************/

    /************************ Elements path configuration ************************/

    //////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////   READ FILE URL   ////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////

    var filePath_EXTRA = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=1";
    var filePath_OREKA = WS_Oreka_Server + ":" + WS_Oreka_Port + WS_Oreka_URL + "?segid=" + segmentID;

    // SET Element file path
    var file_url = filePath_OREKA;

    if (isExtra != null && isExtra.length > 0) {
        var isExtra_str = isExtra.toString();
        if (isExtra_str.toLowerCase() === "true") {
            file_url = filePath_EXTRA;
        }
    }

    /************************ Elements path configuration END ************************/

    /************************ LOAD ELEMENT on Player BEGIN ************************/

    // Load old player global variables
    if (tapeType != null) {
        oldPlayer_activeElement_type = tapeType
    }

    if (duration != null) {
        oldPlayer_activeElement_duration = duration;
    }
    if (file_extension != null && file_extension.length > 0) {
        oldPlayer_activeElement_extension = file_extension[0];
    }

    switch (tapeType) {
        case "S":
        case "P":
        case "V": {
            oldPlayer_activeElement_type = tapeType == "P" ? "S" : tapeType;

            // Special case
            file_url = tapeType === "S" ? WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=0" : file_url;

            loadElement_video_screenRecording(file_url, divPlayer_VIDEO, divControlsMask_VIDEO, file_extension, divControlsMask_AUDIO, aPlayPause_VIDEO, fileName, duration, fileStatus, tapeID, segmentID);
            break;
        }

        case "A": {
            loadElement_audio(file_url, divControlsMask_AUDIO, fileName, lnkSound_AUDIO, file_extension, tapeID, aPlayPause_AUDIO, duration);
            break;
        }

        case "C": {
            loadElement_comment(divControlsMask_VIDEO, timestamp, fileName);
            break;
        }

        case "I": {
            loadElement_image(file_url, divControlsMask_VIDEO, divControlsMask_AUDIO, fileStatus);
            break;
        }

        case "D": {
            loadElement_document(divControlsMask_VIDEO, divControlsMask_VIDEO);
            break;
        }

    }

    // If the element is PROCESSING or ERROR 
    if (fileStatus === "PROCESSING" || fileStatus === "ERROR") {
        $("#lnkElementDownload").addClass("disabled");
        $("#btnFullscreen").addClass("disabled");
        $("#aBtnFullscreen").addClass("disabled");
    }

    /************************ Load element on Player END ************************/
}

//************************************** 1. VIDEO Element OR SCREEN RECORDING Element ***************************************
function loadElement_video_screenRecording(file_url, divPlayer_VIDEO, divControlsMask_VIDEO, file_extension, divControlsMask_AUDIO, aPlayPause_VIDEO, fileName, duration, fileStatus, tapeID, segmentID) {

    /*
     * Steps:
     * 1. File extension
     * 2. Browser support
     * 
     */

    var ok = true;

    if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {
        switch (file_extension[0]) {

            // HTML5 support:
            case "mp4":
            case "webm":
            case "ogg": {

                $("#btnFullscreen").show(); // Any other video Fullscreen
                $("#btnFullscreen").removeClass("disabled"); 

                $("#aBtnFullscreen").hide(); // FBS Fullscreen
                $("#aBtnFullscreen").addClass("disabled"); 

                loadPlayer_HTML5_Webchimera_Styles1(divPlayer_VIDEO, divControlsMask_VIDEO);

                // HTML5 support:
                ok = loadPlayer_HTML5(file_url, divPlayer_VIDEO, aPlayPause_VIDEO, divControlsMask_VIDEO);

                loadPlayer_HTML5_Webchimera_Styles2(fileName, duration, divControlsMask_AUDIO, fileStatus, ok);

                break;
            }

                // Oreka Player:
            case "fbs": {

                // Oreka Player:
                loadPlayer_OrekaPlayer(tapeID, fileStatus, duration, divControlsMask_AUDIO, divPlayer_VIDEO, divControlsMask_AUDIO, fileName, segmentID, divControlsMask_VIDEO)

                break;
            }

                // Webchimera Plugin Player or else:
            case "avi":
            case "crypt":
            case "bin":
            default: {

                loadPlayer_HTML5_Webchimera_Styles1(divPlayer_VIDEO, divControlsMask_VIDEO);

                // Webchimera plugin - Source: https://github.com/LukasBombach/nw-webchimera-demos

                // Webchimera Plugin Player or else:
                ok = loadPlayer_Webchimera(divPlayer_VIDEO, file_url, aPlayPause_VIDEO, divControlsMask_VIDEO, duration, fileName);

                loadPlayer_HTML5_Webchimera_Styles2(fileName, duration, divControlsMask_AUDIO, fileStatus, ok);

                break;
            }
        }
    }

    if (!ok) {
        $("#dialog p").text(hashMessages["UtilizarNavegador1"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });

        // Disable video player & audio player
        if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length && divControlsMask_AUDIO != null && divControlsMask_AUDIO.length) {
            divControlsMask_VIDEO.addClass("disabled");
            divControlsMask_AUDIO.addClass("disabled");
        }

    }

    //#endregion
}


//************************************** 2. AUDIO Element ***************************************
function loadElement_audio(file_url, divControlsMask_AUDIO, fileName, lnkSound_AUDIO, file_extension, tapeID, aPlayPause_AUDIO, duration) {

    /************************ Local audio variables ************************/

    // Clear Audio and Video player
    emptyAudioPlayer();
    emptyVideoPlayer();

    // Remove previous error messages from the audio player
    $(".load-error").remove();

    ////////////////////////////////////

    // Clear previous onclick events
    aPlayPause_AUDIO.attr('onclick', '');
    aPlayPause_AUDIO.off("click");

    // Clear player control settings
    $("#lnkSound_AUDIO").attr("href", "");
    $("#sm2-inline-time_AUDIO").text("0:00");

    // Get duration format: m:ss
    var currentTime_final = getFormatDuration_short(duration);
    $("#sm2-inline-duration_AUDIO").text(currentTime_final);

    // Clear SoundManager previous playlist
    SetAudioPlaylistURL(0, "xx");
    SetAudioPlaylistURL(1, "xx");

    // Hide Video Player
    $("#divControlsMask_VIDEO").addClass("disabled");

    // Show volume control
    $("#volume_AUDIO").show();

    // Set title
    $("#lblSoundTitle1_AUDIO, #lblSoundTitle2_AUDIO").text(fileName);

    // Set Stop icon
    if (divControlsMask_AUDIO != null && divControlsMask_AUDIO.length > 0) {

        // Show sound player
        divControlsMask_AUDIO.show("blind", 200);

        if (divControlsMask_AUDIO.hasClass("playing")) {
            divControlsMask_AUDIO.addClass("paused");
            divControlsMask_AUDIO.removeClass("playing");
        }

        divControlsMask_AUDIO.on("click", { _tapeID: tapeID }, playAudioElement);
    }
    // Set background image
    loadPlayerBoxImage("url(assets/images/audio.png)");

    ////////////////////////////////////

    if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

        /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
        if (getIsIE() && file_extension[0] == "wav") {

            // Create audio player
            var w = parseInt($("#divControlsMask_AUDIO").css("width"), 10);
            var h = parseInt($("#divControlsMask_AUDIO").css("height"), 10);

            // WMP player Source 1: http://joliclic.free.fr/html/object-tag/en/
            // WMP player Source 2: https://coderwall.com/p/8yulaa/windows-media-player-events-framework

            // ActiveX object
            var wav_object = "<object id='wav_object1' data='" + file_url + "' type='audio/x-wav' width='" + w + "' height='" + h + "' ";
            wav_object += "style='display: none;' classid='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6'> ";
            wav_object += "<param name='URL' value='" + file_url + "'> ";
            wav_object += "<param name='autoplay' value='false'> ";
            wav_object += "<param name='autoStart' value='0'> ";
            wav_object += "</object>";

            $("#audioContainer object").remove();
            $("#audioContainer").append(wav_object);

            // Hide volume control
            $("#volume_AUDIO").hide();

            // Remove previous error messages from the audio player
            $(".load-error").remove();

            var duration_int = parseInt(duration, 10);

            // Click on Play icon AUDIO
            aPlayPause_AUDIO.bind("click", function () {
                if (divControlsMask_AUDIO != null && divControlsMask_AUDIO.length > 0) {

                    if ($("#wav_object1") != null && $("#wav_object1")[0] != null && $("#wav_object1")[0].controls != null) {

                        if (divControlsMask_AUDIO.hasClass("paused")) {
                            divControlsMask_AUDIO.addClass("playing");
                            divControlsMask_AUDIO.removeClass("paused");
                            $("#wav_object1")[0].controls.play();

                            // EVENT: Whileplaying
                            IEObjectPlayer_audio_whileplaying(duration_int);

                        } else {
                            divControlsMask_AUDIO.addClass("paused");
                            divControlsMask_AUDIO.removeClass("playing");
                            $("#wav_object1")[0].controls.pause();

                            // Pause Whileplaying event
                            IEObjectPlayer_whileplaying_pause();
                        }

                        // Remove previous error messages from the audio player
                        setTimeout(function () {

                            $(".load-error").remove();
                        }, 200);
                    }
                }
            });

            // Click on Progress track AUDIO
            $("#sm2-progress-track_AUDIO").on("click", { _duration: duration_int }, pre_getClickPosition_AUDIO);


        } else { // Normal HTML5 Audio tag

            // Prepare audio player
            lnkSound_AUDIO.attr("href", file_url);
            SetAudioPlaylistURL(0, file_url);
        }
    }
}

function pre_getClickPosition_AUDIO(event){
    getClickPosition_AUDIO(event, event.data._duration);
}

function getClickPosition_AUDIO(event, duration) {
    if (duration != null) {
        var parentPosition = getPosition3(event.currentTarget);
        var xPosition = event.clientX - parentPosition.x;
        var yPosition = event.clientY - parentPosition.y;
        var sm2_progress_track_AUDIO = $("#sm2-progress-track_AUDIO");

        if (sm2_progress_track_AUDIO != null && sm2_progress_track_AUDIO.length) {
            var left_percentage = parseInt(xPosition / parseInt(sm2_progress_track_AUDIO.css("width"), 10) * 100, 10);
            var currentSecs = left_percentage * duration / 100;

            var video_player = $("#wav_object1");
            if (video_player != null && video_player[0] != null && video_player[0].controls != null) {
                video_player[0].controls.currentPosition = currentSecs;
            }
        }
    }
}


// Audio IE Object - Event Whileplaying variable
var playPauseInterval;

// Audio IE Object EVENT: Whileplaying
function IEObjectPlayer_audio_whileplaying(duration) {

    playPauseInterval = setInterval(function () {

        if ($("#wav_object1") != null && $("#wav_object1")[0] != null && $("#wav_object1")[0].controls != null) {
            var currentTime = $("#wav_object1")[0].controls.currentPosition;

            var currentTime_int = parseFloat(currentTime, 10);
            var currentTime_final = getFormatDuration_short(currentTime_int);
            var max_time = $("#sm2-inline-duration_AUDIO").text();

            if (currentTime < duration && currentTime != 0) {

                // Move Pointer 
                var progress_percentage = currentTime * 100 / duration;
                var left_final_percentage = progress_percentage + '%';

                var pointer_AUDIO = $('#sm2-progress-ball_AUDIO');
                if (pointer_AUDIO != null) {
                    pointer_AUDIO.css("left", left_final_percentage);
                }

                // Update current timer label
                $('#sm2-inline-time_AUDIO').text(currentTime_final);
            } else {
                if (currentTime != 0) {
                    $("#divControlsMask_AUDIO").addClass("paused");
                    $("#divControlsMask_AUDIO").removeClass("playing");

                    if (currentTime >= duration && max_time != "N/A") {

                        // Update current timer label to reach the maximum
                        $('#sm2-inline-time_AUDIO').text(max_time);
                    }
                }
            }
        }
    }, 100);
}


// Pause Whileplaying event
function IEObjectPlayer_whileplaying_pause() {

    clearInterval(playPauseInterval);
}


// Video IE Object - Event Whileplaying variable
var playPauseInterval;

// Video IE Object EVENT: Whileplaying
function IEObjectPlayer_video_whileplaying(duration) {

    playPauseInterval = setInterval(function () {

        if ($("#video_object1") != null && $("#video_object1")[0] != null && $("#video_object1")[0].controls != null) {
            var currentTime = $("#video_object1")[0].controls.currentPosition;

            var currentTime_int = parseFloat(currentTime, 10);
            var currentTime_final = getFormatDuration_short(currentTime_int);
            var max_time = $("#sm2-inline-duration_VIDEO").text();

            if (currentTime < duration && currentTime != 0) {

                // Move Pointer 
                var progress_percentage = currentTime * 100 / duration;
                var left_final_percentage = progress_percentage + '%';

                var pointer_VIDEO = $('#sm2-progress-ball_VIDEO');
                if (pointer_VIDEO != null) {
                    pointer_VIDEO.css("left", left_final_percentage);
                }

                // Update current timer label
                $('#sm2-inline-time_VIDEO').text(currentTime_final);
            } else {
                if (currentTime != 0) {
                    $("#divControlsMask_VIDEO").addClass("paused");
                    $("#divControlsMask_VIDEO").removeClass("playing");

                    if (currentTime >= duration && max_time != "N/A") {

                        // Update current timer label to reach the maximum
                        $('#sm2-inline-time_VIDEO').text(max_time);
                    }
                }
            }
        }
    }, 100);
}




//************************************* 3. COMMENT Element **************************************
function loadElement_comment(divControlsMask_VIDEO, timestamp, fileName) {
    removeDivPlayerContentExcept();
    if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {
        divControlsMask_VIDEO.hide();
    }

    if (PLAYER_BOX != null && PLAYER_BOX.length) {
        PLAYER_BOX.append(
            "<div name='divComment' class='col-md-12' style='margin: 30px; margin-top:20px;'><div class='row'><h1 style='font-weight: bold;float:left;'>" +
            timestamp +
            "</h1></div><div class='row'><p class='pull-left' style='margin-top:15px;'>" +
            fileName + "</p></div></div>");
    }
    loadPlayerBoxImage("url(assets/images/document.png)");
    $("#lnkElementDownload").addClass("disabled");
    $("#btnRemoveElement").removeClass("disabled");
}

//*************************************** 4. IMAGE Element **************************************
function loadElement_image(file_url, divControlsMask_VIDEO, divControlsMask_AUDIO, fileStatus) {
    if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {
        divControlsMask_VIDEO.hide();
    }
    if (divControlsMask_AUDIO != null && divControlsMask_AUDIO.length > 0) {
        divControlsMask_AUDIO.addClass("disabled");
    }

    removeDivPlayerContentExcept();

    $("#imgPlayer").attr("src", file_url);

    // Style settings
    $("#imgPlayer").show("blind", 200);

    // Enable/Disable functions
    if (fileStatus != "PROCESSING" && fileStatus != "ERROR") {
        $("#btnFullscreen").removeClass("disabled");
        $("#divControlsMask_VIDEO").removeClass("disabled");
        $("#lnkElementDownload").removeClass("disabled");
    } else {
        $("#btnFullscreen").addClass("disabled");
        $("#divControlsMask_VIDEO").addClass("disabled");
        $("#lnkElementDownload").addClass("disabled");
    }
}

//************************************ 5. DOCUMENT Element **************************************
function loadElement_document(divControlsMask_VIDEO, divControlsMask_VIDEO) {
    loadPlayerBoxImage("url(assets/images/document.png)");
    if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {
        divControlsMask_VIDEO.hide();
    }

    if (divControlsMask_VIDEO != null && divControlsMask_AUDIO.length > 0) {
        divControlsMask_AUDIO.addClass("disabled");
    }
}


function loadPlayer_HTML5_Webchimera_Styles1(divPlayer_VIDEO, divControlsMask_VIDEO) {
    /************************ Styles START ************************/
    var manual_offset = 50;
    divPlayer_VIDEO.show();
    divPlayer_VIDEO.css("height", (parseInt(PLAYER_BOX.css("height"), 10) - manual_offset) + "px");

    divControlsMask_VIDEO.show();

    divPlayer_VIDEO.offset({ top: PLAYER_BOX.offset().top + manual_offset + 2 });

    /************************ Styles END ************************/
}

function loadPlayer_HTML5_Webchimera_Styles2(fileName, duration, divControlsMask_AUDIO, fileStatus, ok) {

    /************************ Styles START ************************/
    // Set mask title
    $("#lblSoundTitle1_VIDEO").text(fileName);

    // Set mask duration
    setVideoLength(duration);

    // Disable audio player
    divControlsMask_AUDIO.addClass("disabled");
    /************************ Styles END ************************/

    /************************ Events START ************************/
    // Click over progress bar 
    // Video player
    $("#sm2-progress-track_VIDEO").on("click", { _duration: duration, _fileName: fileName }, setVideoCurrent);

    /************************ Events END ************************/


    /************************ Styles START ************************/
    // Enable/Disable functions
    if (fileStatus != "PROCESSING" && fileStatus != "ERROR" && ok) {
        $("#btnFullscreen").removeClass("disabled");
        $("#divControlsMask_VIDEO").removeClass("disabled");
        $("#lnkElementDownload").removeClass("disabled");
    } else {
        $("#btnFullscreen").addClass("disabled");
        $("#divControlsMask_VIDEO").addClass("disabled");
        $("#lnkElementDownload").addClass("disabled");
    }
    /************************ Events END ************************/

}


// Oreka Player:
function loadPlayer_OrekaPlayer(tapeID, fileStatus, duration, divControlsMask_AUDIO, divPlayer_VIDEO, divControlsMask_AUDIO, fileName, segmentID, divControlsMask_VIDEO) {

    var ok = false;

    if (getIsFirefoxOrIE()) {
        screenRecording_segmentID = tapeID;

        SetAudioPlaylistURL(0, "xx");
        SetAudioPlaylistURL(1, "xx");

        // Enable/Disable functions
        if (fileStatus != "PROCESSING" && fileStatus != "ERROR") {
            $("#btnFullscreen").removeClass("disabled");
            $("#aBtnFullscreen").removeClass("disabled");
            $("#lnkElementDownload").removeClass("disabled");
            divControlsMask_VIDEO.removeClass("disabled");
        } else {
            $("#btnFullscreen").addClass("disabled");
            $("#aBtnFullscreen").addClass("disabled");
            $("#lnkElementDownload").addClass("disabled");
            divControlsMask_VIDEO.addClass("disabled");
        }

        /************************ Events START ************************/
        // Click over progress bar 
        // Video player
        $("#sm2-progress-track_VIDEO").on("click", { _duration: duration, _fileName: fileName }, setVideoCurrent);

        // Click over play/pause button 
        divControlsMask_AUDIO.on("click", { _tapeID: tapeID }, playAudioElement);
        /************************ Events END ************************/

        // Clear Audio and Video player
        emptyAudioPlayer();
        emptyVideoPlayer();

        // Play/Pause actions button
        ActionVideoPlay(tapeID, duration, false);

        /************************ Styles START ************************/
        // Show Video Player
        if (divPlayer_VIDEO != null && divPlayer_VIDEO.length) {
            divPlayer_VIDEO.show();
        }
        // Disable audio player
        if (divControlsMask_AUDIO != null && divControlsMask_AUDIO.length) {
            divControlsMask_AUDIO.addClass("disabled");
        }
        /************************ Styles END ************************/

        // Load FBS Player
        videoPlayerINIT(fileName, duration, segmentID);

        // Enable video player
        if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length && divPlayer_VIDEO != null && divPlayer_VIDEO.length) {

            divControlsMask_VIDEO.removeClass("disabled");

            // Set playing
            divControlsMask_VIDEO.addClass("playing");
            divControlsMask_VIDEO.removeClass("paused");
            TimeRefreshLoop(duration);

            // Coloca los controles en top = 0, por si antes fue usado el Video player (webchimera player)
            divPlayer_VIDEO.offset({ top: PLAYER_BOX.offset().top });

        }

        // Set duration
        setVideoLength(duration);

        $("#aBtnFullscreen").removeClass("disabled");
        $("#aBtnFullscreen").show();
        $("#btnFullscreen").hide();

        // Hide masked controls - Quitar? 
        divPlayer_VIDEO.css("visibility", "visible");
        $("#divControlsMask_VIDEO").hide();

        ok = true;
    }

    return ok;
}

// Webchimera Plugin Player or else:
function loadPlayer_Webchimera(divPlayer_VIDEO, file_url, aPlayPause_VIDEO, divControlsMask_VIDEO, duration, fileName) {

    var ok = false;

    // INIT webchimera
    if (getIsFirefoxOrIE()) {

        // Clear previous onclick events
        aPlayPause_VIDEO.attr('onclick', '');
        aPlayPause_VIDEO.off("click");

        // Create video player
        var width = parseInt(divPlayer_VIDEO.css("width"), 10);
        var height = parseInt(divPlayer_VIDEO.css("height"), 10);

        if (getIsIE()) {

            // ActiveX video object

            var video_player = "<div id='divVideo_object1' style='width:" + width + "px; " + "height:auto; margin:0 auto; display: inline;'> "; // height
            video_player += "<object id='video_object1' data='" + file_url + "' ";
            video_player += "width='" + width + "' height='" + height + "' ";
            video_player += "style='margin-top:4px;' ";
            video_player += "CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6'> ";
            video_player += "<PARAM name='URL' value='" + file_url + "'> ";
            video_player += "<PARAM name='autoStart' value='False'> ";
            video_player += "<PARAM name='uiMode' value='none'> ";
            video_player += "</object></div>";

            $("#divPlayer_VIDEO object").remove(); // revisar no solo objetos
            divPlayer_VIDEO.append(video_player);


            /***************** EVENTS START *****************/

            ////////////////////////////////

            var duration_int = parseInt(duration, 10);

            // Click on Play icon VIDEO
            aPlayPause_VIDEO.bind("click", function () {
                if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {

                    if ($("#video_object1") != null && $("#video_object1")[0] != null && $("#video_object1")[0].controls != null) {

                        if (divControlsMask_VIDEO.hasClass("paused")) {
                            divControlsMask_VIDEO.addClass("playing");
                            divControlsMask_VIDEO.removeClass("paused");
                            $("#video_object1")[0].controls.play();

                            // EVENT: Whileplaying
                            IEObjectPlayer_video_whileplaying(duration_int);

                        } else {
                            divControlsMask_VIDEO.addClass("paused");
                            divControlsMask_VIDEO.removeClass("playing");
                            $("#video_object1")[0].controls.pause();

                            // Pause Whileplaying event
                            IEObjectPlayer_whileplaying_pause();
                        }

                    }
                }
            });

            var ok = true;

            /***************** EVENTS END *****************/

        } else {

            // BEGIN webchimera -------------------------------------------------------

            var applet = "<object id='webchimera1' type='application/x-chimera-plugin' width='" + width + "' height='" + height + "'> ";
            applet += "<param name='windowless' value='true' /> ";
            applet += "</object> ";
            applet += "<div id='interface'></div> ";

            $("#divPlayer_VIDEO object").remove();
            divPlayer_VIDEO.append(applet);

            // If it does not fail to load webchimera plugin
            var ok = true;

            try {
                wjs("#webchimera1").clearPlaylist();
                wjs("#webchimera1").addPlaylist(file_url);
            } catch (err) {
                console.log("l:2790 Error loading webchimera");
                console.log(err);

                // Show alert message
                $("#dialog_WebChimera p").text(hashMessages["InstallWebchimera"]);
                $("#dialog_WebChimera a").attr("href", hashMessages["InstallWebchimera_url"]);
                $("#dialog_WebChimera a").text("aquí.")
                $("#dialog_WebChimera").dialog({
                    buttons: {
                        "OK": function () {
                            $(this).dialog("close");
                        }
                    }
                });

                // Disable player
                ok = false;
            }


            /***************** EVENTS START *****************/


            // Click on Play icon VIDEO
            aPlayPause_VIDEO.bind("click", function () {

                if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {

                    if (divControlsMask_VIDEO.hasClass("paused")) {
                        divControlsMask_VIDEO.addClass("playing");
                        divControlsMask_VIDEO.removeClass("paused");

                        // BEGIN webchimera -------------------------------------------------------

                        wjs("#webchimera1").play();

                        // Event: While playing
                        var previousSecsAVI = 0;
                        wjs("#webchimera1").onTime(function () {
                            var timer_VIDEO = $('#sm2-inline-time_VIDEO');
                            var pointer_VIDEO = $('#sm2-progress-ball_VIDEO');
                            var currentSecs = wjs("#webchimera1").time() / 1000;

                            if (currentSecs < duration && /* currentSecs >= previousSecs && */ currentSecs != 0) {
                                previousSecsAVI = currentSecs;
                                var left = (wjs("#webchimera1").position() * 100) + "%";
                                var secs_int = parseInt(currentSecs, 10);
                                timer_VIDEO.text(getTime(wjs("#webchimera1").time(), true).toString());

                                // Pointers progress
                                pointer_VIDEO.css("left", left);
                            }
                        });

                    } else {
                        divControlsMask_VIDEO.addClass("paused");
                        divControlsMask_VIDEO.removeClass("playing");

                        wjs("#webchimera1").pause();
                    }
                }
            });

            // Event: While playing
            var previousSecsAVI = 0;
            wjs("#webchimera1").onTime(function () {
                var timer_VIDEO = $('#sm2-inline-time_VIDEO');
                var pointer_VIDEO = $('#sm2-progress-ball_VIDEO');
                var currentSecs = wjs("#webchimera1").time() / 1000;

                if (currentSecs < duration && /* currentSecs >= previousSecs && */ currentSecs != 0) {
                    previousSecsAVI = currentSecs;
                    var left = (wjs("#webchimera1").position() * 100) + "%";
                    var secs_int = parseInt(currentSecs, 10);
                    timer_VIDEO.text(getTime(wjs("#webchimera1").time(), true).toString());

                    // Pointers progress
                    pointer_VIDEO.css("left", left);
                }
            });

            /***************** EVENTS END *****************/

            // Bottom progress track
            $("#sm2-progress-track").on("click", {
                _duration: duration,
                _fileName: fileName
            }, setVideoCurrent);


        } // END webchimera

        
        /************************ Events END ************************/

        ok = true;
    }

    return ok;
}

// HTML5 support:
function loadPlayer_HTML5(file_url, divPlayer_VIDEO, aPlayPause_VIDEO, divControlsMask_VIDEO) {

    // HTML5 video tag Source: https://www.w3.org/2010/05/video/mediaevents.html

    // Create video player
    var width = parseInt(divPlayer_VIDEO.css("width"), 10);
    var height = parseInt(divPlayer_VIDEO.css("height"), 10);

    var js_player = '<video id="html_video" preload="none" style="width: ' + width + 'px; height: ' + height + 'px; margin: 0 auto;">';
    js_player += '<source id="mp4" src="' + file_url + '" type="video/mp4">';
    js_player += '<source id="webm" src="' + file_url + '" type="video/webm">';
    js_player += '<source id="ogv" src="' + file_url + '" type="video/ogg">';
    js_player += '</video>';

    divPlayer_VIDEO.append(js_player);

    /************************ Events START ************************/
    // Clear previous onclick events
    aPlayPause_VIDEO.attr('onclick', '');
    aPlayPause_VIDEO.off("click");

    // Click on Play icon VIDEO
    aPlayPause_VIDEO.bind("click", function () {
        if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {

            if (divControlsMask_VIDEO.hasClass("paused")) {
                divControlsMask_VIDEO.addClass("playing");
                divControlsMask_VIDEO.removeClass("paused");
                $("#html_video")[0].play()

            } else {
                divControlsMask_VIDEO.addClass("paused");
                divControlsMask_VIDEO.removeClass("playing");
                $("#html_video")[0].pause();
            }
        }
    });

    var timer_VIDEO = $('#sm2-inline-time_VIDEO');

    // Event: While Playing
    $("#html_video").on("timeupdate", function (event) {
        onTrackedVideoFrame(this.currentTime, this.duration, timer_VIDEO, divControlsMask_VIDEO);
    });
    /************************ Events END ************************/

    return true;
}

// Event: While Playing of HTML5 Video tag (webm, mp4, ogg)
function onTrackedVideoFrame(currentTime, duration, timer_VIDEO, divControlsMask_VIDEO) {
    var currentTime_int = parseFloat(currentTime, 10);
    var currentTime_final = getFormatDuration_short(currentTime_int);
    var max_time = $("#sm2-inline-duration_VIDEO").text();

    if (currentTime < duration && currentTime != 0) {

        // Move Pointer 
        var progress_percentage = currentTime * 100 / duration;
        var left_final_percentage = progress_percentage + '%';

        var pointer_VIDEO = $('#sm2-progress-ball_VIDEO');
        if (pointer_VIDEO != null) {
            pointer_VIDEO.css("left", left_final_percentage);
        }

        // Update current timer label
        timer_VIDEO.text(currentTime_final);
    } else {
        if (currentTime != 0) {
            divControlsMask_VIDEO.addClass("paused");
            divControlsMask_VIDEO.removeClass("playing");

            if (currentTime >= duration && max_time != "N/A") {

                // Update current timer label to reach the top
                timer_VIDEO.text(max_time);
            }
        }
    }
}

/**** Event: OnClick Load on click event remove button (btnRemoveElement) ****/
function loadClickRemoveButton_event() {
    var btnRemoveElement = $("#btnRemoveElement");
    btnRemoveElement.bind("click", function () {
        if (!$('#btnRemoveElement').hasClass("opened")) {
            $('.popbox3').popbox3();
            $(".box3.popbox3").show("highlight", 700);
            $('#txbConfirmRemoveElement').focus();
            $('#btnRemoveElement').addClass("opened");
        } else {
            $(".box3.popbox3").hide(200);
            $('#btnRemoveElement').removeClass("opened");
        }
    });
}

/**** Event: OnClick Load on click event confirm remove button (btnConfirmRemoveElement) ****/
function loadClickConfirmRemoveButton_event(tapeID, isExtra) {

    var btnConfirmRemoveElement = $("#popbox_footer3 button[id*='btnConfirmRemoveElement']");
    var divPanel_PlayerControl = $("#divPanel_PlayerControl");
    var divRemoveElementMessage = $("#divRemoveElementMessage");

    btnConfirmRemoveElement.bind("click", function () {

        var userID = globalUserID;
        var password_input = $("#txbConfirmRemoveElement");

        if (userID != null && userID != "" && password_input != null && password_input.val() != "") {
            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/ConfirmRemoveElement",
                data: '{userID: "' + userID + '",password_input: "' + password_input.val() + '",tapeID: "' + tapeID + '",isExtra: "' + isExtra + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == 1) {

                        // Hide element from search panel
                        $("#tblLeftGridElements #tape_" + tapeID).hide();


                        // Disable element in memory elements 
                        var _hdnIsUpdateNeeded = $("#_hdnIsUpdateNeeded");
                        if (_hdnIsUpdateNeeded != null) {
                            _hdnIsUpdateNeeded.val("true");
                        }
                        // Clear div player
                        removeDivPlayerContentExcept();

                        /************************ Reload timeline BEGIN ************************/

                        $("#timeframe").empty(); // Clean div content
                        var new_timeline_data = jQuery.extend(true, {}, _TL_DATA); // It clones the object, do not references it

                        if (new_timeline_data.spans != null && new_timeline_data.spans.length > 0) {
                            new_timeline_data.spans =
                                $.grep(_TL_DATA.spans,
                                    function (item, index) {
                                        return item.id != tapeID;
                                    });
                        }
                        _TL_DATA = new_timeline_data;

                        // Refresh max and min dates, timeline limits
                        max = new Date(-100000000 * 86400000);
                        min = new Date(100000000 * 86400000);
                        traverse(_TL_DATA.spans, compare);

                        // **** DRAW TIMELINE ****
                        timeframe_draw(_TL_DATA, _TL_STARTDATE, _TL_ENDDATE);

                        /******** Reload timeline END ********/

                        // Update elements count
                        $("#divPanel_Busqueda span[id*='lblResultsCount']").text($("#tblLeftGridElements tr[id*='tape_']:visible").length.toString());

                        // Disable div player again
                        divPanel_PlayerControl.addClass("disabled");

                        // Remove previous info
                        removeDivPlayer();

                        // force to close popup
                        $(".box3.popbox3").hide();

                        // Clear password field
                        $("#txbConfirmRemoveElement").val("");

                        $("#dialog p").text(hashMessages["ElementoBorrado"]);
                        $("#dialog").dialog({
                            buttons: {
                                "Confirmar": function () {
                                    $(this).dialog("close");
                                }
                            }
                        });

                        // Clear player image
                        $("#imgPlayer").attr("src", "");

                    } else if (response.d == 0) {
                        divRemoveElementMessage.text("La contraseña no es válida ");
                        divRemoveElementMessage.removeClass("alert-danger");
                        divRemoveElementMessage.removeClass("alert-warning");
                        divRemoveElementMessage.addClass("alert-danger");
                    } else if (response.d == 2) {
                        divRemoveElementMessage.text(" Ocurrió un error en la opreación");
                        divRemoveElementMessage.removeClass("alert-danger");
                        divRemoveElementMessage.removeClass("alert-warning");
                        divRemoveElementMessage.addClass("alert-danger");
                    }
                }, // end success
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
    });
}

function SetAudioPlaylistURL(number, vURL) {

    var player = window.sm2BarPlayers[number]; // Collection priority
    if (player != null && player.playlistController && player.playlistController.getSoundObject()) {

        // TODO: Research this.
        /* Workaround: sometimes SoundManager.js uses ._iO object to reproduce the audio, and other times uses the object returned by getSoundObject() directly */
        if (player.playlistController.getSoundObject()._iO != null && player.playlistController.getSoundObject()._iO &&
            player.playlistController.getSoundObject()._iO.url != null) {
            player.playlistController.getSoundObject()._iO.url = vURL;
        }
        if (player.playlistController.getSoundObject().url != null && player.playlistController.getSoundObject().url) {
            player.playlistController.getSoundObject().url = vURL;
        }
    }
}

function setVideoCurrent(event) {
    getClickPosition(event, event.data._duration, event.data._fileName);
}

function posRelativeToElement(elem, ev) {
    var $elem = $(elem),
        ePos = $elem.offset(),
        mousePos = {
            x: ev.pageX,
            y: ev.pageY
        };
    mousePos.x -= ePos.left + parseInt($elem.css('paddingLeft')) +
        parseInt($elem.css('borderLeftWidth'));
    mousePos.y -= ePos.top + parseInt($elem.css('paddingTop')) +
        parseInt($elem.css('borderTopWidth'));
    return mousePos;
};

function getClickPosition(e, duration, fileName) {
    var parentPosition = getPosition3(e.currentTarget);
    var xPosition = e.clientX - parentPosition.x;
    var yPosition = e.clientY - parentPosition.y;
    var sm2_progress_track_VIDEO = $("#sm2-progress-track_VIDEO");

    if (sm2_progress_track_VIDEO != null && sm2_progress_track_VIDEO.length) {
        var left_percentage = parseInt(xPosition / parseInt(sm2_progress_track_VIDEO.css("width"), 10) * 100, 10);
        var currentSecs = left_percentage * duration / 100;

        if (oldPlayer_activeElement_type === "S") {
            if (document.fbsviewer != null) {
                document.fbsviewer.seekViewerSeconds(currentSecs);
            }
        } else {
            // TODO: adapt to html5 video 

            if (oldPlayer_activeElement_type === "V") {

                // Get file extension
                var file_extension = getFileExtension(fileName);
                if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {
                    switch (file_extension[0]) {

                        // HTML5 support:
                        case "mp4":
                        case "webm":
                        case "ogg": {

                            var html_player = $("#html_video");
                            if (html_player != null && html_player[0] != null) {
                                try {
                                    html_player[0].currentTime = currentSecs;
                                } catch (err) {
                                    console.log("l:3203 Error seeking HTML5 Player");
                                    console.log(err);
                                }
                            }
                            break;
                        }

                        case "avi":
                        case "crypt":
                        case "bin":
                        default: {

                            if (getIsIE()) {

                                var video_player = $("#video_object1");
                                if (video_player != null && video_player[0] != null && video_player[0].controls != null) {
                                    video_player[0].controls.currentPosition = currentSecs;
                                }

                            } else {

                                // Webchimera Plugin Player or else:
                                try {
                                    if (wjs("#webchimera1") != null) {
                                        wjs("#webchimera1").time(currentSecs);
                                    }
                                } catch (err) {
                                    console.log("l:3221 Error seeking webchimera");
                                    console.log(err);
                                }

                            }

                            break;
                        }
                    } // switch file_extension
                }

            }
        }
    }
}
// Source: https://ckon.wordpress.com/2011/08/05/javascript-position-firefox/
// NOTE: Firefox / Chrome way 2

function XY(o) {
    var z = o,
        x = z.offsetLeft || 0,
        y = z.offsetTop || 0;
    while (z = z.offsetParent) {
        x += z.offsetLeft || 0;
        y += z.offsetTop || 0;
    }
    return {
        x: o.X = x,
        y: o.Y = y
    };
}

function getPosition2(element) {
    var xPosition = 0;
    var yPosition = 0;
    while (element) {

        // NOTE: Chrome way
        //xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
        //yPosition += (element.offsetTop - element.scrollTop + element.clientTop);

        // NOTE: Firefox / Chrome way 1
        xPosition += (XY(element).x - element.scrollLeft + element.clientLeft);
        yPosition += (XY(element).y - element.scrollTop + element.clientTop);
        element = element.offsetParent;
    }
    return {
        x: xPosition,
        y: yPosition
    };
}

function getPosition3(element) {
    var xPosition = 0;
    var yPosition = 0;
    while (element) {

        // NOTE: Chrome way
        xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
        yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
        element = element.offsetParent;

        // NOTE: Firefox / Chrome way 1
        //xPosition += (XY(element).x - element.scrollLeft + element.clientLeft);
        //yPosition += (XY(element).y - element.scrollTop + element.clientTop);
        //element = element.offsetParent;
    }
    return {
        x: xPosition,
        y: yPosition
    };
}

// Set VIDEO mask duration
function setVideoLength(duration) {

    // Set Video length
    // Get duration format: HH:mm:ss
    var duration_final = "";
    var duration_int = parseInt(duration, 10);
    if (duration_int > 0) {
        duration_final = getFormatDuration_short(duration);
    } else {
        duration_final = "N/A";
    }
    var duration_VIDEO = $("#sm2-inline-duration_VIDEO");
    if (duration_VIDEO != null && duration_VIDEO.length > 0) {
        duration_VIDEO.text(duration_final.toString());
    }
}

// Button play/pause actions
function ActionVideoPlay(tapeID, duration, isAudioPlaying) {
    var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");
    var aPlayPause_VIDEO = $("#aPlayPause_VIDEO");
    var divPlayer_VIDEO = $("#divPlayer_VIDEO");

    // Set duration
    setVideoLength(duration);
    if (aPlayPause_VIDEO != null && aPlayPause_VIDEO.length > 0 && divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {
        if (!isAudioPlaying) {

            // Event: Clear previous onclick events
            $("#aPlayPause_VIDEO").off("click");
            aPlayPause_VIDEO.bind("click", function () {
                console.log("click l: 2216");

                if (divControlsMask_VIDEO != null &&
                    divControlsMask_VIDEO.length > 0) {

                    // If is paused
                    if (divControlsMask_VIDEO.hasClass("paused")) {
                        divControlsMask_VIDEO.addClass("playing");
                        divControlsMask_VIDEO.removeClass("paused");
                        playVideo_ok = true;

                        // Set element Playing
                        setElementInMemoryIsPlaying(tapeID);
                        try {
                            if (document.fbsviewer != null) {
                                document.fbsviewer.play();
                                // Set div visible
                                divPlayer_VIDEO.css("visibility", "visible");

                                // Set fbs player init
                                document.fbsviewer.seekViewerSeconds(0);

                                previousSecs = 0;
                                playVideo_ok = true;
                                TimeRefreshLoop(duration);
                            }
                        } catch (err) {
                            console.log("l:3265 Error loading FBS Player");
                            console.log(err);
                        }
                    } else {
                        // If is playing
                        divControlsMask_VIDEO.addClass("paused");
                        divControlsMask_VIDEO.removeClass("playing");

                        try {
                            if (document.fbsviewer != null) {
                                document.fbsviewer.pause();
                            }
                        } catch (err) {
                            console.log("l:3278 Error loading FBS Player");
                            console.log(err);
                        }
                    }
                }
            });
        } else {
            // If it is playing audio
            if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {

                // If it is paused
                divControlsMask_VIDEO.addClass("playing");
                divControlsMask_VIDEO.removeClass("paused");
                playVideo_ok = true;

                // Set element Playing
                setElementInMemoryIsPlaying(tapeID);
                try {
                    if (document.fbsviewer != null) {
                        document.fbsviewer.play();
                        previousSecs = 0;
                        playVideo_ok = true;

                        // Set div visible
                        divPlayer_VIDEO.css("visibility", "visible");

                        TimeRefreshLoop(duration);
                    }
                } catch (err) {
                    console.log(err);
                }
            }
        }
    }
}
//#endregion
//#region JS Methods 4/5: clickTimelineElement1 | clickTimelineElement2 | removeDivPlayer | stopFBSPlayer | prepareTimelineReload | loadPlayerBoxImage

function emptyAudioPlayer() {
    var divControlsMask_AUDIO = $("#divControlsMask_AUDIO");
    if (divControlsMask_AUDIO != null && divControlsMask_AUDIO.length > 0) {
        // Button
        if (divControlsMask_AUDIO.hasClass("playing")) {
            divControlsMask_AUDIO.addClass("paused");
            divControlsMask_AUDIO.removeClass("playing");
        }
    }
}

function emptyVideoPlayer() {
    var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");
    if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {

        // Button
        if (divControlsMask_VIDEO.hasClass("playing")) {
            divControlsMask_VIDEO.addClass("paused");
            divControlsMask_VIDEO.removeClass("playing");
            playVideo_ok = false;
        }
    }

    // Pointer
    var pointer_VIDEO = $('#sm2-progress-ball_VIDEO');
    if (pointer_VIDEO != null) {
        pointer_VIDEO.css("left", 0);
    }
    stopFBSPlayer();
}

function videoPlayerINIT(fileName, duration, segmentID) {

    /******** player control STYLES ********/

    // Player chronos
    $("#sm2-inline-time_VIDEO").text("0:00");
    $("#sm2-inline-duration_VIDEO").text("0:00");

    // Set screen recording title
    $("#lblSoundTitle1_VIDEO, #lblSoundTitle2_VIDEO").text(fileName);

    // Remove player background image
    PLAYER_BOX.css("background-image", "");
    $("#divPlayer_VIDEO").css("visibility", "hidden");

    // p = 'http://192.168.20.225:8080/icweb/replay?segid=1'; // TEST !!

    // Toma resolución del div contenedor (PLAYER_BOX)
    playerBox_w = parseInt(PLAYER_BOX.css("width"), 10);
    playerBox_h = parseInt(PLAYER_BOX.css("height"), 10);

    var left_offset = 25;
    var top_offset = 6;
    var divWidth = playerBox_w - left_offset;
    var divHeight = playerBox_h - top_offset;

    var filePath_OREKA = WS_Oreka_Server + ":" + WS_Oreka_Port + WS_Oreka_URL + "?segid=" + segmentID;

    // filePath_OREKA = 'http://192.168.20.225:8080/icweb/replay?segid=1'; // TEST !!

    var applet = "<div id='fbsviewer1' style='padding-top: 10px;'>";
    applet += "<applet codebase='assets/applets/' code='OrkMP.class' archive='OrkMP.jar' width='" + divWidth + "px' height='" + divHeight + "px' name='fbsviewer' id='fbsviewer' title='undefined'>";
    applet += "<param name='HOST' value=''>";
    applet += "<param name='PORT' value='5901'>";
    applet += "<param name='FBSURL' value='" + filePath_OREKA + "'>";
    applet += "<param name='AUDIOURL' value=''>";
    applet += "<param name='SHOWPLAYERCONTROLS' value='YES'>";
    applet += "<param name='SHOWPLAYERTAGCONTROLS' value='YES'>";
    applet += "<param name='TIMECOUNTDOWN' value='NO'>";
    applet += "<param name='CACHE' value='NO'>";
    applet += "<param name='RESIZABLE' value='NO'>";
    applet += "<param name='TAGS' value=''>";
    applet += "<param name='QUICK_REWIND_SECS' value='-5'>";
    applet += "<param name='QUICK_ADVANCE_SECS' value='5'>";
    applet += "<param name='NOREC_TAGTYPE_NAME' value='Pause'>";
    applet += "</applet></div>";

    $("#divPlayer_VIDEO applet").remove();
    $("#divPlayer_VIDEO").append(applet);

    // Stop FBS player if it is playing
    //stopFBSPlayer();
    try {
        if (document.fbsviewer != null) {
            document.fbsviewer.pause();
        }
    } catch (err) {
        console.log("l:3403 Oreka Player (.fbs) error try catch");
        console.log(err);
    }

    // FBS Player init
    previousSecs = 0;
    playVideo_ok = true;

    // Inicia FBS player para pre-cargar
    //TimeRefreshLoop(duration); 
}

// Called from client side

function clickTimelineElement1(tapeID, count, duration, timestamp, type_longStr, segmentID, isExtra, fileName, filePath,
    duration_formatStr, event, tapeType, fileStatus) {
    paintSelectionClick(tapeID, timestamp);
    loadElementPlayer(tapeID, count, duration, timestamp, type_longStr, segmentID, isExtra, fileName, filePath, duration_formatStr,
        tapeType, fileStatus);
}
// Called from server side

function clickTimelineElement2(tapeID, count, duration, timestamp, type_longStr, segmentID, isExtra, fileName, filePath,
    duration_formatStr, tapeType, fileStatus) {
    paintSelectionClick(tapeID, timestamp);
    loadElementPlayer(tapeID, count, duration, timestamp, type_longStr, segmentID, isExtra, fileName, filePath, duration_formatStr,
        tapeType, fileStatus);
}

function removeDivPlayer() {

    // VIDEO
    // Clear player control settings
    $("#lblSoundTitle1_VIDEO, #lblSoundTitle2_VIDEO").text("");
    $("#lnkSound_VIDEO").attr("href", "");
    $("#sm2-inline-time_VIDEO").text("0:00");
    $("#sm2-inline-duration_VIDEO").text("0:00");

    // AUDIO
    // Clear player control settings
    $("#lblSoundTitle1_AUDIO, #lblSoundTitle2_AUDIO").text("");
    $("#lnkSound_AUDIO").attr("href", "");
    $("#sm2-inline-time_AUDIO").text("0:00");
    $("#sm2-inline-duration_AUDIO").text("0:00");

    soundManager.stopAll()

    var sound_player = window.sm2BarPlayers[1];
    if (sound_player != null && soundManager != null) {
        sound_player.actions.stop();
        sound_player.dom.progress.style.left = "0%";
        sound_player.dom.progressBar.style.width = "0%";
    }

    // Right side info panel
    $("#lblType").val("");
    $("#lblName").val("");
    $("#lblTimestamp").val("");
    $("#lblDuration").val("");
    $("#lblStatus").val("");
}

function stopFBSPlayer() {
    var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");

    // Set pause icon
    divControlsMask_VIDEO.addClass("paused");
    divControlsMask_VIDEO.removeClass("playing");
    try {
        if (document.fbsviewer != null) {
            document.fbsviewer.pause();
        }
    } catch (err) {
        console.log("l:3481 Oreka Player (.fbs) error try catch");
        console.log(err);
    }
}

function prepareTimelineReload(timel) {

    // Refresh max and min dates, timeline limits
    max = new Date(-100000000 * 86400000);
    min = new Date(100000000 * 86400000);
    traverse(timel.spans, compare);

    // **** DRAW TIMELINE ****
    timeframe_draw(timel, _TL_STARTDATE, _TL_ENDDATE);

    // Source: http://stackoverflow.com/questions/7718770/finding-max-min-date-in-multidimensional-javascript-object
}

function loadPlayerBoxImage(image_path) {
    if (PLAYER_BOX != null && PLAYER_BOX.length) {
        PLAYER_BOX.css("background-image", image_path);
        PLAYER_BOX.css("background-repeat", "no-repeat");
        PLAYER_BOX.css("background-position", "center");
        PLAYER_BOX.css("background-size", "250px 250px");
    }
    $("#imgPlayer").hide();
}
//#endregion 
//#region JS Methods 5: removeDivPlayerContentExcept | manageElement | compare | traverse | TimeRefreshLoop | playAudioElement | tickAction

function removeDivPlayerContentExcept() {
    // if the fbs player is active, stop it
    try {
        if (document.fbsviewer != null) {
            document.fbsviewer.pause();
        }
    } catch (err) {
        console.log(err);
    }
}
/******** Method: Element Click - Click on left grid individual elements ********/

function manageElement(caller, tapeID, index, json_element) {
    if ($(caller).parent().parent().is(":visible")) { // Only if row is visible
        $("#timeframe").empty(); // Clean div content
        var timeline_data = _TL_DATA; // Copy original timeline elements as reference
        var checked = $(caller).prop('checked');
        if (checked) {
            // Add element to timeline
            timeline_data.spans.push(json_element);
        } else {
            if (timeline_data.spans != null && timeline_data.spans.length > 0) {
                timeline_data.spans = $.grep(timeline_data.spans,
                    function (item, index) {
                        return item.id != tapeID;
                    });
            }
        }
        prepareTimelineReload(timeline_data);
    }
}
/* ************* Gets the min and max dates in a json object ************* */

function compare(key, value) {
    if (key == "start" || key == "end") {
        var date_str = value.toString();
        var value_date = moment(date_str, "DD-MM-YYYY HH:mm:ss");

        if (key == "start" && value_date < min) {
            _TL_STARTDATE = value;
            min = value_date;
        } else if (key == "end" && value_date > max) {
            _TL_ENDDATE = value;
            max = value_date;
        }
    }
}
/* ************* Loops over the keys in a json object ************* */

function traverse(obj, fun) {
    for (prop in obj) {
        fun.apply(this, [prop, obj[prop]]);
        if (typeof (obj[prop]) == "object") {
            traverse(obj[prop], fun);
        }
    }
}
/* ************* FBS Player settings ************* */

function TimeRefreshLoop(totalDurationSecs) {
    {
        var timer_VIDEO = $('#sm2-inline-time_VIDEO');
        var pointer_VIDEO = $('#sm2-progress-ball_VIDEO');
        var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");

        if (document.fbsviewer != null) {

            try{
                var currentSecs = document.fbsviewer.getCurrTimeOffsetInMSec() / 1000;

                //Si supero los segundos totales, o detecto que el tiempo fue para atras, asumo que termino y dejo de refrecar
                if (currentSecs < totalDurationSecs && currentSecs >= previousSecs) { // && currentSecs != 0) {

                    //if (currentSecs <= totalDurationSecs && currentSecs >= previousSecs && currentSecs !=0) {
                    previousSecs = currentSecs;

                    var left = Math.round(100 * currentSecs / totalDurationSecs) + "%";
                    var secs_int = parseInt(currentSecs, 10);
                    var timer = getTime(document.fbsviewer.getCurrTimeOffsetInMSec(), true).toString();

                    timer_VIDEO.text(timer);

                    // Pointers progress
                    pointer_VIDEO.css("left", left);

                    //divControlsMask_VIDEO.addClass("playing");
                    playVideo_ok = true;
                    setTimeout(function () {
                        TimeRefreshLoop(totalDurationSecs)
                    }, 1000);

                    // doTimeout Source: http://benalman.com/code/projects/jquery-dotimeout/examples/delay-poll/
                }
            } catch (err) {
                console.log("l:3842 Error getCurrTimeOffsetInMSec fbsviewer");
                console.log(err);
            }
        } else {
            // Si terminó
            //divControlsMask_VIDEO.addClass("paused");
            playVideo_ok = false;
            if (pointer_VIDEO != null) {
                pointer_VIDEO.css("left", "0%");
            }
        }
    }
}
var myTimer;

function playAudioElement(event) {
    var divSoundPlayer = $("#divControlsMask_AUDIO");
    if (divSoundPlayer != null && divSoundPlayer.length > 0) {
        if (divSoundPlayer.hasClass("playing")) {

            // Set element Playing
            setElementInMemoryIsPlaying(event.data._tapeID);

        } else {
            clearInterval(myTimer);
        }
    }
}

function addFileClick() {

    // Check if folio is selected
    var _hdnFolioID = $("input[id*='_hdnFolioID']");
    if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {

        if (!$('#btnUploadElement').hasClass("opened")) {
            var posXoff = $("#btnUploadElement").offset().left;
            var posYoff = $("#btnUploadElement").offset().top + 60;

            var date_str = moment(currentPointerPositionDate_str, "DD-MM-YYYY HH:mm:ss");

            $("#divUpload input[id*='uploadDate']").val(date_str.format('DD-MM-YYYY HH:mm:ss'));
            $("#divCamaras input[id*='camarasDate1']").val(date_str.format('DD-MM-YYYY HH:mm:ss'));
            $("#divCamaras input[id*='camarasDate2']").val(date_str.format('DD-MM-YYYY HH:mm:ss'));

            // Hide other popups
            $(".box.popbox").hide();

            // Popup styles
            $('.popbox2').popbox2();
            $(".box2.popbox2").show("highlight", 700);

            var pop_w = parseInt($(".box2.popbox2").css("width"), 10);
            var arrow_w = parseInt($(".box2.popbox2 .arrow").css("width"), 10);
            var btn_w = parseInt($("#btnAddComment").css("width"), 10);

            $(".box2.popbox2").offset({ left: posXoff - pop_w + (btn_w / 2) + (arrow_w / 2) });
            $(".box2.popbox2 .arrow").css("left", (pop_w - arrow_w - 3) + "px");
            $(".box2.popbox2 .arrow-border").css("left", (pop_w - arrow_w - 3) + "px");

            $(".box2.popbox2").offset({ top: posYoff });
            $('#btnUploadElement').addClass("opened");
        } else {
            $(".box2.popbox2").hide(200);
            $('#btnUploadElement').removeClass("opened");
        }

    } else {
        $("#dialog p").text(hashMessages["SeleccioneFolio"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
    }
}

//#endregion 
//#region JS Methods 6: showHideLeftPanel | callback1 | callback2 | callback3 | getElementsInMemory | getElementInMemoryByID | getElementInMemoryByTimeRange    

// Shows or hides left panel Busqueda
function showHideLeftPanel() {
    var divPanel_Busqueda = $('#divPanel_Busqueda');
    var divPanel_PlayerControl = $("#divPanel_PlayerControl");
    if (divPanel_Busqueda != null && divPanel_Busqueda.length &&
        divPanel_PlayerControl != null && divPanel_PlayerControl.length) {
        if (divPanel_Busqueda.is(":visible")) {
            divPanel_Busqueda.hide("slide", {
                direction: "left"
            }, 300, callback1);
        } else {
            divPanel_PlayerControl.animate({
                width: '60%'
            }, 200, callback2);
        }
    }
}
//callback function to bring a hidden box back

function callback1() {
    setTimeout(function () {
        var divPanel_PlayerControl = $("#divPanel_PlayerControl");
        if (divPanel_PlayerControl != null &&
            divPanel_PlayerControl.length) {
            divPanel_PlayerControl.animate("size", {
                width: '100%'
            }, 300);
        }
    }, 10);
};

function callback2() {
    setTimeout(function () {
        var divPanel_PlayerControl = $("#divPanel_PlayerControl");
        var divPanel_Busqueda = $('#divPanel_Busqueda');
        if (divPanel_Busqueda != null && divPanel_Busqueda.length) {
            //divPanel_PlayerControl.css('width', '96%');
            divPanel_Busqueda.show("slide", {
                direction: "left"
            }, 400, callback3);
        }
    }, 10);
};
//callback function to bring a hidden box back
function callback3() {
    setTimeout(function () {
        var divPanel_PlayerControl = $("#divPanel_PlayerControl");
        if (divPanel_PlayerControl != null &&
            divPanel_PlayerControl.length) {
            divPanel_PlayerControl.animate("size", {
                width: initial_size
            }, 300);
        }
    }, 10);
};

function downloadAll() {

    // Check if folio is selected
    var _hdnFolioID = $("input[id*='_hdnFolioID']");
    if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {

        // Get only visible and checked checkboxes to remove
        var list_elements = [];
        $('tr:visible td input:checked').each(function () {
            list_elements.push($(this).attr('value'));
        });
        if (list_elements.length > MAX_DOWNLOAD_FILES) {

            var msj = hashMessages["MaximoElementosDescarga1"] + " " + MAX_DOWNLOAD_FILES + " " + hashMessages["MaximoElementosDescarga2"];
            $("#dialog p").text(msj);
            $("#dialog").dialog({
                buttons: {
                    "Confirmar": function () {
                        $(this).dialog("close");
                    }
                }
            });

        } else if (list_elements.length > 0) {

            $("#dialog p").text(hashMessages["ConfirmarDesgargaElementos"]);
            $("#dialog").dialog({
                resizable: false,
                height: 140,
                modal: true,
                buttons: {
                    "Confirmar": function () {
                        multiDownload(list_elements);
                        $(this).dialog("close");
                    },
                    Cancel: function () {
                        $(this).dialog("close");
                    }
                },
                close: function (event, ui) {
                    //$(this).dialog('destroy').remove()
                }

            });

        } else if (list_elements.length == 0) {

            $("#dialog p").text(hashMessages["SeleccioneElemento"]);
            $("#dialog").dialog({
                buttons: {
                    "Confirmar": function () {
                        $(this).dialog("close");
                    }
                }
            });

        }
    } else {
        $("#dialog p").text(hashMessages["SeleccioneFolio"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
    }
}

/******** Auxiliar Functions ********/

function getDuration_onDatetime(date){

    var duration = 0;
    if (date != null) {
        var date_str1 = moment(_TL_STARTDATE, "DD-MM-YYYY HH:mm:ss");
        var date_str2 = moment(date, "DD-MM-YYYY HH:mm:ss");
        var date1 = new Date(date_str1);
        var date2 = new Date(date_str2);

        var dif = date2.getTime() - date1.getTime();

        var Seconds_from_T1_to_T2 = dif / 1000;
        duration = Math.abs(Seconds_from_T1_to_T2);
    }
    return duration;
}

function getDatetime_onPointerPosition(){
    var position_date_str = null;
    var posX = parseFloat(TIMELINE_POINTER.css("left"), 10);

    // Datetime position 
    var position_date = window.timeframe_live.getTickDate(posX + window.timeframe_live.paddingX);
    if (position_date != null) {
        position_date_str = moment(position_date, "YYYY-MM-DD HH:mm:ss");
    }
    return position_date_str;
}


// Get duration format in ms for timeouts
function getDurationInMS(duration) {
    return duration * 1000;
}

// Get duration format: HH:mm:ss
function getFormatDuration(duration) {
    return moment("2015-01-01").startOf('day').seconds(duration).format('HH:mm:ss');
}

// Get duration format: m:ss
function getFormatDuration_short(duration) {
    return moment("2015-01-01").startOf('day').seconds(duration).format('m:ss');
}

// Get file extension
function getFileExtension(fileName) {
    return (/[.]/.exec(fileName)) ? /[^.]+$/.exec(fileName) : undefined;
}

// Get variable object type
function type(o) {
    return TYPES[typeof o] || TYPES[TOSTRING.call(o)] || (o ? 'object' : 'null');
};

function multiDownload(objects) {
    for (obj in objects) {
        if (objects[obj] != null && objects[obj].length) {
            var array = objects[obj].split("#");
            if (array != null && array.length > 2) {
                var segmentID = array[0];
                var isExtra = array[1];
                var mediaType = array[2];
                if (mediaType != "C") {
                    var filePath_str = "";

                    if (isExtra != null && isExtra.length > 0) {
                        var isExtra_str = isExtra.toString();
                        if (isExtra_str.toLowerCase() === "true") {

                            filePath_str = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=1";

                        } else {

                            filePath_str = WS_Oreka_Server + ":" + WS_Oreka_Port + WS_Oreka_URL + "?segid=" + segmentID;
                        }
                        $("#aDownloader").attr("href", filePath_str);
                        $("#aDownloader")[0].click();
                        sleep(1000);
                    }
                }
            }
        }
    }
}

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds) {
            break;
        }
    }
}

// Show if it is Firefox or IE (10 and 11) browser
function getIsFirefoxOrIE() {
    var msie = -1;
    var ua = navigator.userAgent.toLowerCase();
    if (ua != null && ua.length) {
        msie = ua.toLowerCase().indexOf("msie ");
    }
    return (ua.indexOf('firefox') > -1 || msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./));
}

// Show if it is IE (10 and 11) browser
function getIsIE() {
    var ua = navigator.userAgent.toLowerCase();
    var msie = ua.toLowerCase().indexOf("msie ");

    return (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./));
}

// convert milliseconds to HH:mm:ss, return as object literal or string
function getTime(msec, useString) {
    var nSec = Math.floor(msec / 1000),
        hh = Math.floor(nSec / 3600),
        min = Math.floor(nSec / 60) - Math.floor(hh * 60),
        sec = Math.floor(nSec - (hh * 3600) - (min * 60));
    // if (min === 0 && sec === 0) return null; // return 0:00 as null
    return (useString ? ((hh ? hh + ':' : '') + (hh && min < 10 ? '0' +
        min : min) + ':' + (sec < 10 ? '0' + sec : sec)) : {
            'min': min,
            'sec': sec
        });
}

// Load elements from folio selected - Get data from server
function getElementsInMemory() {
    var hdnElements = $("input[id*='_hdnTapeID_RoleGroupName_TypeTapeType_duration_timestamp_segmentID_count_fileName_endDate_filePath_duration_formatStr_fileStatus']").val();
    if (hdnElements != null && hdnElements.length) {
        var tapes_array = hdnElements.split("$"); // Elements
        if (tapes_array.length > 0) {

            elementsInMemory = [];
            globalplay_stack_elements = [[], []]; // [object, already_taken: bool]

            for (var i = 0; i < tapes_array.length; i++) {
                if (tapes_array[i] != null) {
                    var tape_values = tapes_array[i].split("#"); // Element attributes
                    if (tape_values.length > 11) {
                        var tapeID = tape_values[0];
                        var groupName = tape_values[1];
                        var tapeType = tape_values[2];
                        var duration = tape_values[3];
                        var timestamp = tape_values[4];
                        var segmentID = tape_values[5];
                        var count = tape_values[6];
                        var fileName = tape_values[7];
                        var endDate = tape_values[8];
                        var filePath = tape_values[9];
                        var duration_formatStr = tape_values[10];
                        var fileStatus = tape_values[11];

                        var element = {
                            tapeID: tapeID,
                            groupName: groupName,
                            tapeType: tapeType,
                            duration: duration,
                            timestamp: timestamp,
                            segmentID: segmentID,
                            count: count,
                            fileName: fileName,
                            endDate: endDate,
                            filePath: filePath,
                            duration_formatStr: duration_formatStr,
                            isPlaying: "false",
                            fileStatus: fileStatus
                        };
                        elementsInMemory.push(element);

                        var element_alreadyTaken = new Array();
                        element_alreadyTaken[0] = element;
                        element_alreadyTaken[1] = false; // AlreadyTaken false
                        globalplay_stack_elements.push(element_alreadyTaken);
                    }
                }
            }
        }
    }
}

function getElementInMemoryByID(elementID) {
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        for (var i = 0; i < elementsInMemory.length; i++) {
            var element = elementsInMemory[i];
            if (element != null) {
                if (element.tapeID == elementID) {
                    return element;
                }
            }
        }
    }
}

function setAllElementsInMemoryNotPlaying() {
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        for (var i = 0; i < elementsInMemory.length; i++) {
            var element = elementsInMemory[i];
            if (element != null) {
                element.isPlaying = "false";
            }
        }
    }
}

function setElementInMemoryIsPlaying(tapeID) {
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        for (var i = 0; i < elementsInMemory.length; i++) {
            var element = elementsInMemory[i];
            if (element != null) {
                if (element.tapeID === tapeID) {
                    element.isPlaying = "true";
                }
            }
        }
    }
}

// Get elements in range of the current playing element
function getElementInMemoryByTimeRange(originalID, timeStart, timeCurrent) {
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        var array = elementsInMemory.filter(function (el) {
            return (el.tapeType === 'S' || el.tapeType === 'A') && el.tapeID != originalID && el.isPlaying === "false" &&
                moment(el.timestamp, "DD-MM-YYYY HH:mm:ss").toDate() >= timeStart &&
                moment(el.timestamp, "DD-MM-YYYY HH:mm:ss").toDate() <= timeCurrent;
        });
        return array;
    }
}

// Only visible elements in timeline and not of the same media type
function getElementInMemoryByTimeRange_onlyVisibleInTimeline(originalID, timeStart, timeCurrent) {
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        var element_caller = getElementInMemoryByID(originalID);
        if (element_caller != null) {
            var array = elementsInMemory.filter(function (el) {
                return (el.tapeType === 'S' || el.tapeType === 'A' || el.tapeType === 'V') && el.tapeType != element_caller.tapeType && el.tapeID != originalID && el.isPlaying === "false" &&
                    moment(el.timestamp, "DD-MM-YYYY HH:mm:ss").toDate() >= timeStart &&
                    moment(el.timestamp, "DD-MM-YYYY HH:mm:ss").toDate() <= timeCurrent &&
                    $("#tlTape_" + el.tapeID).length > 0;
            });
        }
        return array;
    }
}

function getElementInMemoryByTimeRangeAux(current_date) {
    if (elementsInMemory != null && elementsInMemory.length > 0) {
        var array = elementsInMemory.filter(function (el) {
            var end1 = moment(el.timestamp, "DD-MM-YYYY HH:mm:ss");
            end1.add(el.duration, "seconds");
            return (el.tapeType === 'S' || el.tapeType === 'A') &&
                current_date >= moment(el.timestamp, "DD-MM-YYYY HH:mm:ss").toDate() &&
                end1.toDate() >= current_date;
        });
        return array;
    }
}


function getElementInMemoryByType(elementType) {
    if (elementsInMemory != null && elementsInMemory.length > 0 && elementType != null && elementType.length > 0) {
        var array = elementsInMemory.filter(function (el) {
            return el.tapeType === elementType.toUpperCase();
        });
        return array;
    }
}

// Hidden Field hdnIsUpdateNeeded: alerts if is needed a data refresh from code behind
// A: Normal file upload
function prepareFileUpload_a(e) {
    var _hdnIsUpdateNeeded = $("#_hdnIsUpdateNeeded");
    if (_hdnIsUpdateNeeded != null) {
        _hdnIsUpdateNeeded.val("true");
    }

    var _hdnFolioID_selected = $("#_hdnFolioID_selected");
    if (_hdnFolioID_selected != null) {
        var checked_folio = $("#divFolioSelection_fileUpload input:radio[name='rbFolios_fileUpload']:checked").val();
        if (checked_folio != null && checked_folio.length) {
            _hdnFolioID_selected.val(checked_folio);
        }
    }

    if (_hdnFolioID_selected == null || _hdnFolioID_selected.val() == null || _hdnFolioID_selected.val().length == 0) {

        $("#dialog p").text(hashMessages["SeleccioneFolioID"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
        if (e) {
            e.preventDefault();
        }
    }

    var MyFileUpload = $("#divUpload input[id*='MyFileUpload']");
    if (MyFileUpload != null && (MyFileUpload.val() == null || MyFileUpload.val().length == 0)) {

        $("#dialog p").text(hashMessages["SeleccioneArchivo"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
        if (e) {
            e.preventDefault();
        }
    }
}

// B: Camera system upload
function prepareFileUpload_b(e) {
    var _hdnIsUpdateNeeded = $("#_hdnIsUpdateNeeded");
    if (_hdnIsUpdateNeeded != null) {
        _hdnIsUpdateNeeded.val("true");
    }
    var txbInputCameraNumber = $("#divCamaras input[id*='txbInputCameraNumber']");
    if (txbInputCameraNumber != null && txbInputCameraNumber.val().length == 0) {

        $("#dialog p").text(hashMessages["IngreseNumeroCamara"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
        txbInputCameraNumber.focus();
        e.preventDefault();
    }
}
//#endregion 

function confirmAddComment() {
    var userID = globalUserID;

    // Check if folio is selected
    var folioID = "";
    var _hdnFolioID = $("input[id*='_hdnFolioID']");
    if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {

        var checked_folio = $("#divFolioSelection_addComment input:radio[name='rbFolios_addComment']:checked").val();
        if (checked_folio != null && checked_folio.length) {
            folioID = checked_folio;
        }
    }

    var comment = $("#txbComment").val();
    var date = $("#commentDate").val();
    var duration = $("#sliderSingle1").val();

    // Disable element in memory elements 
    if ($("#_hdnIsUpdateNeeded") != null) {
        $("#_hdnIsUpdateNeeded").val("true");
    }
    if (userID != null && userID != "" && comment != null && comment != "" && date != null && date != "" && duration != null && duration != "" && folioID != null && folioID != "") {

        console.log("Ajax call: Dashboard.aspx/AddFolioComment. Params:");
        console.log("userID: " + userID + ", type: " + type(userID));
        console.log("comment: " + comment + ", type: " + type(comment));
        console.log("date: " + date.toString() + ", type: " + type(date));
        console.log("duration: " + duration.toString() + ", type: " + type(duration));
        console.log("End Ajax call");

        $.ajax({
            type: "POST",
            url: "Dashboard.aspx/AddFolioComment",
            data: '{userID: "' + userID + '", folioID: "' + folioID + '", comment: "' + comment + '", date: "' + date + '", duration: "' + duration + '"}',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var timeline_data = _TL_DATA; // Copy original timeline elements as reference
                if (timeline_data != null) {

                    // Retrieve the new comment
                    var _hdnIsUpdateNeeded = $("#_hdnIsUpdateNeeded");
                    if (_hdnIsUpdateNeeded != null &&
                        _hdnIsUpdateNeeded.length) {
                        _hdnIsUpdateNeeded.val("true");
                    }
                    var json_object = JSON.parse(response.d);
                    var object = {
                        count: timeline_data.spans.length + 1,
                        duration: json_object.duration,
                        duration_formatStr: getFormatDuration(json_object.duration), // new
                        endDate: json_object.end, //"24-10-2015 01:00:01"
                        fileName: json_object.name,
                        filePath: "",
                        groupName: "",
                        segmentID: json_object.id,
                        tapeID: json_object.id,
                        tapeType: "C",
                        timestamp: json_object.start,
                        isPlaying: "false",
                        fileStatus: "OK"
                    };
                    var username = globalUserName;

                    // Create new row to HTML table
                    var tr = "<tr id='tape_" + object.tapeID + "' style='background-color:rgb(187, 226, 217);' name='Extra'>";
                    tr += "<td>";
                    tr += "<input type='checkbox' name='timeline_elements' class='button' value='" + object.tapeID + "#true#C' checked>"; //onclick='manageElement(this, " + object.tapeID + ", " + (index - 1).toString() + ", " + JsonConvert.SerializeObject(json_element) + ")' checked>";
                    tr += "<td>";
                    tr += "<h5>" + object.count + "</h5>";
                    tr += "<td>";
                    tr += "<h5>" + username + "</h5>";
                    tr += "<td>";
                    tr += "<h5>" + "" + "</h5>";
                    tr += "<td>";
                    tr += "<h5>" + "" + "</h5>";
                    tr += "<td>";
                    tr += "<button type='button' class='btn btn-default btn-sm' style='color:orange; opacity: 0.9; background-color: beige; background-image: none;' name='btnTimelineElement' data-toggle='tooltip' ";
                    tr += "title='C' onclick='clickTimelineElement2(\"" + object.tapeID + "\", \"" + object.count + "\", \"" + object.duration + "\", \"" + object.timestamp.toString("dd'-'MM'-'yyyy HH':'mm':'ss") + "\", \"Comentario\", \"" + object.tapeID + "\", \"true\", \"" + object.fileName + "\", \"" + object.filePath + "\", \"" + object.duration_formatStr + "\", \"C\", \"OK\"" + ")' ><span class='glyphicon glyphicon-comment' aria-hidden='true'></span></button>";
                    tr += "<td>";
                    tr += "<h5 id='timestamp'>" + object.timestamp.toString("dd'-'MM'-'yyyy HH':'mm':'ss") + "</h5>";
                    tr += "<td>";
                    tr += "<h5>" + object.duration_formatStr + "</h5>";
                    tr += "</tr>";

                    // Add object to Html Table
                    $("#tblLeftGridElements tbody").append(tr);

                    // Update elements count
                    $("#divPanel_Busqueda span[id*='lblResultsCount']").text($("#tblLeftGridElements tr[id*='tape_']:visible").length.toString());

                    // Add object to elements list
                    elementsInMemory.push(object);

                    // Add object to timeline
                    timeline_data.spans.push(json_object);

                    // Re draw timeline
                    timeframe_draw(timeline_data, _TL_STARTDATE, _TL_ENDDATE);

                    // force to close popup
                    $(".box.popbox").hide();
                }

                console.log("Ajax call: Dashboard.aspx/AddFolioComment. Status: Success");

            }, // end success
            failure: function (response) {

                console.log("Ajax call: Dashboard.aspx/AddFolioComment. Status: Failure");
                //alert(response.d);
            }
        });

        $("#dialog p").text(hashMessages["ComentarioGuardado"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
    }
    else {
        $("#dialog p").text(hashMessages["SeleccioneFolioID"]);
        $("#dialog").dialog({
            buttons: {
                "Confirmar": function () {
                    $(this).dialog("close");
                }
            }
        });
    }
}
/******** Event: Enter Key listener ********/

