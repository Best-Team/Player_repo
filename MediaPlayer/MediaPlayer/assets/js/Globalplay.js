
/******** START: Media Player 2.0: Nuevo Requerimiento: Global Play ********/


var globalplay_queue_elements = [[], [], []];
var global_numberID = 0;

// Globalplay initialize
function globalplay_init() {

    // Hide Video player box
    $("#divPlayer_VIDEO").css("visibility", "hidden");

    if ($("#globalplay_play").hasClass("globalplay_play")) {

        // Load globalplay initial events
        globalplay_loadEvents();

        /***************** DO PLAY *****************/
        $("#globalplay_play").removeClass("globalplay_play");
        $("#globalplay_play").addClass("globalplay_pause");

        if (GLOBALPLAY_seconds_current == 0) {

            /********** START PLAY CASE **********/

            // Clean timer
            $('#divGlobalplay_timer').timer('remove');

            // Datetime position 
            var lblGlobalplay_timer_current_longFormat = getDatetime_onPointerPosition();
            var actual_duration = getDuration_onDatetime(lblGlobalplay_timer_current_longFormat)

            // Start timer
            $('#divGlobalplay_timer').timer({
                format: '%H:%M:%S',
                seconds: actual_duration
            });

            GLOBALPLAY_seconds_current = actual_duration;


            // Filter elements checked on left grid
            globalplay_filterElementsChecked();
        }
        else {
            /********** RESUME CASE **********/

            // Resume timer
            $('#divGlobalplay_timer').timer('resume');

            // Resume globalplay current paused elements
            globalplay_resumeAllCurrentMedia();
        }

        globalplay_start();

        // If Fancybox is closed, open it
        var fancybox = $(".fancybox-wrap")[0];
        if (fancybox == null) {

            // Open fancybox - DO CLICK
            $("#btnOpenFancybox").click();

            // Show overlay
            $("#fade").show();

            // Load info labels
            loadGlobalplay_settings();
        }

    } else {

        /***************** DO PAUSE *****************/
        $("#globalplay_play").removeClass("globalplay_pause");
        $("#globalplay_play").addClass("globalplay_play");

        // Stop timer
        $('#divGlobalplay_timer').timer('pause');

        // Stop timer 
        globalplay_playback_active = false;

        // Pause all media current playing elements
        globalplay_pausePlayingElements(false);

    }
    return false;
}


// Stopeable timer
var timer_globalplay = 0;
function globalplay_start() {
    globalplay_playback_active = true;
    var w = $("#divTimelineProgress").css("width");
    $("#sm2-progress-track").css("width", w);

    // Init event while playing if GLOBALPLAY_seconds_total is already loaded
    if (GLOBALPLAY_seconds_total > 0) {

        if (timer_globalplay === 0) {
            // Little delay to begin
            setTimeout(function () { timer_globalplay = setInterval(globalplay_whilePlaying, 100); }, 100); 
        }
    }

    // Enable right side Player box
    $("#divPanel_PlayerControl").removeClass("disabled");
}


// EVENT: Whileplaying globalplay timeline
function globalplay_whilePlaying() {
    if (!globalplay_playback_active) return;

    // Remove elements from DOM on globalplay screen 
    globalplay_removeElementsFromPlayback();

    // Load elements in this pointer position
    globalplay_loadElements();

    // Timer Source: http://jquerytimer.com/

    // Update global variable: current timer
    GLOBALPLAY_seconds_current = $("#divGlobalplay_timer").data('seconds');

    // Update current timer label
    $("#lblGlobalplay_timer_current").text($("#divGlobalplay_timer").text());

    var progress_percentage = GLOBALPLAY_seconds_current * 100 / GLOBALPLAY_seconds_total;
    var left_final_percentage = progress_percentage + '%';

    // If it is still in range 
    if (progress_percentage <= 100) {

        // Move pointer 
        TIMELINE_POINTER.css("left", left_final_percentage);

        // Update current timer label
        var date_str2 = moment(_TL_ENDDATE, "DD-MM-YYYY HH:mm:ss");
        $("#lblGlobalplay_timer_total_longFormat").text(date_str2.format('DD-MM-YYYY HH:mm:ss'));

        // Datetime position 
        var lblGlobalplay_timer_current_longFormat = getDatetime_onPointerPosition();
        if (lblGlobalplay_timer_current_longFormat != null) {
            $("#lblGlobalplay_timer_current_longFormat").text(lblGlobalplay_timer_current_longFormat.format('DD-MM-YYYY HH:mm:ss'));
        }

    } else {
        // Pointer arrived to the end

        // Stop timer 
        globalplay_abort();
    }
}

// Load elements in this current pointer position
function globalplay_loadElements() {

    // Search elements in current playtime
    var elementsCandidate = getElementInMemoryByCurrentPlayingTime();
    if (elementsCandidate != null && elementsCandidate.length > 0) {

        // Get visual elements already added in globalplay player
        var visual_size = globalplay_resizeAlreadyAdded(elementsCandidate);

        // Set label elements on play
        $("#lblGlobalplay_element_count").text(elementsCandidate.length);

        // Prepare URL elements to reproduce
        var filePath_EXTRA = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download;
        var filePath_OREKA = WS_Oreka_Server + ":" + WS_Oreka_Port + WS_Oreka_URL;

        // globalplay box container
        var flex_div = $("#divgp_sc .flex");

        var id_list = "";
        for (var i = 0; i < elementsCandidate.length; i++) {
            var element_alreadyTaken = elementsCandidate[i];
            if (element_alreadyTaken != null) {

                global_numberID++;

                // Set id_list label
                id_list = id_list + element_alreadyTaken[0].tapeID + "(" + element_alreadyTaken[0].tapeType + "), ";
                $("#lblGlobalplay_element_ids").text(id_list);

                var current_duration = GLOBALPLAY_seconds_current;
                var timeCurrent = moment(_TL_STARTDATE, "DD-MM-YYYY HH:mm:ss");
                timeCurrent.add(current_duration, "seconds");

                var duration_int = parseInt(element_alreadyTaken[0].duration, 10);
                var element_end = moment(element_alreadyTaken[0].timestamp, "DD-MM-YYYY HH:mm:ss");
                element_end.add(duration_int, "seconds");

                // Si el elemento no fue procesado, hacerlo *IMPORTANTE*
                if (element_alreadyTaken[1] == false) {
                    globalplay_setElementAlreadyTaken(element_alreadyTaken[0].tapeID, true);

                    var segmentID = element_alreadyTaken[0].segmentID;
                    var tapeType = element_alreadyTaken[0].tapeType;
                    var isVisual = (tapeType == "V" || tapeType == "S" || tapeType == "I") ? true : false;
                    /*
                    A: Audio
                    V: Video
                    S: Screen recording
                    I: Image
                    D: Document
                    C: Comment
                    */

                    // IsExtra = If filePath is NOT empty, then is extra from incextras table
                    var isExtra = element_alreadyTaken[0].filePath.length == 0 ? false : true;

                    // Prepare URL elements
                    var path_extra = filePath_EXTRA + "?id=" + element_alreadyTaken[0].segmentID + "&isExtra=1";
                    var path_oreka = filePath_OREKA + "?segid=" + element_alreadyTaken[0].segmentID;

                    // SET Element file path
                    var file_url = isExtra ? path_extra : path_oreka;

                    // Get if element is starting on seek
                    var element_current_duration = 0;
                    var element_start_duration = getDuration_onDatetime(element_alreadyTaken[0].timestamp);
                    if (element_start_duration != null && GLOBALPLAY_seconds_current > element_start_duration) {
                        element_current_duration = GLOBALPLAY_seconds_current - element_start_duration;
                    }

                    var dynamic_id = "";
                    var audio_object = null;

                    switch (tapeType) {
                        case "A": {
                            audio_object = globalplay_audio(file_url, element_alreadyTaken, global_numberID, flex_div, element_current_duration);
                            break;
                        }

                        case "S":
                        case "V": {

                            // Special case
                            file_url = tapeType === "S" ? WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=0" : file_url;

                            dynamic_id = globalplay_video_screenRecording(file_url, visual_size.width, visual_size.height, flex_div, element_alreadyTaken, global_numberID, element_current_duration);
                            break;
                        }

                        case "I": {
                            dynamic_id = globalplay_image(file_url, visual_size.width, visual_size.height, flex_div, element_alreadyTaken, global_numberID);
                            break;
                        }

                        case "D": {
                            dynamic_id = globalplay_document(file_url, element_alreadyTaken, global_numberID);
                            break;
                        }

                        case "C": {
                            dynamic_id = globalplay_comment(element_alreadyTaken, global_numberID);
                            break;
                        }
                    }

                    var dynamic_object = null;
                    if (audio_object != null) {
                        dynamic_id = audio_object[0];
                        dynamic_object = audio_object[1];
                    }

                    if (dynamic_id != "") {
                        var array = new Array();
                        array[0] = element_alreadyTaken[0];
                        array[1] = dynamic_id;
                        array[2] = dynamic_object;
                        globalplay_queue_elements.push(array);
                    }

                } // else: elemento ya procesado

            }
        } // for

    } // GLOBALPLAY_MAX_COLLISION_ELEMENTS
    else {
        var label = $(".flex #globalplay_divSpecialMessages h2");
        label.text(hashMessages["MaxElementsSimultaneous"]);
        label.show();

        // Remove to element list
        var duration_label = GLOBALPLAY_seconds_current + GLOBALPLAY_LABEL_DEFAULT_DURATION;
        globalplay_remove_elements.push([null, null, label, GLOBALPLAY_seconds_current, duration_label]);
    }
}

function globalplay_resizeAlreadyAdded(elementsCandidate) {

    var visual_queue_length = 0;
    if (elementsCandidate != null && elementsCandidate.length > 0) {

        // visual_queue: video, screen_recording and images
        var visual_queue = $.grep(elementsCandidate, function (el, i) {
            return el[0].tapeType == "V" || el[0].tapeType == "S" || el[0].tapeType == "I";
        });

        visual_queue_length = visual_queue.length;
    }

    var visual_alreadyAdded = $(".flex").find('[name="webchimera"], [name="fbsviewer"], [name="visual_element"]').length;
    var visual_count = visual_queue_length + visual_alreadyAdded;

    // >= 4 visual elements
    var width = 275;
    var height = 275;

    var current_screen = window.innerWidth;

    // Wide Promad
    if (current_screen >= 1920) {
        width = 390;
        height = 275;
    }

    // MAX Amount of simultaneous elements 
    var max_amount = GLOBALPLAY_MAX_COLLISION_ELEMENTS;
    if (visual_count <= max_amount) {

        // Element distinct types 
        switch (visual_count) {
            case 1:
                {
                    // Wide normal
                    width = 1000;
                    height = 550;

                    // Wide extra
                    if (current_screen >= 1920) {
                        width = 1400;
                        height = 600;
                    }
                    // Wide Promad
                    else if (current_screen >= 1440) {
                        width = 700;
                        height = 600;
                    }
                    break;
                }
            case 2:
                {
                    // Wide normal
                    width = 600;
                    height = 550;

                    // Wide extra
                    if (current_screen >= 1920) {
                        width = 800;
                        height = 600;
                    }
                    // Wide Promad
                    else if (current_screen >= 1440) {
                        width = 600;
                        height = 600;
                    }
                    break;
                }
            case 3:
                {
                    // Wide normal
                    width = 380;
                    height = 400;

                    // Wide extra
                    if (current_screen >= 1920) {
                        width = 500;
                        height = 500;
                    }
                    // Wide Promad
                    else if (current_screen >= 1440) {
                        width = 400;
                        height = 400;
                    }
                    
                    break;
                }
        }

        var visual_size = {
            width: width,
            height: height
        }


        if (visual_alreadyAdded > 0) {
            $(".flex").find('*').not('.info-label, .info-label *').each(function (index, el) {
                $(this).css("width", visual_size.width);
                $(this).css("height", visual_size.height);

            });

            $(".flex").find('.divVideo video').each(function (index, el) { //
                $(this).css("width", visual_size.width - 5);
                $(this).css("height", visual_size.height - 5);
            });
        }

        return visual_size;
    }
}

/********* Individual elements section *********/

// Play audio
function globalplay_audio(file_url, element_alreadyTaken, global_numberID, flex_div, element_current_duration) {
    var global_elementID = "audio_" + global_numberID;
    var fileName = element_alreadyTaken[0].fileName;
    var tapeID = element_alreadyTaken[0].tapeID;
    var duration = element_alreadyTaken[0].duration;
    var timestamp = element_alreadyTaken[0].timestamp;
    
    var object = new Array();
    object[0] = global_elementID;

    var label = $("#globalplay_divAudioName h2");
    label.text(fileName);
    label.show();

    // Get file extension
    var file_extension = getFileExtension(fileName);
    if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

        /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
        if (getIsIE() && file_extension[0] == "wav") {

            // Source: http://joliclic.free.fr/html/object-tag/en/

            // ActiveX audio object - wav -
            var wav_object = "<object id='" + global_elementID + "' data='" + file_url + "' type='audio/x-wav' ";
            wav_object += "style='display: none;' classid='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6'> ";
            wav_object += "<param name='URL' value='" + file_url + "'> ";
            wav_object += "<param name='autoplay' value='true'> ";
            wav_object += "<param name='autoStart' value='1'> ";
            wav_object += "</object>";

            flex_div.append(wav_object);

            var audio_player = $("#" + global_elementID);
            if (audio_player != null && audio_player[0] != null) {

                // Get element current duration
                if (element_current_duration != null && element_current_duration > 0) {
                    setTimeout(function () {
                        if (audio_player[0].controls != null) {
                            audio_player[0].controls.currentPosition = element_current_duration;
                        }
                    }, 200);
                }

                object[1] = audio_player[0];
            }

        } else { // Normal HTML5 Audio tag

            var audio_tag = "<audio id='" + global_elementID + "' src='" + file_url + "' autoplay style='display: none;' />";
            flex_div.append(audio_tag);

            var audio_player = $("#" + global_elementID);
            if (audio_player != null && audio_player[0] != null) {

                // Get element current duration
                if (element_current_duration != null && element_current_duration > 0) {
                    setTimeout(function () {
                        audio_player[0].currentTime = element_current_duration;
                    }, 200);
                }

                object[1] = audio_player[0];
            }
        }

        // Remove to element list
        var duration_int = parseInt(duration, 10);
        var actual_duration = getDuration_onDatetime(timestamp);
        var duration_final = actual_duration + duration_int + GLOBALPLAY_DEFAULT_DURATION_EXTRA;

        globalplay_remove_elements.push([global_elementID, element_alreadyTaken, label, actual_duration, duration_final]);
    }

    return object;
}

// Play video or screen recording
function globalplay_video_screenRecording(file_url, visual_size_width, visual_size_height, flex_div, element_alreadyTaken, global_numberID, element_current_duration) {
    var global_elementID = "";
    var duration = element_alreadyTaken[0].duration;
    var fileName = element_alreadyTaken[0].fileName;
    var timestamp = element_alreadyTaken[0].timestamp;

    var ok = false;

    // Get file extension
    var file_extension = getFileExtension(fileName);
    if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

        global_elementID = "Video_" + global_numberID;

        switch (file_extension[0]) {

            // HTML5 support:
            case "mp4":
            case "webm":
            case "ogg": {

                // HTML5 video tag Source: https://www.w3.org/2010/05/video/mediaevents.html

                //var js_player = '<div id="div' + global_elementID + '" class="divVideo" style="float:left;">';
                //js_player += '<video id="' + global_elementID + '" preload="none" style="width:' + visual_size_width + 'px; height:' + visual_size_height + 'px;" name="visual_element" autoplay>';
                var js_player = '<div id="div' + global_elementID + '" class="divVideo" style="float:left; width:' + visual_size_width + 'px; height:' + visual_size_height + 'px;">';
                js_player += '<video id="' + global_elementID + '" preload="none" style="width:' + (visual_size_width - 5) + 'px; height:' + (visual_size_height - 5) + 'px;" name="visual_element" autoplay>';
                js_player += '<source id="mp4" src="' + file_url + '" type="video/mp4">';
                js_player += '<source id="webm" src="' + file_url + '" type="video/webm">';
                js_player += '<source id="ogv" src="' + file_url + '" type="video/ogg">';
                js_player += '</video></div>';

                flex_div.append(js_player);

                var html_player = $("#" + global_elementID);
                if (html_player != null && html_player[0] != null) {
                    var seek = false;
                    if (element_current_duration != null && element_current_duration > 0) {
                        html_player[0].play();
                        ok = true;

                        setTimeout(function () {
                            try {
                                if (html_player[0].currentTime != null) {
                                    html_player[0].currentTime = element_current_duration;
                                }
                            } catch (err) {
                                console.log("l:473 Error seeking HTML5 video");
                                console.log(err);
                            }
                        }, 500);
                        seek = true;
                    }

                    if (!seek) {
                        html_player[0].play();
                        ok = true;
                    }

                    ok = true;
                }
                break;
            }

            case "fbs": {

                if (getIsFirefoxOrIE()) {
                    if (fileStatus != "PROCESSING" && fileStatus != "ERROR") {

                        var fileStatus = element_alreadyTaken[0].fileStatus;

                        var applet = "<div id='div" + global_elementID + "' style='float:left;'><applet codebase='assets/applets/' code='OrkMP.class' archive='OrkMP.jar' width='" + visual_size_width + "px' " +
                            "height='" + visual_size_height + "px;' name='fbsviewer' id='" + global_elementID + "' title='undefined'>";

                        applet += "<param name='HOST' value=''>";
                        applet += "<param name='PORT' value='5901'>";
                        applet += "<param name='FBSURL' value='" + file_url + "'>";
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
                        applet += "</applet>";
                        applet += "</div>";

                        flex_div.append(applet);

                        ok = false;

                        // Delay play function, so the player can have time to load
                        setTimeout(function () {

                            try {

                                var label = $("#globalplay_divVideoName h2");
                                label.text(fileName);

                                // FBS Special case
                                label.css("background-color", "blue");
                                label.show();

                                // Insert only if was loaded ok
                                var duration_int = parseInt(duration, 10);
                                var actual_duration = getDuration_onDatetime(timestamp);
                                var duration_final = actual_duration + duration_int + GLOBALPLAY_DEFAULT_DURATION_EXTRA;

                                globalplay_remove_elements.push([global_elementID, element_alreadyTaken, label, actual_duration, duration_final]);

                                var video_player = $("#" + global_elementID);

                                // PLAY
                                var seek = false;
                                if (element_current_duration != null && element_current_duration > 0) {
                                    video_player[0].play();

                                    setTimeout(function () {
                                        video_player[0].seekViewerSeconds(element_current_duration);
                                    }, 500);
                                    seek = true;
                                }

                                if (!seek) {
                                    video_player[0].play();
                                }

                            } catch (err) {
                                console.log("l:5087 Error pausing FBS Player");
                                console.log(err);

                                // Hide player until it is removed by "globalplay_remove_elements"
                                $("#div" + video_player).css("visibility", "hidden");

                                // Error message
                                var label = $("#globalplay_divSpecialMessages h2");
                                label.text(hashMessages["OrekaPlayerError"]);
                                label.show();

                                // Remove to element list
                                var duration_label = GLOBALPLAY_seconds_current + GLOBALPLAY_LABEL_DEFAULT_DURATION;
                                globalplay_remove_elements.push([null, null, label, GLOBALPLAY_seconds_current, duration_label]);

                            }
                        }, 3000);
                        //
                    }
                } else {
                    var label = $("#globalplay_divSpecialMessages h2");
                    label.text(hashMessages["UtilizarNavegador2"]);
                    label.show();

                    // Remove to element list
                    var duration_label = GLOBALPLAY_seconds_current + GLOBALPLAY_LABEL_DEFAULT_DURATION;
                    globalplay_remove_elements.push([null, null, label, GLOBALPLAY_seconds_current, duration_label]);
                }

                break;
            }

            case "avi":
            case "crypt":
            case "bin":
            default: {

                if (getIsFirefoxOrIE()) {

                    var width = flex_div.css("width");

                    if (getIsIE()) {

                        // WMP IE Object Source: https://msdn.microsoft.com/en-us/library/windows/desktop/dd564080(v=vs.85).aspx

                        // ActiveX video object
                        var js_player = "<div id='div" + global_elementID + "' name='visual_element' class='divVideo' style='float:left; width:" + visual_size_width + "px; " + "height:" + visual_size_height + "px;'> "; 
                        js_player += "<object id='" + global_elementID + "' data='" + file_url + "' ";
                        js_player += "width='" + (visual_size_width - 5) + "' height='" + (visual_size_height - 5) + "' ";
                        js_player += "CLASSID='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6'> ";
                        js_player += "<PARAM name='URL' value='" + file_url + "'> ";
                        js_player += "<PARAM name='uiMode' value='none'> ";
                        js_player += "</object></div>";

                        flex_div.append(js_player);

                        var video_player = $("#" + global_elementID);
                        if (video_player != null && video_player[0] != null) {

                            if (element_current_duration != null && element_current_duration > 0) {
                                ok = true;

                                setTimeout(function () {
                                    if (video_player[0].controls != null) {
                                        video_player[0].controls.currentPosition = element_current_duration;
                                    }
                                }, 1300);
                            }

                            ok = true;
                        }

                    } else {

                        // Webchimera
                        var applet = "<div id='div" + global_elementID + "' class='divVideo' style='float:left;'>";
                        applet += "<object id='" + global_elementID + "' type='application/x-chimera-plugin' width='" + (visual_size_width - 3) + "' ";
                        applet += "height='" + (visual_size_height - 3) + "' name='visual_element' style='position:relative; float:left; margin: 10px;'>";
                        applet += "<param name='windowless' value='true' />";
                        applet += "</object>";
                        applet += "<div id='interface'></div></div>";

                        flex_div.append(applet);

                        var webchimera_loaded = true;

                        try {
                            wjs("#" + global_elementID).clearPlaylist();
                            wjs("#" + global_elementID).addPlaylist(file_url);

                            var seek = false;
                            if (element_current_duration != null && element_current_duration > 0) {
                                wjs("#" + global_elementID).play();

                                setTimeout(function () {
                                    wjs("#" + global_elementID).time(element_current_duration);
                                }, 500);
                                seek = true;
                            }

                            if (!seek) {
                                wjs("#" + global_elementID).play();
                            }

                        } catch (err) {
                            console.log("l:660 Error loading webchimera");
                            console.log(err);

                            webchimera_loaded = false;
                        }

                        // Webchimera Plugin not installed
                        if (!webchimera_loaded) {
                            var label = $("#globalplay_divSpecialMessages h2");
                            label.text(hashMessages["InstallWebchimera_Aux"]);
                            label.show();

                            // Remove to element list
                            var duration_label = GLOBALPLAY_seconds_current + GLOBALPLAY_LABEL_DEFAULT_DURATION;
                            globalplay_remove_elements.push([null, null, label, GLOBALPLAY_seconds_current, duration_label]);
                        }

                    } // End webchimera

                    ok = true;
                }
                else {
                    var label = $("#globalplay_divSpecialMessages h2");
                    label.text(hashMessages["UtilizarNavegador2"]);
                    label.show();

                    // Remove to element list
                    var duration_label = GLOBALPLAY_seconds_current + GLOBALPLAY_LABEL_DEFAULT_DURATION;
                    globalplay_remove_elements.push([null, null, label, GLOBALPLAY_seconds_current, duration_label]);
                }

                break;
            }
        }
    }

    if (ok) {

        var label = $("#globalplay_divVideoName h2");
        label.text(fileName);

        // Remove FBS Special case
        label.css("background-color", "purple");
        label.show();

        var duration_int = parseInt(duration, 10);
        var actual_duration = getDuration_onDatetime(timestamp);
        var duration_final = actual_duration + duration_int + GLOBALPLAY_DEFAULT_DURATION_EXTRA;

        globalplay_remove_elements.push([global_elementID, element_alreadyTaken, label, actual_duration, duration_final]);
    }
    return global_elementID;
}

// Play image
function globalplay_image(file_url, visual_size_width, visual_size_height, flex_div, element_alreadyTaken, global_numberID) {
    var global_elementID = "image_" + global_numberID;
    var segmentID = element_alreadyTaken[0].segmentID;
    var fileName = element_alreadyTaken[0].fileName;
    var timestamp = element_alreadyTaken[0].timestamp;

    $('<a name="visual_element" id="' + global_elementID + '" style="width:' + visual_size_width + 'px; height:' + visual_size_height + 'px;' +
       'background-image:url(' + file_url + '); float:left; position:relative; margin:8px 12px; background-size: auto 100%;"' +
       'width="' + visual_size_width + '" height="' + visual_size_height + '">' + fileName + '</a>').appendTo(flex_div).fadeIn(2000);

    // Add Fullscreen click Event
    $("#" + global_elementID).attr("src", file_url).photobox();

    // Salvattore Source: http://webdesign.tutsplus.com/tutorials/build-a-dynamic-grid-with-salvattore-and-bootstrap-in-10-minutes--cms-20410

    // Remove to element list
    var actual_duration = getDuration_onDatetime(timestamp);
    var duration_final = actual_duration + GLOBALPLAY_DEFAULT_DURATION;
    globalplay_remove_elements.push([global_elementID, element_alreadyTaken, null, actual_duration, duration_final]);

    return global_elementID;
}

// Play document
function globalplay_document(file_url, element_alreadyTaken, global_numberID) {
    var global_elementID = "document_" + global_numberID;
    var fileName = element_alreadyTaken[0].fileName;
    var timestamp = element_alreadyTaken[0].timestamp;

    var label = $("#globalplay_divDocumentsName h2");
    label.text("Documento: " + fileName);
    label.show();

    // Remove to element list
    var actual_duration = getDuration_onDatetime(timestamp);
    var duration_final = actual_duration + GLOBALPLAY_DEFAULT_DURATION;
    globalplay_remove_elements.push([global_elementID, element_alreadyTaken, label, actual_duration, duration_final]);

    return global_elementID;
}

// Play comment
function globalplay_comment(element_alreadyTaken, global_numberID) {
    var global_elementID = "comment_" + global_numberID;
    var fileName = element_alreadyTaken[0].fileName;
    var duration = element_alreadyTaken[0].duration;
    var timestamp = element_alreadyTaken[0].timestamp;

    var duration_int = parseInt(duration, 10);
    var duration_sec = duration_int <= 1 ? 5 : duration_int;

    var label = $("#globalplay_divComments h2");
    label.text(fileName);

    // Remove to element list
    var actual_duration = getDuration_onDatetime(timestamp);
    var duration_final = actual_duration + duration_sec;

    globalplay_remove_elements.push([global_elementID, element_alreadyTaken, label, actual_duration, duration_final]);

    return global_elementID;
}

/********* Individual elements section END *********/

// Remove mute buttons on audio elements
function globalplay_removeMuteButtons() {

    $("a[id*='btnMute_']").parent().each(function () { $(this).css("z-index", "0"); });

}

// Load globalplay initial events
function globalplay_loadEvents() {

    if (elementsInMemory != null && elementsInMemory.length > 0) {
        for (var i = 0; i < elementsInMemory.length; i++) {
            var element = elementsInMemory[i];
            if (element != null) {

                var tapeID = element.tapeID;
                var tapeType = element.tapeType;
                switch (tapeType) {

                    case "A": {
                        // Event: Button mute function on audio elements

                        // Darktooltip Source: https://github.com/rubentd/darktooltip

                        var audio_element = $("#tlTape_" + element.tapeID);
                        audio_element.attr("data-tooltip", " ");

                        // Add new Tooltip
                        audio_element.darkTooltip({
                            trigger: 'hover',
                            animation: 'flipIn',
                            gravity: 'south',
                            theme: 'light',
                            confirm: true,
                            yes: ' ',
                            onYes: function (event) {

                                globalplay_muteAudio(event);
                            }
                        });

                        // locate mute button over fancybox screen
                        var id = audio_element.attr('id');
                        $("#darktooltip-" + id).css("z-index", 9000);
                        break;
                    }

                } // switch tapeType
            }
        }
    } // for

}

function globalplay_muteAudio(event) {
    if (event != null && event[0] != null && event[0].id != null && event[0].id.length) {
        var id_complete = event[0].id;
        var id = id_complete.replace('tlTape_', '');

        var icon = $("#btnMute_" + event[0].id + " > span");

        if (id != null) {
            var element_object = globalplay_getQueueElementByID(id);
            if (element_object != null && element_object.length > 2 != null && element_object[0] != null && element_object[2] != null) {

                var ok1 = false;
                var dynamic_object = element_object[2];
                if (dynamic_object != null) {

                    var element = element_object[0];
                    var fileName = element.fileName;
                    var file_extension = getFileExtension(fileName);

                    var ok2 = false;

                    // Get file extension
                    var file_extension = getFileExtension(fileName);
                    if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

                        /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
                        if (getIsIE() && file_extension[0] == "wav") {
                            if (dynamic_object.mute != null) {
                                ok1 = ok2 = true;
                                dynamic_object.mute = !dynamic_object.mute;
                            }
                        }
                        else {
                            if (dynamic_object.muted != null) {
                                ok1 = ok2 = true;
                                dynamic_object.muted = !dynamic_object.muted;
                            }
                        }
                        if (ok2) {
                            // change button icon
                            if (icon.hasClass("glyphicon-volume-up")) {
                                icon.addClass("glyphicon-volume-off");
                                icon.removeClass("glyphicon-volume-up");
                            } else {
                                icon.addClass("glyphicon-volume-up");
                                icon.removeClass("glyphicon-volume-off");
                            }
                        }
                    }
                }
            }
            if (!ok1) {
                icon.parent().hide();
                icon.parent().show("bounce", 80);
            }
        }
    }
}

function globalplay_getQueueElementByID(elementID) {

    // FORMAT: globalplay_queue_elements:
    // element[0] = Element
    // element[1] = Dynamic ID
    // element[2] = Dynamic Object
    if (globalplay_queue_elements != null && globalplay_queue_elements.length > 0) {
        for (var i = 0; i < globalplay_queue_elements.length; i++) {

            var element = globalplay_queue_elements[i];
            if (element != null && element.length > 1 && element[0] != null && element[0].tapeID != null && element[2] != null) {
                if (element[0].tapeID == elementID) {
                    return element;
                }
            }
        } // for
    }
}

// Pause all media current playing elements
function globalplay_pausePlayingElements(isStop) {

    // FORMAT: globalplay_queue_elements:
    // element[0] = Element
    // element[1] = Dynamic ID
    // element[2] = Dynamic Object
    if (globalplay_queue_elements != null && globalplay_queue_elements.length > 0) {
        for (var i = 0; i < globalplay_queue_elements.length; i++) {
            var element = globalplay_queue_elements[i];

            if (element != null && element[0] != null && element[0].tapeType != null) {
                var tapeType = element[0].tapeType;
                var fileName = element[0].fileName;
                var dynamicID = element[1];
                var dynamic_object = element[2];

                // Get file extension
                var file_extension = getFileExtension(fileName);

                switch (tapeType) {
                    case "A": {

                        // Get file extension
                        var file_extension = getFileExtension(fileName);
                        if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

                            var audio_player = $("#" + dynamicID);
                            if (audio_player != null && audio_player[0] != null) {

                                /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
                                if (getIsIE() && file_extension[0] == "wav") {

                                    if (audio_player[0].controls != null) {

                                        // ActiveX audio object - wav -
                                        if (isStop) {
                                            try {
                                                audio_player[0].controls.stop();
                                            } catch (err) {
                                                console.log("l:936 Error stoping IE ActiveX Player");
                                                console.log(err);
                                            }
                                        } else {
                                            try {
                                                audio_player[0].controls.pause();
                                            } catch (err) {
                                                console.log("l:943 Error pausing IE ActiveX Player");
                                                console.log(err);
                                            }
                                        }
                                    }
                                } else { // Normal HTML5 Audio tag

                                    if (isStop) {
                                        try {
                                            audio_player[0].pause();
                                            audio_player[0].currentTime = 0;
                                        } catch (err) {
                                            console.log("l:955 Error pausing HTML5 Player");
                                            console.log(err);
                                        }
                                    } else {
                                        try {
                                            audio_player[0].pause();
                                        } catch (err) {
                                            console.log("l:962 Error pausing HTML5 Player");
                                            console.log(err);
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    }

                    case "S":
                    case "V": {

                        // Get file extension
                        var file_extension = getFileExtension(fileName);
                        if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

                            var video_player = $("#" + dynamicID);
                            if (video_player != null && video_player[0] != null) {

                                switch (file_extension[0]) {

                                    // HTML5 support:
                                    case "mp4":
                                    case "webm":
                                    case "ogg": {

                                        if (isStop) {
                                            try {
                                                video_player[0].pause();
                                                video_player[0].currentTime = 0;
                                            } catch (err) {
                                                console.log("l:4456 Error pausing HTML5 Player");
                                                console.log(err);
                                            }
                                        } else {
                                            try {
                                                video_player[0].pause();
                                            } catch (err) {
                                                console.log("l:4463 Error pausing HTML5 Player");
                                                console.log(err);
                                            }
                                        }
                                        break;
                                    }

                                    case "fbs": {

                                        // Oreka Player:
                                        if (document.fbsviewer != null) {
                                            if (isStop) {
                                                try {
                                                    video_player[0].stop();
                                                } catch (err) {
                                                    console.log("l:4429 Error playing FBS Player");
                                                    console.log(err);
                                                }
                                            } else {
                                                try {
                                                    video_player[0].pause();
                                                } catch (err) {
                                                    console.log("l:4436 Error pausing FBS Player");
                                                    console.log(err);
                                                }
                                            }
                                        }
                                        break;
                                    }

                                    case "avi":
                                    case "crypt":
                                    case "bin":
                                    default: {

                                        if (getIsIE()) {

                                            // ActiveX video object
                                            if (video_player[0].controls != null) {

                                                if (isStop) {
                                                    try {
                                                        video_player[0].controls.stop();
                                                    } catch (err) {
                                                        console.log("l:1033 Error stopping IE video object");
                                                        console.log(err);
                                                    }
                                                } else {
                                                    try {
                                                        video_player[0].controls.pause();
                                                    } catch (err) {
                                                        console.log("l:1040 Error pausing IE video object");
                                                        console.log(err);
                                                    }
                                                }

                                            }
                                        } else {

                                            // Webchimera Plugin Player or else:
                                            if (isStop) {
                                                try {
                                                    wjs("#" + dynamicID).stop();
                                                } catch (err) {
                                                    console.log("l:4504 Error stopping webchimera");
                                                    console.log(err);
                                                }
                                            } else {
                                                try {
                                                    wjs("#" + dynamicID).pause();
                                                } catch (err) {
                                                    console.log("l:4511 Error pausing webchimera");
                                                    console.log(err);
                                                }
                                            }

                                        }

                                        break;
                                    }
                                } // switch file_extension
                            }
                        }
                        break;
                    }

                } // switch tapeType
            }
        } //for
    }
}

// Resume globalplay current paused elements
function globalplay_resumeAllCurrentMedia() {

    // FORMAT: globalplay_queue_elements:
    // element[0] = Element
    // element[1] = Dynamic ID
    // element[2] = Dynamic Object
    if (globalplay_queue_elements != null && globalplay_queue_elements.length > 0) {
        for (var i = 0; i < globalplay_queue_elements.length; i++) {
            var element = globalplay_queue_elements[i];

            if (element != null && element[0] != null && element[0].tapeType != null) {
                var tapeType = element[0].tapeType;
                var fileName = element[0].fileName;
                var dynamicID = element[1];
                var dynamic_object = element[2];

                // Get file extension
                var file_extension = getFileExtension(fileName);
                if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

                    switch (tapeType) {
                        case "A": {

                            var audio_player = $("#" + dynamicID);
                            if (audio_player != null && audio_player[0] != null) {

                                /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
                                if (getIsIE() && file_extension[0] == "wav") {

                                    if (audio_player[0].controls != null) {

                                        try {
                                            audio_player[0].controls.play();
                                        } catch (err) {
                                            console.log("l:4545 Error playing IE ActiveX Player");
                                            console.log(err);
                                        }

                                    }
                                }
                                else { // Normal HTML5 Audio tag

                                    audio_player[0].play();
                                }
                            }
                            break;
                        }

                        case "S":
                        case "V": {

                            var video_player = $("#" + dynamicID);
                            if (video_player != null && video_player[0] != null) {

                                switch (file_extension[0]) {

                                    // HTML5 support:
                                    case "mp4":
                                    case "webm":
                                    case "ogg": {

                                            try {
                                                video_player[0].play();
                                            } catch (err) {
                                                console.log("l:4572 Error playing HTML5 Player");
                                                console.log(err);
                                            }
                                        break;
                                    }

                                    case "fbs": {

                                        // Oreka Player:
                                            try {
                                                video_player[0].play();
                                            } catch (err) {
                                                console.log("l:4586 Error playing FBS Player");
                                                console.log(err);
                                            }
                                        break;
                                    }

                                    case "avi":
                                    case "crypt":
                                    case "bin":
                                    default: {

                                        if (getIsIE()) {

                                            // ActiveX video object
                                            if (video_player[0].controls != null) {

                                                try {
                                                    video_player[0].controls.play();
                                                } catch (err) {
                                                    console.log("l:1148 Error resuming IE video object");
                                                    console.log(err);
                                                }

                                            }
                                        } else {


                                            // Webchimera Plugin Player or else:
                                            try {
                                                wjs("#" + dynamicID).play();

                                            } catch (err) {
                                                console.log("l:1160 Error resuming webchimera");
                                                console.log(err);                                               
                                            }
                                        } // END webchimera
                                        break;
                                    }
                                } // switch extension
                            }
                            break;
                        }

                    } // switch type
                }
            }
        } // for
    }
}


function globalplay_filterElementsChecked() {

    // Get only visible and checked checkboxes to remove
    var list_elements = [];
    $('tr:visible td input:checked').each(function () {
        list_elements.push($(this).attr('value'));
    });

    globalplay_stack_elements = [[], []]; // [object, already_taken: bool]
    if (list_elements.length > 0) {
        for (var i = 0; i < list_elements.length; i++) {
            if (list_elements[i] != null) {
                var attrs_array = list_elements[i].split("#"); // Element attributes
                if (attrs_array.length == 3) {
                    var tapeID = attrs_array[0];
                    if (tapeID != null && tapeID.length) {
                        var element = getElementInMemoryByID(tapeID)
                        if (element != null) {
                            var element_alreadyTaken = new Array();
                            element_alreadyTaken[0] = element;
                            element_alreadyTaken[1] = false; // AlreadyTaken false
                            globalplay_stack_elements.push(element_alreadyTaken);
                        }
                    }
                }
            }
        } // for
    }
}


// Remove elements from DOM on globalplay screen -- "GARBAGE COLLECTOR" --
function globalplay_removeElementsFromPlayback() {

    /* Object
     * 0: Element DOM ID - dynamicID
     * 1: Element (globalplay_stack_elements)
     * 2: label
     * 3: Element playback start time
     * 4: Element playback stop time
     */
    if (globalplay_remove_elements.length > 0) {
        for (var i = 0; i < globalplay_remove_elements.length; i++) {
            var object = globalplay_remove_elements[i];
            if (object != null) {
                var dynamicID = object[0]; // dynamicID 
                var element = object[1];
                var label = object[2];
                var timeToStart = object[3]
                var timeToRemove = object[4];

                //remove element from queue when current time is outside the playback time range for the element
                if (GLOBALPLAY_seconds_current < timeToStart || GLOBALPLAY_seconds_current >= timeToRemove) {
                    if (element != null) {
                        globalplay_removeElement(dynamicID, element);
                    }
                    if (label != null) {
                        // Empty label
                        globalplay_clearLabel(label);

                        if (dynamicID == null) {
                            label.hide();
                        }
                    }

                    // "Remove" object in array
                    globalplay_remove_elements[i] = null;
                }
            }

        } // for

        //purge array
        globalplay_remove_elements = globalplay_remove_elements.filter(function (item) {
            return item !== null;
        });

    }
}

function globalplay_loadElementSeek(pointer_current_duration) {

    // FORMAT: globalplay_queue_elements:
    // element[0] = Element
    // element[1] = Dynamic ID
    // element[2] = Dynamic Object
    if (globalplay_queue_elements != null && globalplay_queue_elements.length > 0) {
        for (var i = 0; i < globalplay_queue_elements.length; i++) {
            var queue_element = globalplay_queue_elements[i];
            if (queue_element != null && queue_element.length) {

                var dynamicID = queue_element[1];
                var element = queue_element[0];
                if (element != null) {

                    var tapeType = element.tapeType;
                    var timestamp = element.timestamp;
                    var tapeID = element.tapeID;
                    var fileName = element.fileName;

                    // Get element current duration
                    var element_start_duration = getDuration_onDatetime(timestamp);
                    if (pointer_current_duration > element_start_duration) {
                        var element_current_duration = pointer_current_duration - element_start_duration;

                        // Get file extension
                        var file_extension = getFileExtension(fileName);
                        if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

                            switch (tapeType) {
                                case "A": {

                                    if (dynamicID != null) {
                                        var audio_player = $("#" + dynamicID);
                                        if (audio_player != null && audio_player[0] != null) {

                                            /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
                                            if (getIsIE() && file_extension[0] == "wav") {

                                                if (audio_player[0].controls != null) {

                                                    try {
                                                        // ActiveX audio object - wav -
                                                        audio_player[0].controls.currentPosition = element_current_duration;
                                                    } catch (err) {
                                                        console.log("l:1330 Error seeking IE ActiveX Player");
                                                        console.log(err);
                                                    }

                                                }
                                            }
                                            else { // Normal HTML5 Audio tag

                                                audio_player[0].currentTime = element_current_duration;
                                            }
                                        }
                                    }
                                    break;
                                }

                                case "S":
                                case "V": {

                                    var video_player = $("#" + dynamicID);
                                    if (video_player != null && video_player[0] != null) {

                                        switch (file_extension[0]) {

                                            // HTML5 support:
                                            case "mp4":
                                            case "webm":
                                            case "ogg": {

                                                try {
                                                    video_player[0].currentTime = element_current_duration;
                                                } catch (err) {
                                                    console.log("l:1366 Error seeking HTML5 Player");
                                                    console.log(err);
                                                }
                                                break;
                                            }

                                            case "fbs": {

                                                // Oreka Player:
                                                try {
                                                    video_player[0].seekViewerSeconds(element_current_duration);
                                                } catch (err) {
                                                    console.log("l:1379 Error seeking FBS Player");
                                                    console.log(err);
                                                }

                                                break;
                                            }

                                            case "avi":
                                            case "crypt":
                                            case "bin":
                                            default: {

                                                if (getIsIE()) {

                                                    // ActiveX video object
                                                    if (video_player[0].controls != null) {

                                                        try {
                                                            video_player[0].controls.currentPosition = element_current_duration;
                                                        } catch (err) {
                                                            console.log("l:1375 Error seeking IE video object");
                                                            console.log(err);
                                                        }

                                                    }
                                                } else {


                                                    // Webchimera Plugin Player or else:
                                                    try {
                                                        //wjs("#" + dynamicID).plugin.time = element_current_duration;
                                                        wjs("#" + dynamicID).time(element_current_duration);
                                                    } catch (err) {
                                                        console.log("l:1386 Error seeking webchimera");
                                                        console.log(err);
                                                    }
                                                } // END webchimera

                                                break;
                                            }
                                        } // switch file_extension
                                    }
                                    break;
                                }

                            } // switch tapeType

                        }
                    }
                }
            }
        }
    }
}

function globalplay_removeAll() {

    // Remove elements from globalplay player
    globalplay_removeDOMElements();

    // Stop all audios
    globalplay_pausePlayingElements(true);

    // Remove all audios from queue
    if (globalplay_queue_elements != null && globalplay_queue_elements.length > 0) {
        for (var i = 0; i < globalplay_queue_elements.length; i++) {

            var element = globalplay_queue_elements[i];
            if (element != null && element.length > 1 && element[0] != null && element[0].tapeID != null) {
                if (element[0].tapeType == "A") {
                    element[0] = null;
                }
            }
        } // for
    }
}

function getElementInQueueArray(elementID) {

    // FORMAT: globalplay_queue_elements:
    // element[0] = Element
    // element[1] = Dynamic ID
    // element[2] = Dynamic Object
    if (globalplay_queue_elements != null && globalplay_queue_elements.length > 0) {
        for (var i = 0; i < globalplay_queue_elements.length; i++) {
            if (globalplay_queue_elements[i] != null) {
                var queue_element = globalplay_queue_elements[i];
                if (queue_element[2] != null) {
                    return i;
                }
            }
        } // for
    }
    return -1;
}


// Stop timer 
function globalplay_abort() {
    clearInterval(timer_globalplay);
    timer_globalplay = 0;
    $('#divGlobalplay_timer').timer('pause');
}

function globalplay_stop() {

    // DO STOP
    $("#globalplay_play").removeClass("globalplay_pause");
    $("#globalplay_play").addClass("globalplay_play");

    TIMELINE_POINTER.css("left", "0%");

    // Stop all elements currently playing
    globalplay_pausePlayingElements(true);

    // Set ready elements already taken
    globalplay_prepareElementsAlreadyTaken();

    // Remove elements from globalplay player
    globalplay_removeDOMElements();

    // Clean info labels
    globalplay_cleanLabels();

    global_numberID = 0;

    // Stop timer 
    globalplay_abort();
    GLOBALPLAY_seconds_current = 0;
    $("#lblGlobalplay_timer_current").text("00:00:00");

    // Clear global timer
    $('#divGlobalplay_timer').timer('remove');

    // Empty list of playing elements 
    globalplay_queue_elements = [[], [], []];

    // Empty list of elements to remove
    globalplay_remove_elements = [];
    globalplay_playback_active = false;
}

// Clean info labels
function globalplay_cleanLabels() {
    $("#lblGlobalplay_element_count").text("0");
    $("#lblGlobalplay_element_ids").text("0");
    $("#lblGlobalplay_timer_total_longFormat").text("00:00:00");
    $("#lblGlobalplay_timer_current_longFormat").text("00:00:00");
}

// Remove elements from globalplay player
function globalplay_removeDOMElements() {
    $(".flex").find('*').remove();

    // Clean all label elements
    $("#flex_messages div h2").text("");
}

function globalplay_removeElement(dynamicID, element_alreadyTaken) {

    // FORMAT: element_alreadyTaken
    // element_alreadyTaken[0] = Element
    // element_alreadyTaken[1] = AlreadyTaken bool
    var element = element_alreadyTaken[0];
    if (element != null) {
        var tapeID = element.tapeID;
        var tapeType = element.tapeType;
        var fileName = element.fileName;

        // Set alreadyTaken to false to signal the element is available again:
        globalplay_setElementAlreadyTaken(tapeID, false);

        // If is Audio stop it and remove it
        if (tapeType === "A") {

            var audio_player = $("#" + dynamicID);
            if (audio_player != null && audio_player[0] != null) {

                // Get file extension
                var file_extension = getFileExtension(fileName);
                if (file_extension != null && file_extension.length > 0 && file_extension[0] && file_extension[0].length > 0) {

                    /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
                    if (getIsIE() && file_extension != null && file_extension[0] == "wav") {

                        if (audio_player[0].controls != null) {

                            try {
                                audio_player[0].controls.stop();
                            } catch (err) {
                                console.log("l:5614 Error stopping IE ActiveX Player");
                                console.log(err);
                            }

                        }
                    }
                    else { // Normal HTML5 Audio tag

                        audio_player[0].pause();
                    }
                }
            }
        } else if (tapeType === "V" || tapeType === "S") {

            //remove visual element from player
            $(".flex #div" + dynamicID).remove();

            // Resize elements already added
            globalplay_resizeAlreadyAdded(null);
        } else if (tapeType === "I") {

            //remove visual element from player
            $(".flex #" + dynamicID).remove();

            // Resize elements already added
            globalplay_resizeAlreadyAdded(null);
        }

        // FORMAT: globalplay_queue_elements:
        // element[0] = Element
        // element[1] = Dynamic ID
        // element[2] = Dynamic Object

        // Remove element from current elements queue:  
        if (globalplay_queue_elements != null && globalplay_queue_elements.length > 0) {
            globalplay_queue_elements = $.grep(globalplay_queue_elements, function (queue_element, i) {
                if (queue_element != null && queue_element[1] != null)
                    return queue_element[1] != dynamicID;
            });
        }

    }
}

// Empty label
function globalplay_clearLabel(label) {
    label.text("");
}

// Search elements in current playtime
function getElementInMemoryByCurrentPlayingTime() {
    if (globalplay_stack_elements != null && globalplay_stack_elements.length > 0) {

        var current_duration = GLOBALPLAY_seconds_current;
        var timeCurrent = moment(_TL_STARTDATE, "DD-MM-YYYY HH:mm:ss");
        if (current_duration > 1) { // Check the first element
            timeCurrent.add(current_duration, "seconds");
        }

        // element_alreadyTaken[0] = element
        // element_alreadyTaken[1] = AlreadyTaken
        var array = globalplay_stack_elements.filter(function (element_alreadyTaken) {
            var element_start = null;
            var element_end = null;
            if (element_alreadyTaken != null) {
                var element = element_alreadyTaken[0];
                if (element != null && element.timestamp != null && element.duration != null) {
                    element_start = moment(element.timestamp, "DD-MM-YYYY HH:mm:ss");
                    element_end = moment(element.timestamp, "DD-MM-YYYY HH:mm:ss");
                    element_end.add(element.duration, "seconds");
                }
            }
            return element_start != null && element_end != null && element_alreadyTaken[1] === false && // AlreadyTaken false
                element_start.toDate() <= timeCurrent.toDate() &&
                timeCurrent.toDate() <= element_end.toDate();
        });
        return array;
    }
}

// Set ready elements already taken
function globalplay_prepareElementsAlreadyTaken() {
    if (globalplay_stack_elements != null && globalplay_stack_elements.length > 0) {
        for (var i = 0; i < globalplay_stack_elements.length; i++) {
            var element_alreadyTaken = globalplay_stack_elements[i];
            if (element_alreadyTaken != null && element_alreadyTaken[1] == true) {
                element_alreadyTaken[1] = false; // AlreadyTaken false
            }
        }
    }
}

// Set ready elements already taken TRUE / FALSE
function globalplay_setElementAlreadyTaken(elementID, value) {
    if (globalplay_stack_elements != null && globalplay_stack_elements.length > 0) {
        var stak_element_index = -1;
        for (var i = 0; i < globalplay_stack_elements.length; i++) {
            var element_alreadyTaken = globalplay_stack_elements[i];
            if (element_alreadyTaken != null && element_alreadyTaken[0] != null && element_alreadyTaken[1] != null) {
                var stack_elementID = element_alreadyTaken[0].tapeID;
                var stack_elementAlreadyTaken = element_alreadyTaken[1];
                if (stack_elementID == elementID && stack_elementAlreadyTaken != value) {
                    stak_element_index = i;
                }
            }

            if (stak_element_index >= 0 && globalplay_stack_elements.length >= stak_element_index) {
                var candidate = globalplay_stack_elements[stak_element_index];
                if (candidate != null && candidate[1] != null) {
                    candidate[1] = value; // AlreadyTaken true / false
                }
            }
        }
    }
}

/******** @author: Gonzalo Borderolle - inConcert MVD/UY ********/
/******** END: Media Player 2.0: Nuevo Requerimiento: Global Play ********/
