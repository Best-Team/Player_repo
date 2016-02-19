﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="MediaPlayer.Dashboard" MasterPageFile="~/Site.Master" %>
<asp:content id="Content2" ContentPlaceHolderID="ContentHeader" runat="server">

	<!-- Scripts -->
	<script src="ExternalResources/Alert_Messages.js"></script>
	<script src="assets/js/datetimepicker.full.min.js"></script>
	<script src="assets/js/timeframe.js"></script>
	<script src="assets/js/soundmanager2.js"></script>
	<script src="assets/js/soundmanager2-nodebug.js"></script>
	<script src="assets/js/bar-ui.js"></script>
	<script src="assets/js/moment.js"></script>
	<script src="assets/js/popbox.js"></script>
	<script src="assets/js/popbox2.js"></script>
	<script src="assets/js/popbox3.js"></script> 
	<script src="assets/js/popbox4.js"></script>
	<script src="assets/js/jshashtable-2.1_src.js"></script>
	<script src="assets/js/jquery.numberformatter-1.2.3.js"></script>
	<script src="assets/js/tmpl.js"></script>
	<script src="assets/js/jquery.dependClass-0.1.js"></script>
	<script src="assets/js/draggable-0.1.js"></script>
	<script src="assets/js/jquery.slider.js"></script>
	<script src="assets/js/jquery.ba-dotimeout.js"></script>
	<script src="assets/js/webchimera.js" type="text/javascript"></script>  
	<script src="assets/js/timer.jquery.js"></script>
	<script src="assets/js/inputmask.js"></script>
	<script src="assets/js/jquery.inputmask.js"></script>
	<script src="assets/js/inputmask.date.extensions.js"></script>
	<script src="assets/js/inputmask.dependencyLib.jquery.js"></script>
	<script src="assets/js/inputmask.extensions.js"></script>
	<script src="assets/js/jquery.inputmask.bundle.js"></script>
	<script src="assets/js/jquery.maskedinput.js"></script>
	<script src="assets/js/jquery.fancybox.js"></script>
	<script src="assets/js/timer.jquery.js"></script>
	<script src="assets/js/bootstrap-confirmation.js"></script>


	<!-- Styles -->
	<link href="assets/css/datetimepicker.css" type="text/css" rel="stylesheet"/>
	<link href="assets/css/jquery.photobox.css" type="text/css" rel="stylesheet"/> 
	<link href="assets/css/timeline-styles.css" rel="stylesheet" />
	<link href="assets/css/numericUpDown.css" rel="stylesheet" />
	<link href="assets/css/bar-ui.css" rel="stylesheet" />
	<link href="assets/css/popbox.css" rel="stylesheet" />
	<link href="assets/css/qtip.css" rel="stylesheet" />
	<link href="assets/css/highlight.css" rel="stylesheet" />
	<link href="assets/css/jslider.css" rel="stylesheet" />
	<link href="assets/css/globalplay.css" type="text/css" rel="stylesheet"/> 
	<link href="assets/css/jquery.fancybox.css" type="text/css" rel="stylesheet"/> 

   <script type="text/javascript">
	  
	   //#region Global Variables

	   /**** Timeline global variables ****/

	   var _TL_DATA = null;
	   var _TL_STARTDATE = "";
	   var _TL_ENDDATE = "";

	   /**** FBS Player global variables ****/

	   var previousSecs = 0;

	   /**** General global variables ****/

	   var MAX_DOWNLOAD_FILES = 6;
	   var GLOBALPLAY_DEFAULT_DURATION = 30000; // 30 s // 5000 = 5 seg
	   var SVG_Height = 170;
	   var addComment_active = false;
	   var addFile_active = false;
	   var elementType_active = "";
	   var comment_popup_timestamp = "";
	   var initial_size = 0;
	   var elementsInMemory = [];
	   var stack_elements = [[], []]; // [object, already_taken: bool]
	   var selectedElementID = 0;
	   var currrentVideoDuration = 0;
	   var currentPointerPositionDate;

	   // Timeline Global Pointer
	   var TIMELINE_POINTER = $("#sm2-progress-ball_TIMELINE");
	   var PLAYER_BOX = $("div[id*='playerBox");


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
		   try{
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
		   var _hdnWebchimera_Install_URL = $("input[id*='_hdnWebchimera_Install_URL']");
		   if (_hdnWebchimera_Install_URL != null && _hdnWebchimera_Install_URL.val() != null && _hdnWebchimera_Install_URL.val().length > 0) {
			   Webchimera_Install_URL = _hdnWebchimera_Install_URL.val();
		   }
		   hashMessages["InstallWebchimera_url"] = Webchimera_Install_URL;

		   //runTableVisualEffect(true);
		   getElementsInMemory();
		   loadHiddenFields();
		   initVariables();
		  
		   initial_size = $('#divPanel_Busqueda').css('width');
		   var pnlTagTypes = $("div[id$='pnlTagTypes']");
		   if (pnlTagTypes != null && pnlTagTypes.length) {
			   pnlTagTypes.css("margin-top", "-13px");
		   }
		   
		   // Initial focus
		   $("input[id*='_txbSearchBox1']").focus();

		   // Events on Ready ---------------------------------------------------

		   /**** Date time picker control: comment date ****/
		   $('#commentDate').inputmask({
			   mask: "1-2-y h:s:s",
			   placeholder: "dd-mm-yyyy HH:mm:ss",
			   alias: "datetime",
			   separator: "-",
			   hourFormat: "24"
		   });
		   $("input[id*='uploadDate']").inputmask({
			   mask: "1-2-y h:s:s",
			   placeholder: "dd-mm-yyyy HH:mm:ss",
			   alias: "datetime",
			   separator: "-",
			   hourFormat: "24"
		   });

		   $("input[id*='camarasDate1']").inputmask({
			   mask: "1-2-y h:s",
			   placeholder: "dd-mm-yyyy HH:mm",
			   alias: "datetime",
			   separator: "-",
			   hourFormat: "24"
		   });

		   $("input[id*='camarasDate2']").inputmask({
			   mask: "1-2-y h:s",
			   placeholder: "dd-mm-yyyy HH:mm",
			   alias: "datetime",
			   separator: "-",
			   hourFormat: "24"
		   });

		   /**** Event: OnClick check all elements at left grid ****/
		   loadGridCheckboxAll_event();

		   /**** Event: OnClick Load on click event remove button ****/
		   loadClickRemoveElementSelected_event();

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
		   currentPointerPositionDate = _TL_STARTDATE;

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
			   closeClick: true,

			   openEffect: 'elastic',
			   openSpeed: 150,

			   closeEffect: 'elastic',
			   closeSpeed: 150,
			   
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


           /*
		   $('[data-toggle="confirmation"]').confirmation();

$('[data-toggle="confirmation"]').confirmation({
placement: 'top', // How to position the confirmation - top | bottom | left | right
trigger: 'click', // How confirmation is triggered - click | hover | focus | manual
target : '_self', // Default target value if `data-target` attribute isn't present.
href   : '#', // Default href value if `data-href` attribute isn't present.
title: 'Are you sure?', // Default title value if `data-title` attribute isn't present
template: '<div class="popover">' +
				'<div class="arrow"></div>' +
				'<h3 class="popover-title"></h3>' +
				'<div class="popover-content text-center">' +
				'<div class="btn-group">' +
				'<a class="btn btn-small" href="" target=""></a>' +
				'<a class="btn btn-small" data-dismiss="confirmation"></a>' +
				'</div>' +
				'</div>' +
				'</div>',
btnOkClass:  'btn-primary', // Default btnOkClass value if `data-btnOkClass` attribute isn't present.
btnCancelClass:  '', // Default btnCancelClass value if `data-btnCancelClass` attribute isn't present.
btnOkLabel: '<i class="icon-ok-sign icon-white"></i> Yes', // Default btnOkLabel value if `data-btnOkLabel` attribute isn't present.
btnCancelLabel: '<i class="icon-remove-sign"></i> No', // Default btnCancelLabel value if `data-btnCancelLabel` attribute isn't present.
singleton: false, // Set true to allow only one confirmation to show at a time.
popout: false, // Set true to hide the confirmation when user clicks outside of it.
onConfirm: function(){}, // Set event when click at confirm button
onCancel: function(){}}) // Set event when click at cancel button



// Reveals an elements confirmation.
$('#element').confirmation('show')
// Hides an elements confirmation.
$('#element').confirmation('hide')
// Toggles an elements confirmation.
$('#element').confirmation('toggle')
// Hides and destroys an element's confirmation.
$('#element').confirmation('destroy')
*/
	   }); // END On Ready




	   function loadGlobalplay_settings() {

		   // ************* Globalplay Timer settings *************

		   var date_str1 = moment(_TL_STARTDATE, "DD-MM-YYYY HH:mm:ss");
		   var date_str2 = moment(_TL_ENDDATE, "DD-MM-YYYY HH:mm:ss");

		   var date1 = new Date(date_str1);
		   var date2 = new Date(date_str2);

		   var dif = date2.getTime() - date1.getTime();

		   var Seconds_from_T1_to_T2 = dif / 1000;
		   var Seconds_Between_Dates = Math.abs(Seconds_from_T1_to_T2);

		   GLOBALPLAY_seconds_total = Seconds_Between_Dates;

		   // Get duration format: HH:mm:ss
		   var total_sec_format = getFormatDuration(Seconds_Between_Dates);

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
				   try{
					   timer = (document.fbsviewer.getCurrTimeOffsetInMSec() / 1000).toString();
					   document.fbsviewer.pause();
				   }catch(err)
				   {
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
											   data: '{list_elements: "' +
												   list_elements + '"}',
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
												   var _hdnIsUpdateNeeded = $("input[id*='_hdnIsUpdateNeeded']");
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
												   $("span[id*='lblResultsCount']").text($("tr[id*='tape_']:visible").length.toString());

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
					   if (elementsInMemory != null) {
						   if (elementsInMemory.length > 0) {

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
			       left: $("#svg_timeframe").offset().left + 42 //Fix Left Offset 
			   })
		   }
	   }

	   // Event Drag & Drop: Stop Dragging
	   function handleDragStop(event, ui) {
		   var posX = ui.offset.left - $("#svg_timeframe").offset().left;
		   var position_date = window.timeframe_live.getTickDate(posX); // Datetime position - Formato: AÑO DIA MES
		   if (position_date != null) {
			   var position_date_str = moment(position_date, "YYYY-MM-DD HH:mm:ss");
			   currentPointerPositionDate = position_date_str.format('DD-MM-YYYY HH:mm:ss');

			   // Update popup dates: FileUpload and CommentUpload
			   $("#commentDate").val(currentPointerPositionDate);
			   $("input[id*='uploadDate']").val(currentPointerPositionDate);

			   /******** Globalplay ********/

			   // Set current timer
			   var start_date_str = moment(_TL_STARTDATE, "DD-MM-YYYY HH:mm:ss");

			   var position_date_final = new Date(position_date_str);
			   var start_date_final = new Date(start_date_str);

			   var dif = start_date_final.getTime() - position_date_final.getTime();

			   var Seconds_from_T1_to_T2 = dif / 1000;
			   var Seconds_Between_Dates = Math.abs(Seconds_from_T1_to_T2);

			   GLOBALPLAY_seconds_current = Seconds_Between_Dates;

			   // Clear global timer
			   $('#divGlobalplay_timer').timer('remove');

			   // Set global timer current progress
			   $('#divGlobalplay_timer').timer({
				   format: '%H:%M:%S',
				   seconds: Seconds_Between_Dates
			   });

			   // Set current timer
			   $("#lblGlobalplay_timer_current_longFormat").text(position_date_str.format('DD-MM-YYYY HH:mm:ss'));

			   // Pause global timer 
			   $('#divGlobalplay_timer').timer('pause');

			   // Set player mask pause
			   $("#globalplay_play").removeClass("pauseAudio");
			   $("#globalplay_play").addClass("play");
		   }
	   }

	   // Event Drag & Drop: Dragging
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
		   $(".box4.popbox4").offset({
			   left: posXfinal - 28, // 28 Quitar?
			   top: posYfinal
		   });
		   var date = window.timeframe_live.getTickDate(posX); // Datetime position - Formato: AÑO DIA MES
		   if (date != null) {
			   var date_str = moment(date, "YYYY-MM-DD HH:mm:ss");
			   $("#lblPopbox4").text(date_str.format('DD-MM-YYYY HH:mm:ss'));
		   }

		   /******** Globalplay ********/

		   // Stop timer 
		   globalplay_abort();
	   }


	   // Load Alert messages default values
	   function LoadAlertMessagesBackup() {

		   hashMessages = {};

		   hashMessages["ElementosBorrados"] = "Los elementos se borraron correctamente.";
		   hashMessages["SeleccioneElemento"] = "Por favor, seleccione un elemento del folio.";
		   hashMessages["ElementoBorrado"] = "Elemento correctamente borrado.";
		   hashMessages["UtilizarNavegador1"] = "Por favor, utilice Firefox o IE para continuar con esta función.";
		   hashMessages["UtilizarNavegador2"] = "Por favor, utilice Firefox o IE para reproducir este elemento.";
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

	   }

	   function initVariables() {

		   TIMELINE_POINTER = $("#sm2-progress-ball_TIMELINE");
		   PLAYER_BOX = $("div[id*='playerBox");

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

		   var text = " <%:Session["UserName"]%>, " + currentDateToday;
		   $('.usernameInfo').html(text);

		   // Load alert message: Get Max Elements download from web.config
		   MaxElementsDownload = "6";
		   var _hdnMaxElementsDownload = $("input[id*='_hdnMaxElementsDownload']");
		   if (_hdnMaxElementsDownload != null && _hdnMaxElementsDownload.val() != null && _hdnMaxElementsDownload.val().length > 0) {
			   MaxElementsDownload = _hdnMaxElementsDownload.val();
		   }

		   // Load Globalplay default duration on elements 
		   GLOBALPLAY_DEFAULT_DURATION = "6000";
		   var _hdnGlobalplay_defaultDuration = $("input[id*='_hdnGlobalplay_defaultDuration']");
		   if (_hdnGlobalplay_defaultDuration != null && _hdnGlobalplay_defaultDuration.val() != null && _hdnGlobalplay_defaultDuration.val().length > 0) {
			   GLOBALPLAY_DEFAULT_DURATION = _hdnGlobalplay_defaultDuration.val();
		   }
	   }

	   function loadHiddenFields() {

		   // IS INCONCERT - EXTRA ------------

		   // WS: /RecordingIntegration/WebServices
		   // param 1: id --> segmentID
		   // param 1: isExtra --> 0/1

		   // Get INCONCERT SERVER from web.config
		   WS_InConcert_Server = "http://192.168.10.31";
		   var _hdnWS_InConcert_Server = $("input[id*='_hdnWS_InConcert_Server']");
		   if (_hdnWS_InConcert_Server != null && _hdnWS_InConcert_Server.val() != null && _hdnWS_InConcert_Server.val().length > 0) {
			   WS_InConcert_Server = "http://" + _hdnWS_InConcert_Server.val();
		   }

		   // Get INCONCERT WS PORT from web.config
		   WS_InConcert_Port = "8081";
		   var WS_Port = $("input[id*='_hdnWS_InConcert_Port']");
		   if (WS_Port != null && WS_Port.val() != null && WS_Port.val().length > 0) {
			   WS_InConcert_Port = WS_Port.val();
		   }

		   // Get INCONCERT WS URL from web.config
		   WS_InConcert_URL_download = "/RecordingIntegration/WebServices/Download.aspx";
		   var WS_URL = $("input[id*='_hdnWS_InConcert_URL_download']");
		   if (WS_URL != null && WS_URL.val() != null && WS_URL.val().length > 0) {
			   WS_InConcert_URL_download = WS_URL.val();
		   }

		   // IS OREKA ------------
		   // Get OREKA SERVER from web.config
		   WS_Oreka_Server = "http://192.168.10.31";
		   var _hdnWS_Oreka_Server = $("input[id*='_hdnWS_Oreka_Server']");
		   if (_hdnWS_Oreka_Server != null && _hdnWS_Oreka_Server.val() != null && _hdnWS_Oreka_Server.val().length > 0) {
			   WS_Oreka_Server = "http://" + _hdnWS_Oreka_Server.val();
		   }

		   // Get OREKA WS PORT from web.config
		   WS_Oreka_Port = "8080";
		   var _hdnWS_Oreka_Port = $("input[id*='_hdnWS_Oreka_Port']");
		   if (_hdnWS_Oreka_Port != null && _hdnWS_Oreka_Port.val() != null && _hdnWS_Oreka_Port.val().length > 0) {
			   WS_Oreka_Port = _hdnWS_Oreka_Port.val();
		   }

		   // Get OREKA WS URL from web.config
		   WS_Oreka_URL = "/icweb/replay";
		   var _hdnWS_Oreka_URL = $("input[id*='_hdnWS_Oreka_URL']");
		   if (_hdnWS_Oreka_URL != null && _hdnWS_Oreka_URL.val() != null && _hdnWS_Oreka_URL.val().length > 0) {
			   WS_Oreka_URL = _hdnWS_Oreka_URL.val();
		   }

		   // Get FBS Default screen properties
		   FBS_DEFAULT_Width = "557px", FBS_DEFAULT_Height = "390px";
		   var vWidth = $("input[id*='_hdnFbs_width']");
		   var vHeight = $("input[id*='_hdnFbs_height']");
		   if (vWidth != null && vWidth.val().length > 0 && vHeight != null && vHeight.val().length > 0) {
			   FBS_DEFAULT_Width = vWidth.val();
			   FBS_DEFAULT_Height = vHeight.val();
		   }

		   // Get FBS Fullscreen screen properties
		   FBS_FULLSCREEN_Width = "557px", FBS_FULLSCREEN_Height = "390px";
		   var vWidth1 = $("input[id*='_hdnPlayerFBS_fullscreen_width']");
		   var vHeight1 = $("input[id*='_hdnPlayerFBS_fullscreen_height']");
		   if (vWidth1 != null && vWidth1.val().length > 0 && vHeight1 != null && vHeight1.val().length > 0) {
			   FBS_FULLSCREEN_Width = vWidth1.val();
			   FBS_FULLSCREEN_Height = vHeight1.val();
		   }

		   // Get FBS Popup screen properties
		   FBS_POPUP_Width = "1366", FBS_POPUP_Height = "768";
		   var vWidth2 = $("input[id*='_hdnPlayerFBS_popup_width']");
		   var vHeight2 = $("input[id*='_hdnPlayerFBS_popup_height']");
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

	   //#region JS Methods 1: runTableVisualEffect | openFullscreen | closeFullscreen | openUploadModal | addCommentClick | removeElement | closeModal 

	   // Change Roles and Types filter checkboxes to checked value 
	   function checkRolesAndTypesFilters() {
		   $("#divTypes input:not(:checked)").click()
		   $("#divRoles input:not(:checked)").click()
	   }

	   // Show visual effect on loading the left grid
	   function runTableVisualEffect(show) {
		   if (show) {
			   $("#tblLeftGridElements").show("blind", 1900);
		   }
	   }

	   function openFullscreen() {

		   if (elementType_active === "S") {

			   /* ------------------  SCREEN RECORDING CASE ------------------ */
			   // http://stackoverflow.com/questions/22248670/html-object-tag-data-attribute-wont-update-with-jquery-change

			   var light = $("#light");
			   var fade = $("#fade");
			   var divPlayer_VIDEO = $("#divPlayer_VIDEO");
			   var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");

			   if (light != null && light.length && fade != null && fade.length && divPlayer_VIDEO != null && divPlayer_VIDEO.length && divControlsMask_VIDEO != null && divControlsMask_VIDEO.length) {

				   /*
				   // -------------------------------------------------------------
				   var w = MONITOR_WIDTH - (MONITOR_WIDTH * 40 / 100);
				   var h = MONITOR_HEIGHT - (MONITOR_HEIGHT * 40 / 100);

				   $("#fbsviewer").attr('width', w);
				   $("#fbsviewer").attr('height', h);

				   light.css('width', '80%');
				   light.css('height', '80%');

				   //light.css('top', '10%');
				   //light.css('left', '10%');

				   ///
				   light.css('position', 'fixed');
				   light.css('top', '50%');
				   light.css('left', '50%');

				   var t1 = parseInt(light.css('top'), 10);
				   light.css('top', t1 + 'px');

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
				   */

				   //$("#aOpenWindow_fullscreen").attr("href", "")
			   }

		   } else if (elementType_active === "I") {

			   /* ------------------  IMAGE CASE ------------------ */
			   $("#imgPlayer").photobox();
			   $("#imgPlayer").click();
			   // Remove all images but first
			   $("#photobox-container img").not(":first").remove();
			   $("#photobox-container").css("z-index", "10");

		   } else if (elementType_active === "V") {

			   /* ------------------  VIDEO CASE ------------------ */
			   var light = $("#light");
			   var fade = $("#fade");
			   var divPlayer_VIDEO = $("#divPlayer_VIDEO");
			   var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");

			   if (light != null && light.length && fade != null && fade.length && divPlayer_VIDEO != null && divPlayer_VIDEO.length && divControlsMask_VIDEO != null && divControlsMask_VIDEO.length) {

					   var w = MONITOR_WIDTH - (MONITOR_WIDTH * 40 / 100);
					   var h = MONITOR_HEIGHT - (MONITOR_HEIGHT * 40 / 100);

					   document.getElementById("webchimera").width = w;
					   document.getElementById("webchimera").height = h;

					   light.css('width', '70%');
					   light.css('height', '80%');

						///
					   light.css('position', 'fixed');
					   light.css('top', '50%');
					   light.css('left', '50%');

					   var t1 = parseInt(light.css('top'), 10);
					   light.css('top', t1 + 'px');

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
	   }

	   function closeFullscreen() {
		   var light = $("#light");
		   var fade = $("#fade");
		   var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");
		   var divPlayer_VIDEO = $("#divPlayer_VIDEO");

		   if (elementType_active === "A" || elementType_active === "I") {

			   if (light != null && light.length && fade != null && fade.length && PLAYER_BOX != null && PLAYER_BOX.length && divControlsMask_VIDEO != null && divControlsMask_VIDEO.length && divPlayer_VIDEO != null && divPlayer_VIDEO.length) {

				   // Move player and banner to div container
				   divControlsMask_VIDEO.appendTo(PLAYER_BOX);
				   divPlayer_VIDEO.appendTo(PLAYER_BOX);

				   // styles
				   light.css('display', 'none');
				   fade.css('display', 'none');
				   divControlsMask_VIDEO.css('height', '54px');
			   }
		   }
		   else if (elementType_active === "S") {

			   if (light != null && light.length && fade != null && fade.length && PLAYER_BOX != null && PLAYER_BOX.length && divControlsMask_VIDEO != null && divControlsMask_VIDEO.length && divPlayer_VIDEO != null && divPlayer_VIDEO.length) {

				   // -------------------------------------------------------------
				   $("#fbsviewer").attr('width', FBS_DEFAULT_Width);
				   $("#fbsviewer").attr('height', FBS_DEFAULT_Height);
				   
				   // -------------------------------------------------------------

				   // Move player and banner to div container
				   divControlsMask_VIDEO.appendTo(PLAYER_BOX);
				   divPlayer_VIDEO.appendTo(PLAYER_BOX);

				   // styles
				   light.css('display', 'none');
				   fade.css('display', 'none');
				   divControlsMask_VIDEO.css('height', '54px');

			   }
		   }
		   else if (elementType_active === "V") {

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
			   
			   // Webchimera player size
			   var divPlayer_VIDEO_w = parseInt(divPlayer_VIDEO.css("width"), 10);
			   var divPlayer_VIDEO_h = parseInt(divPlayer_VIDEO.css("height"), 10);

			   document.getElementById("webchimera").width = divPlayer_VIDEO_w;
			   document.getElementById("webchimera").height = divPlayer_VIDEO_h;
		   }
	   }

	   function addCommentClick() {

		   // Check if folio is selected
		   var folioID = 0;
		   var _hdnFolioID = $("input[id*='_hdnFolioID']");
		   if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {
			   folioID = _hdnFolioID.val();
		   }
		   var folioID_int = parseInt(folioID, 10);

		   if (folioID_int != null && !isNaN(folioID_int) && folioID_int > 0) {

			   if (!$('#btnAddComment').hasClass("opened")) {
				   var posXoff = $("#btnAddComment").offset().left;
				   var posYoff = $("#btnAddComment").offset().top + 60;
				   $('.popbox').popbox();
				   $("#txbComment").val("");
				   $("#txbComment").focus();

				   // Hide other popups
				   $(".box2.popbox2").hide();
				   var date_str = moment(currentPointerPositionDate, "DD-MM-YYYY HH:mm:ss");
				   $("#commentDate").val(date_str.format('DD-MM-YYYY HH:mm:ss'));
				   $(".jslider-pointer").css("left", "0%");

				   // Popup styles
				   $(".box.popbox").show("highlight", 700);

				   var pop_w = parseInt($(".box.popbox").css("width"), 10);
				   var arrow_w = parseInt($(".box.popbox .arrow").css("width"), 10);
				   var btn_w = parseInt($("#btnAddComment").css("width"), 10);

				   //$(".box.popbox").offset({ left: posXoff });
				   $(".box.popbox").offset({ left: posXoff - pop_w + (btn_w / 2) + (arrow_w/2) });
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
				   $("span[id*='lblResultsCount']").text($("tr[id*='tape_']:visible").length.toString());
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
		   $("ul[id='nav_tabs1']").find('li').removeClass("active");
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
		   $("ul[id='nav_popbox2']").find('li').removeClass("active");
		   $(caller).addClass("active");
		   var type = $(caller).attr("id");
		   if (type != null) {
			   $("#divUpload").hide();
			   $("#divCamaras").hide();
			   if (type === "liUpload") {
				   $("#divUpload").show();

				   // Clear tab values
					$("input[id*='MyFileUpload']").val("");
			   } else if (type === "liCamera") {
				   $("#divCamaras").show();

				   // Clear tab values
					$("input[id*='txbInputCameraNumber']").val("");
			   }
		   }
	   }

	   function setCurrentPointerPositionDate(event) {
		   var target = event.target;
		   var x = getClickPosition1(event); // Click position
		   var date = window.timeframe_live.getTickDate(x); // Datetime position
		   if (date != null) {
			   var date_str = moment(date, "YYYY-MM-DD HH:mm:ss");
			   currentPointerPositionDate = date_str.format('DD-MM-YYYY HH:mm:ss');
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

		   TIMELINE_POINTER.hide();
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

		   // If timeline is already drawn, set to divTimelineProgress the main line real width 
		   divTimelineProgress_SetWidth();
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
			               var ELEMENT = $("#timeframe #tlTape_" + tapeID);
			               var ELEMENT_rect = $("#timeframe #tlTape_" + tapeID + " > rect");
			               var ELEMENT_text = $("#timeframe #tlTape_" + tapeID + " > text");

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
			                           if (ELEMENT_rect != null && ELEMENT_rect
										   .length) {
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
			                           if (ELEMENT_rect != null && ELEMENT_rect
										   .length) {
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


			   //$("#playerContainer").offset({ top: $("#timeframe").offset().top + 10 })
			   //$("#playerContainer").css("height", MAIN_LINE_height);

		   }
	   }

	   // Send element details
	   function fire_event(event) {
		   $("button[name='btnTimelineElement']").removeClass("active");
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
		   var border_start = $("line[name='timeframe_start']");
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

			   // rect
			   $("#timeframe g[type_name='" + objects[obj] + "'] > rect").attr("y", initial_top);
			   $("#timeframe g[type_name='" + objects[obj] + "'] > rect").attr("height", basic_height);

			   // text
			   $("#timeframe g[type_name='" + objects[obj] + "'] > text").attr("y", initial_top - 7);
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
		   $("button[name='btnTimelineElement']").css("background-color", color_str);
		   $("g[id^='tlTape_']").attr("fill", color_str);
	   }

	   function paintSelectionClick(tapeID, timestamp) {

		   /******** Clear other element styles ********/

		   // Left panel
		   $("button[name='btnTimelineElement']").removeClass("active");
		   $("tr[id*='tape_'] > td > h5").attr("style", "color:black;");
		   $("tr[id*='tape_']").css("background-color", "white");

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
		   var vBottom_text = $("#timeframe #tlTape_" + tapeID + " > text");
		   var vBottom_rect = $("#timeframe #tlTape_" + tapeID + " > rect");
		   if (vBottom_text != null && vBottom_text.length && vBottom_rect !=
			   null && vBottom_rect.length) {
			   vBottom_text.attr("fill", "DodgerBlue ");
			   vBottom_rect.attr("stroke", "DodgerBlue ");
			   vBottom_rect.attr("stroke-width", 4);
			   vBottom_rect.attr("stroke-opacity", 0.9);
		   }

		   // Set Selected element
		   /*
		   selectedElementID = tapeID;
		   timeline_pointer_setLocation(tapeID);
		   */

		   // Set current pointer date, to the add-comment & upload-file functions
		   currentPointerPositionDate = timestamp; 
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

		   if (TIMELINE_POINTER != null && sm2_inline_element != null && sm2_inline_element.length &&
			   sm2_progress_bd != null && sm2_progress_bd.length && sm2_progress != null && sm2_progress.length &&
			   sm2_progress_track != null && sm2_progress_track.length && timeline != null) {

			   TIMELINE_POINTER.show();

			   // Check if if exists at least one element
			   if (tapeID > 0) {
				   var vElement = $("#timeframe #tlTape_" + tapeID);
				   var vElementRect = $("#timeframe #tlTape_" + tapeID + " > rect");

				   // Check if timeline is already drawn
				   if (vElement != null && vElement.length && vElementRect != null && vElementRect.length) {

					   // Set progress bar width
					   var _width_int = parseInt(vElementRect.attr('width'), 10);
					   var _width_percentage = (5 / 100) * _width_int;
					   var _width = _width_int + _width_percentage + "px";

					   sm2_progress_bd.css("padding", "0px");

					   sm2_progress.css('height', 15);

					   sm2_inline_element.css('width', _width);

					   var MAIN_LINE = $("#svg_timeframe > g:first > line:first");
					   if (MAIN_LINE != null && MAIN_LINE.length) {
					       sm2_inline_element.offset({ left: MAIN_LINE.offset().left });
					   }

					   //sm2_inline_element.offset({ left: vElementRect.offset().left });

					   sm2_progress_bd.css('width', _width);

					   sm2_progress_bd.css('left', _width);

					   sm2_progress_track.css('height', 15);

					   // Pointer left and top position
					   //TIMELINE_POINTER.offset({ left: vElement.offset().left });

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
		   var btnConfirmRemoveElement = $("button[id*='btnConfirmRemoveElement");
		   var divRemoveElementMessage = $("div[id*='divRemoveElementMessage");
		   var aPlayPause_AUDIO = $("#aPlayPause_AUDIO");
		   var aPlayPause_VIDEO = $("#aPlayPause_VIDEO");
		   var lnkSound_AUDIO = $("#lnkSound_AUDIO");
		   var lnkSound_VIDEO = $("#lnkSound_VIDEO");

		   // Get file extension
		   var file_extension = getFileExtension(fileName);

		   /************************ General variables END ************************/

		   /************************ General events START ************************/
		   elementType_active = "";

		   // Remove click event
		   aPlayPause_VIDEO.attr('onclick', '');
		   aPlayPause_VIDEO.off("click");

		   // Clear previous onclick events
		   lnkElementDownload.attr('onclick', '');
		   lnkElementDownload.off("click");

		   // Load on click event to download element link
		   if (type_longStr != "Comentario") {
			   var filePath_str = "";

			   // If audio is from incextras (isExtra = true) then use localPath, if not use oreka web service

			   //////////////////////////////////////////////////////////////////////////////////////////
			   //////////////////////////////////   DOWNLOAD FILE URL   /////////////////////////////////
			   //////////////////////////////////////////////////////////////////////////////////////////

			   if (isExtra.toLowerCase() === "true") {
				   filePath_str = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=1";

			   } else {

				   //filePath_str = WS_Oreka_Server + ":" + WS_Oreka_Port + WS_Oreka_URL + "?segid=" + segmentID;
				   filePath_str = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download + "?id=" + segmentID + "&isExtra=0";
			   }
			   lnkElementDownload.attr("href", filePath_str);
		   }

		   // ------- Remove element click

		   // Clear previous onclick or click events
		   btnRemoveElement.attr('onclick', '');
		   btnRemoveElement.off("click");

		   /**** Event: OnClick Load on click event remove button (btnRemoveElement) ****/
		   loadClickRemoveButton_event();

		   divRemoveElementMessage.text("Está a punto de borrar el elemento, confirme su contraseña para continuar");
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
		   $("#btnFullscreen").addClass("disabled");
		   $("#aBtnFullscreen").addClass("disabled");

		   // If the element is PROCESSING or ERROR 
		   if (fileStatus === "PROCESSING" || fileStatus === "ERROR") {
			   $("#lnkElementDownload").addClass("disabled");
			   $("#btnFullscreen").addClass("disabled");
			   $("#aBtnFullscreen").addClass("disabled");
		   }

		   // Show sound player
		   //       divControlsMask_VIDEO.show("blind", 200); ****

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

		   $("#audioContainer object").remove();


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

		   var duration_str = duration;
		   if (duration == 0) {
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
		   if (isExtra.toLowerCase() === "true") {
			   file_url = filePath_EXTRA;
		   }

		   /************************ Elements path configuration END ************************/

		   /************************ LOAD ELEMENT on Player BEGIN ************************/

		   switch (tapeType) {
			   case "S":
			   case "P": {
				   elementType_active = "S";
				   loadElement_screenRecording(file_url, tapeID, fileStatus, divControlsMask_AUDIO, duration, divPlayer_VIDEO, fileName, segmentID, divControlsMask_VIDEO);
				   break;
			   }

			   case "A": {
				   elementType_active = "A";
				   loadElement_audio(file_url, divControlsMask_AUDIO, fileName, lnkSound_AUDIO, file_extension, tapeID);
				   break;
			   }

			   case "C": {
				   elementType_active = "C";
				   loadElement_comment(divControlsMask_VIDEO, timestamp, fileName);
				   break;
			   }

			   case "I": {
				   elementType_active = "I";
				   loadElement_image(file_url, divControlsMask_VIDEO, divControlsMask_AUDIO, fileStatus);
				   break;
			   }

			   case "D": {
				   elementType_active = "D";
				   loadElement_document(divControlsMask_VIDEO, divControlsMask_VIDEO);
				   break;
			   }

			   case "V": {
				   elementType_active = "V";
				   loadElement_video(file_url, divPlayer_VIDEO, divControlsMask_VIDEO, file_extension, divControlsMask_AUDIO, aPlayPause_VIDEO, fileName, duration);
				   break;
			   }
		   }

		   /************************ Load element on Player END ************************/
	   }

	   //********************************* 1. SCREEN RECORDING Element *********************************
	   function loadElement_screenRecording(file_url, tapeID, fileStatus, divControlsMask_AUDIO, duration, divPlayer_VIDEO, fileName, segmentID, divControlsMask_VIDEO) {
		   if (getIsFirefoxOrIE()) {
			   screenRecording_segmentID = tapeID;

			   SetAudioPlaylistURL(1, "");

			   // Enable/Disable functions
			   if (fileStatus != "PROCESSING" && fileStatus != "ERROR") {
				   $("#btnFullscreen").removeClass("disabled");
				   $("#aBtnFullscreen").removeClass("disabled");
				   $("#divControlsMask_VIDEO").removeClass("disabled");
				   $("#lnkElementDownload").removeClass("disabled");
			   } else {
				   $("#btnFullscreen").addClass("disabled");
				   $("#aBtnFullscreen").addClass("disabled");
				   $("#divControlsMask_VIDEO").addClass("disabled");
				   $("#lnkElementDownload").addClass("disabled");
			   }

			   currrentVideoDuration = duration;

			   /************************ Events START ************************/

			   // Click over progress bar 
			   // Video player
			   $("#sm2-progress-track_VIDEO").on("click", { _duration: duration, _d: $(this) }, setVideoCurrent);

			   // Bottom progress track

			   $("#sm2-progress-track").on("click", { _duration: duration }, setVideoCurrent);

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

		   } else { // It is not Firefox

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
	   }

	   //************************************** 2. AUDIO Element ***************************************
	   function loadElement_audio(file_url, divControlsMask_AUDIO, fileName, lnkSound_AUDIO, file_extension, tapeID) {

		   /************************ Local audio variables ************************/

		   // Clear Audio and Video player
		   emptyAudioPlayer();
		   emptyVideoPlayer();

		   // Remove previous error messages from the audio player
		   $(".load-error").remove();

		   // Show sound player
		   if (divControlsMask_AUDIO != null && divControlsMask_AUDIO.length) {
			   divControlsMask_AUDIO.show("blind", 200);
		   }

		   // Set title
		   $("#lblSoundTitle1_AUDIO, #lblSoundTitle2_AUDIO").text(fileName);

		   // Prepare audio player
		   lnkSound_AUDIO.attr("href", file_url);
		   SetAudioPlaylistURL(0, file_url);

		   // Set Stop icon
		   if (divControlsMask_AUDIO != null && divControlsMask_AUDIO.length > 0) {
			   if (divControlsMask_AUDIO.hasClass("playing")) {
				   divControlsMask_AUDIO.addClass("paused");
				   divControlsMask_AUDIO.removeClass("playing");
			   }
			   divControlsMask_AUDIO.on("click", { _tapeID: tapeID }, playAudioElement);
		   }
		   // Set background image
		   loadPlayerBoxImage("url(assets/images/audio.png)");


		   /* Important: ----------- PCM WAVE Case: Only for IE cases because it does not reproduce WAV files ----------- */
		   if ((file_extension != null && file_extension.length > 0 && file_extension[0] === "wav" || file_extension[0] === "crypt") && getIsIE()) {

			   // Create avi player
			   var w = parseInt($("#divControlsMask_AUDIO").css("width"), 10);
			   var h = parseInt($("#divControlsMask_AUDIO").css("height"), 10);

			   // Source: http://joliclic.free.fr/html/object-tag/en/

			   // ActiveX object
			   var wav_object = "<object data='" + file_url + "' type='audio/x-wav' width='" + w + "' height='" + h + "'>";
			   wav_object += " <param name='src' value='" + file_url + "'>";
			   wav_object += " <param name='autoplay' value='false'>";
			   wav_object += " <param name='autoStart' value='0'>";
			   wav_object += " <a href='" + file_url + "'>Play</a>";
			   wav_object += " </object>";

			   $("#audioContainer object").remove();
			   $("#audioContainer").append(wav_object);
			   divControlsMask_AUDIO.hide();
		   }
		   /* Important: ----------- PCM WAVE - Case ----------- */
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

	   //************************************** 6. VIDEO Element ***************************************
	   function loadElement_video(file_url, divPlayer_VIDEO, divControlsMask_VIDEO, file_extension, divControlsMask_AUDIO, aPlayPause_VIDEO, fileName, duration, fileStatus) {

		   var ok = true;

		   // Webchimera plugin - Source: https://github.com/LukasBombach/nw-webchimera-demos

		   /************************ Styles START ************************/

		   var manual_offset = 52;
		   divPlayer_VIDEO.show();
		   divPlayer_VIDEO.css("height", (parseInt(PLAYER_BOX.css("height"), 10) - manual_offset - 2) + "px");

		   divControlsMask_VIDEO.show();

		   divPlayer_VIDEO.offset({ top: PLAYER_BOX.offset().top + manual_offset });

		   // Create video player
		   var w = parseInt(divPlayer_VIDEO.css("width"), 10);
		   var h = parseInt(divPlayer_VIDEO.css("height"), 10);

		   // HTML5 video supported formats
		   if (file_extension != null && file_extension.length > 0 && file_extension[0] === "mp4" ||
               file_extension[0] === "webm" || file_extension[0] === "ogg") {

			   // HTML5 video tag Source: https://www.w3.org/2010/05/video/mediaevents.html

			   var js_player = '<video id="html_video" preload="none" style="width: ' + w + 'px; height: ' + h + 'px;">';
			   //js_player += '<source id="mp4" src="http://media.w3.org/2010/05/bunny/trailer.mp4" type="video/mp4">'; // p
			   js_player += '<source id="mp4" src="' + file_url + '" type="video/mp4">';
			   js_player += '<source id="webm" src="' + file_url + '" type="video/webm">';
			   js_player += '<source id="ogv" src="' + file_url + '" type="video/ogg">';
			   js_player += '</video>';

			   divPlayer_VIDEO.append(js_player);


			   /************************ Events START ************************/

			   // Clear previous onclick events
			   aPlayPause_VIDEO.attr('onclick', '');
			   $("#aPlayPause_VIDEO").off("click");

			   // Click on Play icon VIDEO
			   $("#aPlayPause_VIDEO").bind("click", function () {

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
			   var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");

			   // Event: While Playing
			   $("#html_video").on("timeupdate", function (event) {
				   onTrackedVideoFrame(this.currentTime, this.duration, timer_VIDEO, divControlsMask_VIDEO);
			   });


			   /*
			   // TODO
			// Bottom progress track
				   $("#sm2-progress-track").on("click", {
					   _duration: duration
				   }, setVideoCurrent);


			   */

			   /************************ Events END ************************/

		   }
		   else {

			   // INIT webchimera
			   if (getIsFirefoxOrIE()) {


				   // -----------------------------------------------------------------------------------------------

				   var applet = "<object id='webchimera1' type='application/x-chimera-plugin' width='" + w + "' height='" + h + "'>";
				   applet += "<param name='windowless' value='true' />";
				   applet += "</object>";
				   applet += "<div id='interface'></div>";

				   $("#divPlayer_VIDEO object").remove();
				   divPlayer_VIDEO.append(applet);

				   // If it does not fail to load webchimera plugin
				   var ok = true;

				   try {
					   wjs("#webchimera1").clearPlaylist();
					   wjs("#webchimera1").addPlaylist(file_url);
				   } catch (err) {
					   console.log("Error loading webchimera");
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


				   // Clear previous onclick events
				   aPlayPause_VIDEO.attr('onclick', '');
				   $("#aPlayPause_VIDEO").off("click");

				   //setTimeout(function () {
				   // Source: http://wiki.webchimera.org/Player_JavaScript_API

				   // Click on Play icon VIDEO
				   $("#aPlayPause_VIDEO").bind("click", function () {

					   if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {

						   if (divControlsMask_VIDEO.hasClass("paused")) {
							   divControlsMask_VIDEO.addClass("playing");
							   divControlsMask_VIDEO.removeClass("paused");
							   wjs("#webchimera1").play();

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
					   var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");
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


				   // }, 1000); // SetTimeout

				   // Bottom progress track
				   $("#sm2-progress-track").on("click", {
					   _duration: duration
				   }, setVideoCurrent);

				   /************************ Events END ************************/



			   } else {
				   ok = false;
			   }

		   } // END webchimera


		   // -----------------------------------------------------------------------------------------------

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
		   $("#sm2-progress-track_VIDEO").on("click", { _duration: duration, _d: $(this) }, setVideoCurrent);
		   // Bottom progress track
		   $("#sm2-progress-track").on("click", { _duration: duration }, setVideoCurrent);



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

		   //#endregion
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

					   // Update current timer label to reach the maximum
					   timer_VIDEO.text(max_time);
				   }
			   }
		   }
	   }

	   /**** Event: OnClick Load on click event remove button (btnRemoveElement) ****/
	   function loadClickRemoveButton_event(){
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

		   var btnConfirmRemoveElement = $("button[id*='btnConfirmRemoveElement");
		   var divPanel_PlayerControl = $("#divPanel_PlayerControl");
		   var divRemoveElementMessage = $("div[id*='divRemoveElementMessage");

		   btnConfirmRemoveElement.bind("click", function () {

			   var userID = '<%= Session["UserID"] %>';
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
							   var _hdnIsUpdateNeeded = $("input[id*='_hdnIsUpdateNeeded']");
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
							   $("span[id*='lblResultsCount']").text($("tr[id*='tape_']:visible").length.toString());

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

	   function SetAudioPlaylistURL(number, vURL){
		   var player = window.sm2BarPlayers[number]; // Collection priority
		   if (player != null && player.playlistController && player.playlistController.getSoundObject()) {

			   // ToDo: Research this.
			   /* Workaround: sometimes SoundManager.js uses ._iO object to reproduce the audio, and other times uses the object returned by getSoundObject() directly */
				if (player.playlistController.getSoundObject()._iO != null && player.playlistController.getSoundObject()._iO &&
					player.playlistController.getSoundObject()._iO.url != null){
					player.playlistController.getSoundObject()._iO.url = vURL;
				}
				if (player.playlistController.getSoundObject().url != null && player.playlistController.getSoundObject().url) {
					player.playlistController.getSoundObject().url = vURL;
				}
			}
	   }

	 function setVideoCurrent(event) {
		 getClickPosition(event, event.data._duration);
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

	 function getClickPosition(e, duration) {
		 var parentPosition = getPosition3(e.currentTarget);
		 var xPosition = e.clientX - parentPosition.x;
		 var yPosition = e.clientY - parentPosition.y;
		 var sm2_progress_track_VIDEO = $("#sm2-progress-track_VIDEO");

		 if (sm2_progress_track_VIDEO != null && sm2_progress_track_VIDEO.length) {
			 var left_percentage = parseInt(xPosition / parseInt(sm2_progress_track_VIDEO.css("width"), 10) * 100, 10);
			 var currentSecs = left_percentage * duration / 100;
			 if (elementType_active === "S") {
				 if (document.fbsviewer != null) {
					 document.fbsviewer.seekViewerSeconds(currentSecs);
				 }
			 } else {
				 // TODO: adapt to html5 video - flowplayer

				 if (elementType_active === "V") {
					 if (wjs("#webchimera1") != null) {
						 wjs("#webchimera1").time(currentSecs);
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
		 var aPlayPause_VIDEO = $("#aPlayPause_VIDEO");
		 var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");
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
								 console.log(err);
							 }
						 }
					 }
				 });
			 } else {
				 // If it is playing audio
				 if (divControlsMask_VIDEO != null && divControlsMask_VIDEO.length > 0) {

					 // If it is paused
					 //if (divControlsMask_VIDEO.hasClass("paused")) {
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

		 //var applet = "<applet codebase='assets/applets/' code='OrkMP.class' archive='OrkMP.jar' width='" + FBS_DEFAULT_Width + "' height='" + FBS_DEFAULT_Height + "' name='fbsviewer' id='fbsviewer' title='undefined'>";         

		 // Toma resolución del div contenedor (PLAYER_BOX)

		 playerBox_w = parseInt(PLAYER_BOX.css("width"), 10);
		 playerBox_h = parseInt(PLAYER_BOX.css("height"), 10);

		 var left_offset = 25;
		 var top_offset = 6;
		 var divWidth = playerBox_w - left_offset;
		 var divHeight = playerBox_h - top_offset;

		 var filePath_OREKA = WS_Oreka_Server + ":" + WS_Oreka_Port + WS_Oreka_URL + "?segid=" + segmentID;

		 // filePath_OREKA = 'http://192.168.20.225:8080/icweb/replay?segid=1'; // TEST !!

		 var applet = "<applet codebase='assets/applets/' code='OrkMP.class' archive='OrkMP.jar' width='" + divWidth + "px' height='" + divHeight + "px' name='fbsviewer' id='fbsviewer' title='undefined'>";

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
		 applet += "</applet>";

		$("#divPlayer_VIDEO applet").remove();
		$("#divPlayer_VIDEO").append(applet);

		 // Stop FBS player if it is playing
		 //stopFBSPlayer();
		 try {
			 if (document.fbsviewer != null) {
				 document.fbsviewer.pause();
			 }
		 } catch (err) {
			 console.log("Oreka Player (.fbs) error try catch");
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
			 console.log("Oreka Player (.fbs) error try catch");
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
		 //if (playVideo_ok)
		 {
			 var timer_VIDEO = $('#sm2-inline-time_VIDEO');
			 var pointer_VIDEO = $('#sm2-progress-ball_VIDEO');
			 var divControlsMask_VIDEO = $("#divControlsMask_VIDEO");

			 if (document.fbsviewer != null) {

				 var currentSecs = document.fbsviewer.getCurrTimeOffsetInMSec() / 1000;

				 //Si supero los segundos totales, o detecto que el tiempo fue para atras, asumo que termino y dejo de refrecar
				 if (currentSecs < totalDurationSecs && currentSecs >= previousSecs){ // && currentSecs != 0) {

					 //if (currentSecs <= totalDurationSecs && currentSecs >= previousSecs && currentSecs !=0) {
					 previousSecs = currentSecs;

					 var left = Math.round(100 * currentSecs / totalDurationSecs) + "%";
					 var secs_int = parseInt(currentSecs, 10);
					 var timer = getTime(document.fbsviewer.getCurrTimeOffsetInMSec(), true).toString();

					 timer_VIDEO.text(timer);

					 // Pointers progress
					 pointer_VIDEO.css("left", left);

					 /*
					 TIMELINE_POINTER.show();
					 TIMELINE_POINTER.css("left", left);
					 */

					 //divControlsMask_VIDEO.addClass("playing");
					 playVideo_ok = true;
					 setTimeout(function () {
						 TimeRefreshLoop(totalDurationSecs)
					 }, 1000); //1000

					 // doTimeout Source: http://benalman.com/code/projects/jquery-dotimeout/examples/delay-poll/
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
		 var folioID = 0;
		 var _hdnFolioID = $("input[id*='_hdnFolioID']");
		 if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {
			 folioID = _hdnFolioID.val();
		 }
		 var folioID_int = parseInt(folioID, 10);
		
		 if (folioID_int != null && !isNaN(folioID_int) && folioID_int > 0) {

			 if (!$('#btnUploadElement').hasClass("opened")) {
				 var posXoff = $("#btnUploadElement").offset().left;
				 var posYoff = $("#btnUploadElement").offset().top + 60;

				 var date_str = moment(currentPointerPositionDate, "DD-MM-YYYY HH:mm:ss");

				 $("input[id*='uploadDate']").val(date_str.format('DD-MM-YYYY HH:mm:ss'));
				 $("input[id*='camarasDate1']").val(date_str.format('DD-MM-YYYY HH:mm:ss'));
				 $("input[id*='camarasDate2']").val(date_str.format('DD-MM-YYYY HH:mm:ss'));

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
		 var folioID = 0;
		 var _hdnFolioID = $("input[id*='_hdnFolioID']");
		 if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {
			 folioID = _hdnFolioID.val();
		 }
		 var folioID_int = parseInt(folioID, 10);

		 if (folioID_int != null && !isNaN(folioID_int) && folioID_int > 0) {

			 // Get only visible and checked checkboxes to remove
			 var list_elements = [];
			 $('tr:visible td input:checked').each(function () {
				 list_elements.push($(this).attr('value'));
			 });
			 if (list_elements.length > MAX_DOWNLOAD_FILES) {

				 var msj = hashMessages["MaximoElementosDescarga1"] + " " + MaxElementsDownload + " " + hashMessages["MaximoElementosDescarga2"];
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
						 if (isExtra.toLowerCase() === "true") {

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
				 stack_elements = [[], []]; // [object, already_taken: bool]

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

							 var array = new Array();
							 array[0] = element;
							 array[1] = false;
							 stack_elements.push(array);
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
			 if(element_caller != null){
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

	

	   // Hidden Field hdnIsUpdateNeeded: alerts if is needed a data refresh from code behind
	   // A: Normal file upload
	 function prepareFileUpload_a(e) {
		 var _hdnIsUpdateNeeded = $("input[id*='_hdnIsUpdateNeeded']");
		 if (_hdnIsUpdateNeeded != null) {
			 _hdnIsUpdateNeeded.val("true");
		 }

		 var MyFileUpload = $("input[id*='MyFileUpload']");
		 if (MyFileUpload != null && (MyFileUpload.val() == null || MyFileUpload.val().length == 0)) {

			 $("#dialog p").text(hashMessages["SeleccioneArchivo"]);
			 $("#dialog").dialog({
				 buttons: {
					 "Confirmar": function () {
						 $(this).dialog("close");
					 }
				 }
			 });
				 e.preventDefault();
		 }
	 }

	 // B: Camera system upload
	 function prepareFileUpload_b(e) {
		 var _hdnIsUpdateNeeded = $("input[id*='_hdnIsUpdateNeeded']");
		 if (_hdnIsUpdateNeeded != null) {
			 _hdnIsUpdateNeeded.val("true");
		 }
		 var txbInputCameraNumber = $("input[id*='txbInputCameraNumber']");
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
		 var userID = '<%= Session["UserID"] %>';
		 
		 // Check if folio is selected
		 var folioID = 0;
		 var _hdnFolioID = $("input[id*='_hdnFolioID']");
		 if (_hdnFolioID != null && _hdnFolioID.val() != null && _hdnFolioID.val().length > 0) {
			 folioID = _hdnFolioID.val();
		 }
		 var folioID_int = parseInt(folioID, 10);

		 var comment = $("#txbComment").val();
		 var date = $("#commentDate").val();
		 var duration = $("#sliderSingle1").val();

	 // Disable element in memory elements 
	 if ($("input[id*='_hdnIsUpdateNeeded']") != null) {
		 $("input[id*='_hdnIsUpdateNeeded']").val("true");
	 }
	 if (userID != null && userID != "" && comment != null && comment != "" && date != null && date != "" && duration != null && duration != "") {

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
					 var _hdnIsUpdateNeeded = $("input[id*='_hdnIsUpdateNeeded']");
					 if (_hdnIsUpdateNeeded != null &&
						 _hdnIsUpdateNeeded.length) {
						 _hdnIsUpdateNeeded.val("true");
					 }
					 var json_object = JSON.parse(response.d);
					 var object = {
						 count: timeline_data.spans.length + 1,
						 duration: "1",
						 duration_formatStr: "00:00:01",
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
					 var username = '<%:Session["UserName"]%>';

					 // Create new row to HTML table
					 var tr = "<tr id='tape_" + object.tapeID + "'>";
					 tr +="<td>";
					 tr +="<input type='checkbox' name='timeline_elements' class='button' value='" + object.tapeID + "#true#C' checked>";//onclick='manageElement(this, " + object.tapeID + ", " + (index - 1).toString() + ", " + JsonConvert.SerializeObject(json_element) + ")' checked>";
					 tr +="<td>";
					 tr +="<h5>" + object.count + "</h5>";
					 tr +="<td>";
					 tr += "<h5>" + username + "</h5>";
					 tr +="<td>";
					 tr +="<h5>" + "" + "</h5>";
					 tr +="<td>";
					 tr +="<h5>" + "" + "</h5>";
					 tr +="<td>";
					 tr += "<button type='button' class='btn btn-default btn-sm' style='color:orange; opacity: 0.9; background-color: beige; border: 1px solid black; background-image: none;' name='btnTimelineElement' data-toggle='tooltip' ";
					 tr += "title='C' onclick='clickTimelineElement2(\"" + object.tapeID + "\", \"" + object.count + "\", \"" + object.duration + "\", \"" + object.timestamp.toString("dd'-'MM'-'yyyy HH':'mm':'ss") + "\", \"Comentario\", \"" + object.tapeID + "\", \"true\", \"" + object.fileName + "\", \"" + object.filePath + "\", \"" + object.duration_formatStr + "\", \"C\", \"OK\"" + ")' ><span class='glyphicon glyphicon-comment' aria-hidden='true'></span></button>";
					 tr +="<td>";
					 tr +="<h5 id='timestamp'>" + object.timestamp.toString("dd'-'MM'-'yyyy HH':'mm':'ss") + "</h5>";
					 tr +="<td>";
					 tr +="<h5>" + object.duration_formatStr + "</h5>";
					 tr +="</tr>";

					 // Add object to Html Table
					 $("#tblLeftGridElements tbody").append(tr);

					 // Update elements count
					 $("span[id*='lblResultsCount']").text($("tr[id*='tape_']:visible").length.toString());

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
 }
 /******** Event: Enter Key listener ********/

 function enterSearchBox(e) {
	 if (e.keyCode == 13) {
		 __doPostBack('<%=btnSearchCandidate.UniqueID%>', "");
	 }
 }

	   /******** START: Media Player 2.0: Nuevo Requerimiento: Global Play ********/

	   var queue_elements = [[], [], []];
	   var dynamic_number;

	   function globalplay_init() {

	       // Hide Video player box
	       var divPlayer_VIDEO = $("#divPlayer_VIDEO");
	       divPlayer_VIDEO.css("visibility", "hidden");

	       if ($("#globalplay_play").hasClass("play")) {

               // Queue of current elements playing
	           // queue_elements = [[], [], []];

               // ID dynamic
	           dynamic_number = 0;

	           // DO PLAY
	           $("#globalplay_play").removeClass("play");
	           $("#globalplay_play").addClass("pauseAudio");

	           // Start timer
	           if (GLOBALPLAY_seconds_current == 0) {
	               $('#divGlobalplay_timer').timer({
	                   format: '%H:%M:%S',
	                   seconds: 0
	               });

	           }
	           else {
	               // Resume timer
	               $('#divGlobalplay_timer').timer('resume');

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

	           // DO PAUSE
	           $("#globalplay_play").removeClass("pauseAudio");
	           $("#globalplay_play").addClass("play");

	           // Stop timer
	           $('#divGlobalplay_timer').timer('pause');

	           // Stop timer 
	           globalplay_abort();

	           // Pause all media current playing elements
	           globalplay_pauseAllCurrentMedia();

	       }
	       return false;
	   }

	   // Pause all media current playing elements
	   function globalplay_pauseAllCurrentMedia() {
	       // queue_elements:

	       // element[0] = Element
	       // element[1] = Dynamic ID
	       // element[2] = Dynamic Object
	       for (var i = 0; i < queue_elements.length; i++) {
	           var element = queue_elements[i];
	           if (element != null && element[0] != null && element[0].tapeType != null) {
	               var tapeType = element[0].tapeType;
	               var fileName = element[0].fileName;
	               var playID = element[1];
	               var dynamic_object = element[2];

	               // Get file extension
	               var file_extension = getFileExtension(fileName);

	               switch (tapeType) {
	                   case "A": {
	                       dynamic_object.pause();
	                       break;
	                   }

	                   case "V": {

	                       // HTML5 video supported formats
	                       if (file_extension != null && file_extension.length > 0 && file_extension[0] === "mp4" ||
                               file_extension[0] === "webm" || file_extension[0] === "ogg") {
	                           $("#" + playID)[0].pause();
	                       } else {
	                           wjs("#webchimera2").pause();

	                       }

	                       break;
	                   }

	                   case "S": {
	                       $("#fbsviewer2")[0].pause();
	                       break;
	                   }

	               }
	           }
	       } //for
	   }

	   function globalplay_resumeAllCurrentMedia() {
	       // queue_elements:

	       // element[0] = Element
	       // element[1] = Dynamic ID
	       // element[2] = Dynamic Object
	       for (var i = 0; i < queue_elements.length; i++) {
	           var element = queue_elements[i];
	           if (element != null && element[0] != null && element[0].tapeType != null) {
	               var tapeType = element[0].tapeType;
	               var fileName = element[0].fileName;
	               var playID = element[1];
	               var dynamic_object = element[2];

	               // Get file extension
	               var file_extension = getFileExtension(fileName);

	               switch (tapeType) {
	                   case "A": {
	                       dynamic_object.play();
	                       break;
	                   }

	                   case "V": {

	                       // HTML5 video supported formats
	                       if (file_extension != null && file_extension.length > 0 && file_extension[0] === "mp4" ||
                               file_extension[0] === "webm" || file_extension[0] === "ogg") {
	                           $("#" + playID)[0].play();
	                       } else {
	                           wjs("#webchimera2").play();
                           }

	                       break;
	                   }

	                   case "S": {
	                       $("#fbsviewer2")[0].play();
	                       break;
	                   }

	               }
	           }
	       } //for
	   }

       // Stopeable timer
	   var timer_globalplay; 
	   function globalplay_start() {

	       var w = $("#divTimelineProgress").css("width");
	       $("#sm2-progress-track").css("width", w);

	       // Init event while playing if GLOBALPLAY_seconds_total is already loaded
	       if (GLOBALPLAY_seconds_total > 0) {

               // Little delay to begin
	           setTimeout(function () { timer_globalplay = setInterval(globalplay_whilePlaying, 1000); }, 800);
	       }

	       // Enable right side Player box
	       $("#divPanel_PlayerControl").removeClass("disabled");
	   }

	   function globalplay_whilePlaying() {

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

			   var posX = parseFloat(TIMELINE_POINTER.css("left"), 10);

			   // Datetime position 
			   var position_date = window.timeframe_live.getTickDate(posX);
			   if (position_date != null) {
				   var position_date_str = moment(position_date, "YYYY-MM-DD HH:mm:ss");
				   $("#lblGlobalplay_timer_current_longFormat").text(position_date_str.format('DD-MM-YYYY HH:mm:ss'));
			   }

		       

		   } else {
			   // Pointer arrived to the end

			   // Stop timer 
			   globalplay_abort();
		   }
	   }

	   // Load elements in this pointer position
	   function globalplay_loadElements() {

	       // Search elements in current playtime
	       var elementsCandidate = getElementInMemoryByCurrentPlayingTime();
	       if (elementsCandidate != null && elementsCandidate.length > 0) {

	           // visual_queue: video, screen_recording and images
	           var visual_queue = $.grep(elementsCandidate, function (el, i) {
	               return el[0].tapeType == "V" || el[0].tapeType == "S" || el[0].tapeType == "I";
	           });

	           var flex_width_int = parseInt($(".flex").css("width"), 10);
	           var flex_height_int = parseInt($(".flex").css("height"), 10);

	           var visual_size_w = 300;
	           var visual_size_h = 300;

	           // Get visual elements already added in globalplay player
	           var visual_alreadyAdded = $(".flex").find('*').not('.info-label, .info-label *').length;
	           var visual_count = visual_queue.length + visual_alreadyAdded;

	           // Element distinct types 
	           switch (visual_count) {
	               case 1:
	                   {
	                       visual_size_w = flex_width_int - 80;
	                       visual_size_h = flex_height_int - 80;
	                       break;
	                   }
	               case 2:
	                   {
	                       visual_size_w = flex_width_int / 2 - 80;
	                       visual_size_h = flex_width_int / 2 - 80;
	                       break;
	                   }
	           }

	           // Resize elements already added 
	           if (visual_alreadyAdded > 0) {

	               //$(".flex a[name='visual_element']").each(function (index, el) {
	               $(".flex").find('*').not('.info-label, .info-label *').each(function (index, el) {
	                   $(this).css("width", visual_size_w);
	                   $(this).css("height", visual_size_h);
	               });
	           }

	           // Set label elements on play
	           $("#lblGlobalplay_element_count").text(elementsCandidate.length);

	           // Prepare URL elements to reproduce
	           var filePath_EXTRA = WS_InConcert_Server + ":" + WS_InConcert_Port + WS_InConcert_URL_download;
	           var filePath_OREKA = WS_Oreka_Server + ":" + WS_Oreka_Port + WS_Oreka_URL;

	           // globalplay box container
	           var flex_div = $("#divGlobalplay_screen .flex");

	           // Location variables
	           var visual_count = visual_alreadyAdded; // = 0
	           var visual_new = 0;


	           var id_list = "";
	           for (var i = 0; i < elementsCandidate.length; i++) {
	               var element = elementsCandidate[i];
	               if (element != null) {

	                   dynamic_number++;

	                   // Set id_list label
	                   id_list = id_list + element[0].tapeID + "(" + element[0].tapeType + "), ";
	                   $("#lblGlobalplay_element_ids").text(id_list);

	                   var current_duration = GLOBALPLAY_seconds_current;
	                   var timeCurrent = moment(_TL_STARTDATE, "DD-MM-YYYY HH:mm:ss");
	                   timeCurrent.add(current_duration, "seconds");

	                   var element_end = moment(element[0].timestamp, "DD-MM-YYYY HH:mm:ss");
	                   element_end.add(element[0].duration, "seconds");

	                   // Si el elemento no fue procesado, hacerlo
	                   if (element[1] == false) {
	                       element[1] = true;

	                       var tapeType = element[0].tapeType;
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
	                       var isExtra = element[0].filePath.length == 0 ? false : true;

	                       // Prepare URL elements
	                       var path_extra = filePath_EXTRA + "?id=" + element[0].segmentID + "&isExtra=1";
	                       var path_oreka = filePath_OREKA + "?segid=" + element[0].segmentID;

	                       // SET Element file path
	                       var file_url = isExtra ? path_extra : path_oreka;

	                       var dynamic_id = "";
	                       var audio_object = null;

	                       switch (tapeType) {
	                           case "A": {
	                               audio_object = globalplay_audio(file_url, element, dynamic_number);
	                               break;
	                           }

	                           case "V": {
	                               dynamic_id = globalplay_video(file_url, visual_size_w, visual_size_h, flex_div, element, dynamic_number);
	                               break;
	                           }

	                           case "S": {
	                               dynamic_id = globalplay_screenRecording(file_url, visual_size_w, visual_size_h, flex_div, element, dynamic_number);
	                               break;
	                           }

	                           case "I": {
	                               dynamic_id = globalplay_image(file_url, visual_size_w, visual_size_h, flex_div, element, dynamic_number);
	                               break;
	                           }

	                           case "D": {
	                               dynamic_id = globalplay_document(file_url, element, dynamic_number);
	                               break;
	                           }

	                           case "C": {
	                               dynamic_id = globalplay_comment(element, dynamic_number);
	                               break;
	                           }
	                       }

	                       var dynamic_object = null;
	                       if (audio_object != null) {
	                           dynamic_id = audio_object[0];
	                           dynamic_object = audio_object[1];
	                       }

	                       // element[0] = Element
	                       // element[1] = Dynamic ID
	                       // element[2] = Dynamic Object
	                       if (dynamic_id != "") {
	                           var array = new Array();
	                           array[0] = element[0];
	                           array[1] = dynamic_id;
	                           array[2] = dynamic_object;
	                           queue_elements.push(array);
	                       }

	                   } // else: elemento ya procesado

	               }
	           } // for

	       }
	   }

	   /********* Individual elements section *********/

	   function globalplay_audio(file_url, element, dynamic_number) {
	       var global_elementID = "audio_" + dynamic_number;
	       var fileName = element[0].fileName;
	       var tapeID = element[0].tapeID;
	       var duration = element[0].duration;
	       var duration_timeout = getDurationInMS(duration);// * 1.3;
		  
		   var label = $(".flex #globalplay_divAudioName h2");
		   label.text(fileName);

		   var audio = new Audio(file_url);
		   audio.play();

		   var object = new Array();
		   object[0] = global_elementID;
		   object[1] = audio;

	       // Mute Source: http://www.jqueryscript.net/other/Clean-jQuery-Confirmation-Dialog-Plugin-with-Bootstrap-Popovers-Bootstrap-Confirmation.html

	       // TODO: Mute function: Add on over event
		   var audio_timeline = $("#timeframe #tlTape_" + tapeID + " > rect");
		   // audio_timeline



		   setTimeout(function () { globalplay_removeElement(global_elementID, element); globalplay_clearLabel(label); }, duration_timeout);

		   return object;
	   }

	   function globalplay_video(file_url, visual_size_w, visual_size_h, flex_div, element, dynamic_number) {
		   var global_elementID = "";
		   var duration = element[0].duration;
		   var fileName = element[0].fileName;

		   //var duration_final = duration <= 8 ? 10000 : duration * 1000;
		   var duration_final = duration <= 7 ? duration * 1000 * 1.5 : duration * 1000;
		   var ok = false;


	       // Get file extension
		   var file_extension = getFileExtension(fileName);

	       // HTML5 video supported formats
		   if (file_extension != null && file_extension.length > 0 && file_extension[0] === "mp4" ||
               file_extension[0] === "webm" || file_extension[0] === "ogg") {

		       // HTML5 video tag Source: https://www.w3.org/2010/05/video/mediaevents.html

		       global_elementID = "video_" + dynamic_number;

		       var js_player = '<video id="' + global_elementID + '" preload="none" style="width: ' + visual_size_w + 'px; height: ' + visual_size_h + 'px; margin-top:30px;" name="visual_element" autoplay>';
		       js_player += '<source id="mp4" src="' + file_url + '" type="video/mp4">';
		       js_player += '<source id="webm" src="' + file_url + '" type="video/webm">';
		       js_player += '<source id="ogv" src="' + file_url + '" type="video/ogg">';
		       js_player += '</video>';

		       flex_div.append(js_player);
		       ok = true;

		   } else {
               // Is wav audio ==> Webchimera plugin

		       if (getIsFirefoxOrIE()) {
		           global_elementID = "webchimera2";

		           var applet = "<object id='" + global_elementID + "' type='application/x-chimera-plugin' width='" + visual_size_w + "' " +
                                "height='" + visual_size_h + "' name='visual_element' style='position:relative; float:left; margin: 10px;'>";
		           applet += "<param name='windowless' value='true' />";
		           applet += "</object>";
		           applet += "<div id='interface'></div>";

		           flex_div.append(applet);

		           // Play webchimera
		           try {
		               wjs("#" + global_elementID).clearPlaylist();
		               wjs("#" + global_elementID).addPlaylist(file_url);
		               wjs("#" + global_elementID).play();
		           } catch (err) {
		               console.log("Error loading webchimera");
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
		           }

		           ok = true;
		       }
		       else {
		           var label = $(".flex #globalplay_divSpecialMessages h2");
		           label.text(hashMessages["UtilizarNavegador2"]);
		           setTimeout(function () { globalplay_clearLabel(label); label.hide(); }, duration_final);
		       }
		   }

		   if (ok) {
		       setTimeout(function () { globalplay_removeElement(global_elementID, element) }, duration_final);
		   }
		   return global_elementID;
	   }

	   function globalplay_screenRecording(file_url, visual_size_w, visual_size_h, flex_div, element, dynamic_number) {
		   var global_elementID = "";
		   var duration = element[0].duration;
		   var duration_timeout = getDurationInMS(duration);

		   if (getIsFirefoxOrIE()) {
			   if (fileStatus != "PROCESSING" && fileStatus != "ERROR") {

				   global_elementID = "fbsviewer2";
				   var fileStatus = element[0].fileStatus;

				   var applet = "<applet codebase='assets/applets/' code='OrkMP.class' archive='OrkMP.jar' width='" + visual_size_w + "px' " +
					   "height='" + visual_size_h + "px' name='fbsviewer' id='" + global_elementID + "' title='undefined'>";

				   applet += "<param name='HOST' value=''>";
				   applet += "<param name='PORT' value='5901'>";
				   applet += "<param name='FBSURL' value='" + file_url + "'>";
				   applet += "<param name='AUDIOURL' value=''>";
				   applet += "<param name='SHOWPLAYERCONTROLS' value='YES'>"; // YES
				   applet += "<param name='SHOWPLAYERTAGCONTROLS' value='YES'>";
				   applet += "<param name='TIMECOUNTDOWN' value='NO'>";
				   applet += "<param name='CACHE' value='NO'>";
				   applet += "<param name='RESIZABLE' value='NO'>";
				   applet += "<param name='TAGS' value=''>";
				   applet += "<param name='QUICK_REWIND_SECS' value='-5'>";
				   applet += "<param name='QUICK_ADVANCE_SECS' value='5'>";
				   applet += "<param name='NOREC_TAGTYPE_NAME' value='Pause'>";
				   applet += "</applet>";

				   flex_div.append(applet);

				   setTimeout(function () { globalplay_removeElement(global_elementID, element) }, duration_timeout);
			   }
		   } else {
			   var label = $(".flex #globalplay_divSpecialMessages h2");
			   label.text(hashMessages["UtilizarNavegador2"]);
			   setTimeout(function () { globalplay_clearLabel(label); label.hide(); }, duration_timeout);
		   }
		   return global_elementID;
	   }

	   function globalplay_image(file_url, visual_size_w, visual_size_h, flex_div, element, dynamic_number) {
	       var global_elementID = "image_" + dynamic_number;
		   var segmentID = element[0].segmentID;
		   var fileName = element[0].fileName;

	       $('<a name="visual_element" id="' + global_elementID + '" style="width:' + visual_size_w + 'px; height:' + visual_size_h + 'px;' +
			  'background-image:url(' + file_url + '); float:left; position:relative; margin:10px; background-size: auto 100%;"' +
			  'width="' + visual_size_w + '" height="' + visual_size_h + '">' + fileName + '</a>').appendTo(flex_div).fadeIn(2000);

		   // Salvattore Source: http://webdesign.tutsplus.com/tutorials/build-a-dynamic-grid-with-salvattore-and-bootstrap-in-10-minutes--cms-20410


           // DURATION TEST

		   setTimeout(function () { globalplay_removeElement(global_elementID, element) }, GLOBALPLAY_DEFAULT_DURATION);
		   return global_elementID;
	   }

	   function globalplay_document(file_url, element, dynamic_number) {
	       var global_elementID = "image_" + dynamic_number;
		   var duration = element[0].duration;
		   var fileName = element[0].fileName;
		   var duration_final = duration <= 1 ? 5000 : duration * 1000;
		   var label = $(".flex #globalplay_divDocumentsName h2");

		   label.text("Documento: " + fileName);
		   setTimeout(function () { globalplay_clearLabel(label); label.hide(); }, duration_final);

		   return global_elementID;
	   }

	   function globalplay_comment(element, dynamic_number) {
	       var global_elementID = "image_" + dynamic_number;
		   var duration = element[0].duration;
		   var fileName = element[0].fileName;
		   var duration_final = duration <= 1 ? 5000 : duration * 1000;

		   var label = $(".flex #globalplay_divComments h2");
		   label.text(fileName);
		   setTimeout(function () { globalplay_clearLabel(label) }, duration_final);

		   return global_elementID;
	   }

	   /********* Individual elements section END *********/


	   // Stop timer 
	   function globalplay_abort() {
		   clearInterval(timer_globalplay);
		   $('#divGlobalplay_timer').timer('pause');
	   }

	   function globalplay_stop() {


	       // Queue of current elements playing
	       queue_elements = [[], [], []];

		   // DO PAUSE
		   $("#globalplay_play").removeClass("pauseAudio");
		   $("#globalplay_play").addClass("play");

		   // Close Fancybox 
		   $.fancybox.close();

		   TIMELINE_POINTER.css("left", "0%");

		   // Set ready elements already taken
		   prepareElementsAlreadyTaken();

		   // Remove elements from globalplay player
		   globalplay_removeAllElements();

		   // Clean info labels
		   globalplay_cleanLabels();

		   dynamic_number = 0;

		   // Stop timer 
		   globalplay_abort();
		   GLOBALPLAY_seconds_current = 0;

		   // Clear global timer
		   $('#divGlobalplay_timer').timer('remove');
	   }

	   // Clean info labels
	   function globalplay_cleanLabels() {
		   $("#lblGlobalplay_element_count").text("0");
		   $("#lblGlobalplay_element_ids").text("0");
		   $("#lblGlobalplay_timer_total_longFormat").text("00:00:00");
		   $("#lblGlobalplay_timer_current_longFormat").text("00:00:00");
	   }

	   // Remove elements from globalplay player
	   function globalplay_removeAllElements() {
		   $(".flex").find('*').not('.info-label, .info-label *').remove();

		   // Clean all label elements
		   $(".flex div h2").text("");
	   }

	   function globalplay_removeElement(global_elementID, element) {
		   $(".flex #" + global_elementID).remove();

		   // Set available true back
		   element[1] = true;

		   // Remove element from current elements queue

		   // element[0] = Element
		   // element[1] = Dynamic ID
		   // element[2] = Dynamic Object
		   queue_elements = $.grep(queue_elements, function (el, i) {
			   return el[1] != global_elementID;
		   });

	   }

	   function globalplay_clearLabel(label) {
		   label.text("");
	   }

	   // Search elements in current playtime
	   function getElementInMemoryByCurrentPlayingTime() {
		   if (stack_elements != null && stack_elements.length > 0) {

			   var current_duration = GLOBALPLAY_seconds_current;
			   var timeCurrent = moment(_TL_STARTDATE, "DD-MM-YYYY HH:mm:ss");
			   timeCurrent.add(current_duration, "seconds");

			   var array = stack_elements.filter(function (el) {
				   var element_start = null;
				   var element_end = null;
				   if (el != null && el[0] != null && el[0].timestamp != null && el[0].duration != null) {

					   element_start = moment(el[0].timestamp, "DD-MM-YYYY HH:mm:ss");
					   element_end = moment(el[0].timestamp, "DD-MM-YYYY HH:mm:ss");
					   element_end.add(el[0].duration, "seconds");
				   }

				   return element_start != null && element_end != null && el[1] === false && 
					   element_start.toDate() <= timeCurrent.toDate() &&
					   timeCurrent.toDate() <= element_end.toDate();
			   });
			   return array;
		   }
	   }

	   // Set ready elements already taken
	   function prepareElementsAlreadyTaken() {
		   if (stack_elements != null && stack_elements.length > 0) {
			   for (var i = 0; i < stack_elements.length; i++) {
				   var el = stack_elements[i];
				   if (el != null && el[1] == true) {
					   el[1] = false;
				   }
			   }
		   }
	   }


	   /******** END: Media Player 2.0: Nuevo Requerimiento: Global Play ********/

   </script>

   <style>

       .ui-dialog {
           z-index: 2500;
       }

       .divTimeline {
           height: 100%;
           left: 0;
           border-radius: 13px;
           width: 101%;
           margin-left: -13px;
           z-index: 1002;
       }

       .timeframe {
           /* display: inline; */
           width: 94%;  /* 94 %*/
           margin: auto;
           background: transparent;
           background-color: inherit !important;
           padding-left: 0;
       }

       .playerContainer {
           width: 55px; 
           height: 140px;
           padding-right: 55px;
           margin-top: 10px;
           background-color: #446e9b;
           background-image: linear-gradient(to bottom, rgba(255,255,255,0.125) 5%, rgba(255,255,255,0.125) 45%, rgba(255,255,255,0.15) 50%, rgba(0,0,0,0.1) 51%, rgba(0,0,0,0.1) 95%);
       }

/* ---------------------------------- */

.black_overlay {
	display: none;
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background-color: #000;
	z-index: 1001;
	-moz-opacity: 0.7;
	opacity: 0.5;
	filter: alpha(opacity=80);
}

.white_content {
	display: none;
	position: absolute;
	top: 25%;
	left: 25%;
	width: 50%;
	padding: 16px;
	background-color: lightgray;
	z-index: 1002;
	overflow: auto;
	border-radius: 15px;
}

/* ---------------------------------- */
#timeframe {
	background-color: #f5f5f5;
	height: auto !important;
}

/* */
.panel {
	border: 1px solid #CCC;
}

div#playerBox {
	background: #333;
	margin: 0 auto;
}

.playerBox {
	min-height:440px; 
	margin-left: 20px; 
	border: solid 0.17em; 
	position:relative;
}

.globalplayBox {
	min-width:1000px; 
	min-height:650px;
	/*min-height:580px; */
	border: solid 0.17em; 
	background: linear-gradient(to bottom, #9EA7B1, #9EA7B1); 
	top: 10px;
}

.fancybox-wrap {
	top: 15px !important;
}

div#videoBar {
	background: #333;
	padding: 10px;
}

hr#line {
	margin-top: 0;
}

/* ---- */
hr.style-one {
	border: 0;
	border-bottom: 1px dashed #ccc;
	background: #999;
	position: absolute;
	z-index: 10;
	width: 100%;
	margin-top: 9px;
}

hr.style-one:after {
/* Not really supposed to work, but does */
	content: "\00a0";
/* Prevent margin collapse */
}

/* ---- */
.no-gutter > [class*='col-'] {
	padding-right: 0;
	padding-left: 0;
}

.col-md-1 {
	float: none;
	display: inline-block;
	vertical-align: middle;
}

/* ---- */
.row-short {
	margin-left: 0;
	margin-right: 0;
}

/* ---- */
/*---popup styles starts here ----- */
.popupGrayBg {
	position: fixed;
	width: 100%;
	height: 100%;
	background: #000;
	z-index: 1001;
	left: 0;
	top: 0;
	opacity: .5;
	filter: progid:DXImageTransform.Microsoft.Alpha(Opacity=50);
}

.QTPopupCntnr {
	width: 487px;
	position: fixed;
	z-index: 1200;
	background: gray;
	left: 50%;
	top: 50%;
	margin-left: -244px;
	margin-top: -276px;
}

.gpBdrLeftTop {
	width: 6px;
	height: 6px;
	background: url(../images/greenPopupBdr.png) left top no-repeat;
	float: left;
}

.gpBdrRightTop {
	width: 6px;
	height: 6px;
	background: url(../images/greenPopupBdr.png) right top no-repeat;
	float: right;
}

.gpBdrTop {
	height: 3px;
	background: #a9b6e1;
	border-top: 3px solid #3b4f91;
	margin-left: 6px;
	margin-right: 6px;
}

.gpBdrLeft {
	border-left: 3px solid #3b4f91;
	background: #fff;
}

.gpBdrRight {
	border-right: 3px solid #3b4f91;
	background: #fff;
	min-height: 300px;
	position: relative;
}

.gpBdrLeftBottom {
	width: 6px;
	height: 6px;
	background: url(../images/greenPopupBdr.png) left bottom no-repeat;
	float: left;
}

.gpBdrRightBottom {
	width: 6px;
	height: 6px;
	background: url(../images/greenPopupBdr.png) right bottom no-repeat;
	float: right;
}

.gpBdrBottom {
	height: 3px;
	background: #fff;
	border-bottom: 3px solid #3b4f91;
	margin-left: 6px;
	margin-right: 6px;
}

.gpBdrRight .caption {
	background: #a9b6e1;
	line-height: 38px;
	padding-left: 10px;
	font-family: Arial,Helvetica,sans-serif;
	font-size: 15px;
	font-weight: 700;
	color: #3b4f91;
}

.gpBdrRight .closeBtn {
	background: red;
	width: 31px;
	height: 31px;
	position: absolute;
	right: -15px;
	top: -15px;
	background: url(../images/grn_pp_cls_btn_normal.png) no-repeat;
}

.gpBdrRight .closeBtn:hover {
	background: url(../images/grn_pp_cls_btn_over.png) no-repeat;
}

.gpBdrRight .content {
	padding: 25px;
	font-weight: 400;
}

/*--- Popup styles ends here ----- */
.container-session {
	float: right;

	height: 100%;
	padding-left: 50px;
	text-align: right;
	white-space: nowrap;
	background-image: url(assets/images/toolbar-bkg.png);
	background-repeat: no-repeat;
	margin-top: 7px;
	float: right;
	position: relative;
	z-index: 201;
}

.container-session div,.container-session button {
	float: left;
}

/* ---- Table styles */
.special-title {
	font-size: 17px;
	font-style: normal;
	padding: 0 5px;
	border-radius: 3px;
	margin-right: 2px;
}

.div-panel {
	background: linear-gradient(to bottom, whitesmoke, whitesmoke);
}

.div-panel2 {
	background: linear-gradient(to top,#D7D8DA,#C9CBCE);
}

table {
	border-collapse: collapse;
}

table,th,td {
	border: 1px solid #9DA3AB !important;
}

tr {
	background: #f5f5f5;
}

h1 {
	cursor: default;
}

/* ---- Div disabled styles */
div.disabled,button.disabled,a.disabled {
	pointer-events: none;

/* for "disabled" effect */
	opacity: .5;
	background: #CCC;

}

/************* Flex js  *************/

.flex {position:relative;width:50%;min-height:650px;margin:0 auto;border:0px solid red;margin-top:10px;}
.flex a {background-color:white;display:block;width:100px;height:100px;border-radius:8px;position:absolute;background-repeat:no-repeat;background-position:center;border:3px solid white;cursor:pointer;text-align:left;text-shadow:1px 1px 20px #000;color:white;font-size:18px;font-weight:bold;text-indent:10px;line-height:30px;text-decoration:none;}

</style>

</asp:content>
<asp:content id="Content3" ContentPlaceHolderID="ContentLoginStatus" runat="server">
	<div class="container-session" >
		<div class="hidden-xs" style="color:#446e9b; margin-left:15px; margin-right:20px; cursor:default;"><span class="fa fa-user pull-left" aria-hidden="true"></span><div class="usernameInfo" style="font: 11px/1.4em FontAwesome, Helvetica, Arial, sans-serif"></div></div>
		<button id="btn_close" class="btn btn-primary btn-xs" style="color:white;  background-color:#446e9b; text-transform: none; letter-spacing: inherit;" runat="server" onserverclick="btn_close_ServerClick"> 
			<span class="glyphicon glyphicon-log-out" aria-hidden="true"></span>  Salir 
		</button>
	</div>
</asp:content>
<asp:content id="Content1" ContentPlaceHolderID="ContentBody" runat="server">
  <form id="form1" runat="server" enctype="multipart/form-data">
   <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
   <div style="width:100%; padding-bottom: 20px;">
	  <div id="divMessages" role="alert" style="padding:6px;"></div>
	  <div style="width:98%; min-height:360px; height:100%; margin: 0 auto;">
		 <div class="row no-gutter" style="height:100%; min-height:600px; max-height:600px;">

			<!-- PANEL BÚSQUEDA -->
			 <div id="divPanel_Busqueda" class="div-panel col-md-4 col-xs-12 img-rounded panel offset-2" style="max-height:600px; min-height:600px; border-radius: 13px;">
			   <h1 style="margin-top: 5px;"><span class="special-title label label-primary" style="font-weight: normal; z-index: 50;">Búsqueda</span> 
			   </h1>
			   <div class="row" style="margin:3px; margin-top: 25px; min-height: 110px;">
				  
				   <div class="row row-short" id="divFolios">

						<div class="pull-right" style="margin-right:8px; margin-top: -20px;">
					 <h6>
						# Resultados: 
						<asp:Label Text="0" ID="lblResultsCount" runat="server"/>
					 </h6>
				  </div>

					 <div class="col-md-12" style="margin-bottom: -20px;">
						<div style="z-index:0; display: inline;">
						<div>
							<asp:Timer ID="Timer1" OnTick="Timer1_Tick" runat="server" Interval="300000"> <!-- Default: Refresh grid every 5 mins -->
							</asp:Timer> 
						</div>

						<asp:UpdatePanel runat="server">
							<Triggers>
								<asp:AsyncPostBackTrigger ControlID="Timer1" EventName="Tick" />
							</Triggers>
						<ContentTemplate>
					 
							<asp:HiddenField ID="_hdnTapeID_RoleGroupName_TypeTapeType_duration_timestamp_segmentID_count_fileName_endDate_filePath_duration_formatStr_fileStatus" runat="server" />
							<asp:HiddenField ID="_hdnJSonList" runat="server" />
							<asp:HiddenField ID="_hdnJSonStart" runat="server" />
							<asp:HiddenField ID="_hdnJSonEnd" runat="server" />
							<asp:HiddenField ID="_hdnFolioID" runat="server" />

						   <span>
						   <button class="btn btn-default pull-left" type="button" runat="server" id="btnSearch1" onserverclick="btnSearch_ServerClick" >
						   <span class="glyphicon glyphicon-search" aria-hidden="true"></span>
						   </button>
						   </span>

						   <span class="col-md-10">
						   <asp:TextBox CssClass="form-control" placeholder="Buscar folios por número" runat="server" ID="txbSearchBox1" onkeypress="return enterSearchBox(event)"/>
						   <asp:Button ID="btnSearchCandidate" runat="server" style="display:none" Text="" OnClick="btnSearchCandidate_Click"/>
						   </span>

						</ContentTemplate>
						</asp:UpdatePanel>

						</div>
						<asp:RegularExpressionValidator ID="RegularExpressionValidator1" ControlToValidate="txbSearchBox1" runat="server" ErrorMessage="Número de folio inválido" ValidationExpression="\d+"></asp:RegularExpressionValidator>
						<!-- /input-group -->
					 </div>
				  </div>
				  <br/>

				<div class="pull-right" style="margin-bottom: 5px; margin-right: 0px; padding: 0px;">
					<button id="btnDownloadAll" class="btn btn-default" type="button" title="Descargar los elementos seleccionados" style="margin-right: 6px;" onclick="downloadAll();">
					 <span class="fa fa-download" aria-hidden="true"></span>
					 </button>  
					 <a href="#" id="btnAddComment" class="open btn btn-default" style="margin-right: 6px;" title="Agregar comentario al folio" onclick="addCommentClick();">
						<!-- addCommentClick -->
						<span class="glyphicon glyphicon-comment"></span> 
					 </a>
					 <button id="btnUploadElement" class="btn btn-default" type="button" title="Subir elemento al folio" style="margin-right: 6px;" onclick="addFileClick();">
					 <span class="fa fa-upload" aria-hidden="true"></span>
					 </button>                     
					 <button id="btnRemoveElementSelected" style="margin-right: 6px; display:none;" class="btn btn-default" type="button" title="Borrar elementos seleccionados">
					 <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
					 </button> 
					 <button id="btnRefresh" class="btn btn-default" type="button" title="Actualizar folio" style="margin-right: 6px; display:none;" runat="server" onserverclick="btnSearch_ServerClick">
					 <span class="glyphicon glyphicon-refresh" aria-hidden="true"></span>
					 </button>
				  </div>


				  <div class="row row-short">
					 <ul id="nav_tabs1" class="nav nav-tabs">
						<li id="liFolio" onclick="return changeTab1(this);" class="active"><a name="nav_tabs" style="background:transparent;" href="#">Folio</a></li>
						<li id="liRoles" onclick="return changeTab1(this);"><a style="background:transparent;" href="#">Roles</a></li>
						<li id="liTipos" onclick="return changeTab1(this);"><a style="background:transparent;" name="nav_tabs" href="#">Tipos</a></li>
					 </ul>
				  </div>
				  <div class="row row-short" id="divRoles" style="display:none;">
					 <div class="col-md-12">
						<!-- /input-group -->
						<asp:Literal id="litCheckRoles" Text="" runat="server" />
					 </div>
				  </div>
				  <div class="row row-short" id="divTypes" style="display:none;">
					 <div class="col-md-12">
						<!-- /input-group -->
						<asp:Literal id="litCheckTypes" Text="" runat="server" />
					 </div>
				  </div>
				  <asp:Panel runat="server" ID="pnlTagTypes"></asp:Panel>
				  <!-- /.col-md-6 -->
			   </div>
			   <!-- /.row -->
			  
			   <div id="divElementos" style="overflow:auto; max-height:430px; min-height:330px">
				  <asp:UpdatePanel runat="server">
					 <ContentTemplate>
						<asp:Literal ID="litTable" runat="server" Text=""></asp:Literal>
					 </ContentTemplate>
				  </asp:UpdatePanel>
				  <asp:Panel runat="server" ID="pnlTimelineElements">
				  </asp:Panel>
			   </div>
			   <div id="divAcciones" style="display:none;">
				  <br />
				  <div class="row row-short">
				  </div>
				  <br />
				  <br />
				  <br />
			   </div>

			</div>

			<div id="light" class="white_content">
			<div id="light_row" class="row">

			</div>               
				<hr />
			   <div class="row-short">
				  <button id="btnCloseFullscreen" type="submit" class="btn btn-default pull-right" title="Cerrar pantalla completa" onclick="closeFullscreen();">
				  <span class="glyphicon glyphicon-new-window" aria-hidden="true"></span>
				  </button>
				  <label class="label" id="lblFullscreenTitle"></label>
			   </div>
			</div>
			<div id="fade" class="black_overlay"></div>
			
			 <!-- PANEL PLAYER -->
			<div id="divPanel_PlayerControl" class="div-panel col-md-8 col-xs-12 img-rounded disabled" style="float:right; max-height:600px; min-height:600px; border-radius: 13px; width: 66%;">
			   <h1 style="margin-top: 5px;"><span class="special-title label label-primary" style="font-weight: normal;">Reproductor</span></h1>
			   <button id="btnShowHideLeftPanel" class="btn btn-primary btn-xs" type="button" title="Mostrar / Ocultar panel" style="color:white; float:left; display:none;" onclick="showHideLeftPanel();">
			   <span class="glyphicon glyphicon-transfer" aria-hidden="true"></span>
			   </button>

			   <div class="row row-short" >
				  <label id="lblElementName" class="pull-left" style="margin-left:40px;">Video Player</label>
			   </div>
			   <div class="row row-short" style="margin-top:1%; display:block;" >

				<!-- PLAYER VIDEO -->
				<div class="col-md-9" style="width: 79%;">    
					<div class="row">

						<div id="playerBox" class="img-rounded playerBox" runat="server">

						<!-- GLOBALPLAY SCREEN -->
						<div id="divGlobalplay_screen" class="globalplayBox img-rounded" style="display:none;"> <!-- min-height:100%;"> -->
							<div class="flex" style="min-width: 1000px;"> <!--min-height:100%;">-->

								<div id="globalplay_divSpecialMessages" class="info-label" style="position: absolute; width: 100%; z-index:1001;">
									<h2 class="label label-danger" style="z-index:1001; text-transform: none; font-size:20px; width: 50%; margin: 0 auto;"></h2>
								</div>

								<div id="globalplay_divDocumentsName" class="info-label" style="position: absolute; width: 100%; z-index:1001;">
									<h2 class="label label-success" style="z-index:1001; text-transform: none; font-size:20px; width: 50%; margin: 0 auto;"></h2>
								</div>

                                <div id="globalplay_divAudioName" class="info-label" style="position: absolute; width: 100%; z-index:1001;">
									<h2 class="label label-danger" style="z-index:1001; text-transform: none; font-size:20px; width: 50%; margin: 0 auto;"></h2>
								</div>

								<div id="globalplay_divComments" class="info-label" style="position: absolute; bottom: 30px; width: 100%; z-index:1001;">
									<h2 class="label label-warning" style="z-index:1001; background-color: orange; text-transform: none; font-size:20px; width: 50%; margin: 0 auto;"></h2>
								</div>
							</div>
						</div>

								<div id="divPlayer_VIDEO" style="display:none;" class='photobox'> <!-- Contiene el Applet --> </div>
								<img id="imgPlayer" class='photobox' style='max-width:100%; margin: auto; display:none;' alt=''/> <!-- javascript:$("#imgPlayer").photobox(); max-height:390px --> 

								<!-- PLAYER - VIDEO - Controls Mask -->
								<div id="divControlsMask_VIDEO" class="sound_player_class1 sm2-bar-ui compact full-width" style="position:absolute; top: 0; right: 0; height: 54px; display: none;"> <!-- Controles -->
								<div class="bd sm2-main-controls" style="height:100%;">
								   <div class="sm2-inline-texture"></div>
								   <div class="sm2-inline-gradient"></div>
								   <div class="sm2-inline-element sm2-button-element">
									  <div class="sm2-button-bd">
										 <a id="aPlayPause_VIDEO" href="#" class="sm2-inline-button play-pause"></a>
									  </div>
								   </div>
								   <div class="sm2-inline-element sm2-inline-status">
									  <div class="sm2-playlist">
										 <div class="sm2-playlist-target">
											<ul class="sm2-playlist-bd">
											   <li><label id="lblSoundTitle1_VIDEO">*</label></li>
											</ul>
										 </div>
									  </div>
									  <div class="sm2-progress">
										 <div class="sm2-row">
											<div id="sm2-inline-time_VIDEO" class="sm2-inline-time">0:00</div>
											<div class="sm2-progress-bd">
											   <div id="sm2-progress-track_VIDEO" class="sm2-progress-track">
												  <div class="sm2-progress-bar"></div>
												  <div id="sm2-progress-ball_VIDEO" class="sm2-progress-ball">
													 <div class="icon-overlay"></div>
												  </div>
											   </div>
											</div>
											<div id="sm2-inline-duration_VIDEO" class="sm2-inline-duration">0:00</div>
										 </div>
									  </div>
								   </div>
						  
								</div>
								<div class="bd sm2-playlist-drawer sm2-element">
								   <div class="sm2-inline-texture">
									  <div class="sm2-box-shadow"></div>
								   </div>
								   <!-- playlist content is mirrored here -->
								   <div class="sm2-playlist-wrapper">
									  <ul class="sm2-playlist-bd">
										 <li class="selected"><a id="lnkSound_VIDEO"><label id="lblSoundTitle2_VIDEO">*</label></a></li>
									  </ul>
								   </div>
								</div>
							 </div>

							

						  </div>    
					</div>              

					<div class="row">
						<!-- PLAYER AUXILIAR - AUDIO -->
						<div id="divPlayer_AUDIO" style="display:block;">
							<div class="row row-short">
							   <label class="pull-left" style="margin-top:15px; margin-bottom:-3px; margin-left: 40px;">Audio Player</label>
							</div>
						   <div class="row row-short" style="margin-top:1%; margin-left: 20px;" >
			   
						   <div id="audioContainer" class="row row-short" style="height:80px;">

							   <div id="divControlsMask_AUDIO" class="sound_player_class sm2-bar-ui compact full-width" style="top:0px; right:0px; height:54px">
									<div class="bd sm2-main-controls" style="height:100%;">
									   <div class="sm2-inline-texture"></div>
									   <div class="sm2-inline-gradient"></div>
									   <div class="sm2-inline-element sm2-button-element">
										  <div class="sm2-button-bd">
											 <a id="aPlayPause_AUDIO" href="#play" class="sm2-inline-button play-pause">Play / pause</a>
										  </div>
									   </div>
									   <div class="sm2-inline-element sm2-inline-status">
										  <div class="sm2-playlist">
											 <div class="sm2-playlist-target">
												<ul class="sm2-playlist-bd">
												   <li><label id="lblSoundTitle1_AUDIO">*</label></li>
												</ul>
											 </div>
										  </div>
										  <div class="sm2-progress">
											 <div class="sm2-row">
												<div id="sm2-inline-time_AUDIO" class="sm2-inline-time">0:00</div>
												<div class="sm2-progress-bd">
												   <div class="sm2-progress-track">
													  <div class="sm2-progress-bar"></div>
													  <div id="sm2-progress-ball_AUDIO" class="sm2-progress-ball">
														 <div class="icon-overlay"></div>
													  </div>
												   </div>
												</div>
												<div id="sm2-inline-duration_AUDIO" class="sm2-inline-duration">0:00</div>
											 </div>
										  </div>
									   </div>
									   <div class="sm2-inline-element sm2-button-element sm2-volume">
										  <div class="sm2-button-bd">
											 <span class="sm2-inline-button sm2-volume-control volume-shade"></span>
											 <a href="#volume" class="sm2-inline-button sm2-volume-control">volume</a>
										  </div>
									   </div>
									</div>
									<div class="bd sm2-playlist-drawer sm2-element">
									   <div class="sm2-inline-texture">
										  <div class="sm2-box-shadow"></div>
									   </div>
									   <!-- playlist content is mirrored here -->
									   <div class="sm2-playlist-wrapper">
										  <ul class="sm2-playlist-bd">
											 <li class="selected"><a id="lnkSound_AUDIO"><label id="lblSoundTitle2_AUDIO">*</label></a></li>
										  </ul>
									   </div>
									</div>
								 </div>

							   </div>
							</div>
						</div>
					</div>

				</div>

				   <!-- Right slide - Element details info -->
				<div class="col-md-2 img-rounded" style="height:70%; padding-right: 5px; width: 20%;">
					 <div class="row row-short">
						<label id="lblDetalles" class="pull-left" style="margin-top:5px; margin-bottom:-3px">Detalles:</label>
					 </div>
					 <hr style="margin-top:4px;"/>
					   <div class="row row-short" style="margin-left: 10px; margin-top: -8px;">
						<label class="pull-left" style="font-size:12px; font-weight: normal;">Nombre:</label>
					 </div>
					 <div class="row row-short" style="margin-bottom: 10px;">
						<div class="form-group form-group-sm">
						   <input id="lblName" type="text" readonly="true" class="form-control form-group-sm"/>
						</div>
					 </div>
					 <div class="row row-short" style="margin-left: 10px; margin-top: -8px;">
						<label class="pull-left" style="font-size:12px; font-weight: normal;">Tipo:</label>
					 </div>
					 <div class="row row-short" style="margin-bottom: 10px;">
						<div class="form-group form-group-sm">
						   <input id="lblType" type="text" readonly="true" class="form-control form-group-sm"/>
						</div>
					 </div>
					 <div class="row row-short" style="margin-left: 10px;">
						<label class="pull-left" style="font-size:12px; font-weight: normal;">Inicio:</label>
					 </div>
					 <div class="row row-short" style="margin-bottom: 10px;">
						<div class="form-group form-group-sm">
						   <input id="lblTimestamp" type="text" readonly="true" class="form-control form-group-sm"/>
						</div>
					 </div>
					 <div class="row row-short" style="margin-left: 10px;">
						<label class="pull-left" style="font-size:12px; font-weight: normal;">Duración:</label>
					 </div>
					 <div class="row row-short" style="margin-bottom: 10px;">
						<div class="form-group form-group-sm">
						   <input id="lblDuration" type="text" readonly="true" class="form-control form-group-sm"/>
						</div>
					 </div>
					   <div class="row row-short" style="margin-left: 10px;">
						<label class="pull-left" style="font-size:12px; font-weight: normal;">Estado:</label>
					 </div>
					 <div class="row row-short" style="margin-bottom: 10px;">
						<div class="form-group form-group-sm">
						   <input id="lblStatus" type="text" readonly="true" class="form-control form-group-sm"/>
						</div>
					 </div>
					 <br />
					 <div class="row row-short" style="margin-top: -10px;">
						<label id="lblAcciones" class="pull-left" style="margin-bottom: -3px;">Acciones:</label>
					 </div>
					 <hr style="margin-top:4px;"/>
					 <div class="row row-short">
						<a id="lnkElementDownload" class="btn btn-default" type="button"  style="margin-right: 4px;" href="#" onclick="javascript: $('#dialog p').text(hashMessages['SeleccioneElemento']); $('#dialog').dialog({ buttons: {'Confirmar': function () { $(this).dialog('close'); }} });"> 
						<span class="fa fa-download" aria-hidden="true"></span>
						</a> 

						 <button id="btnRemoveElement" class="btn btn-default" type="button" title="Borrar elemento" style="margin-right: 4px;" onclick="javascript: $('#dialog p').text(hashMessages['SeleccioneElemento']); $('#dialog').dialog({ buttons: {'Confirmar': function () { $(this).dialog('close'); }} });"> 
						<span class="fa fa-trash" aria-hidden="true"></span>
						</button> 

						 <div class='popbox3' style="margin-top:15px; margin-right: 6px; display: none;"> </div> <!-- popbox: Remove element -->
					 <div class='box3 popbox3' style="width:300px; height: 240px; right: 10%; margin-top: 10px;">
						<div class='arrow' style="left: 250px;"></div>
						<div class='arrow-border' style="left: 250px;"></div>
						<div class="row row-short" style="padding: 10px;">
						   <label class="label" style="font-size:100%; color:black;">Borrar elemento seleccionado</label> 
						</div>
						<div class="form-group">
						   <div class="row row-short" style="padding: 10px;">

							   <div id="divRemoveElementMessage" class="alert alert-warning" role="alert">
								  <span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>
								  <span class="sr-only">Info:</span> Está a punto de borrar el elemento, confirme su contraseña para continuar
								</div>
							<input type="password" class="form-control" id="txbConfirmRemoveElement" placeholder="Contraseña" name="login-username" required="required"/>
							   <!--  -->
						   </div>
						   <div id="popbox_footer3" class="row row-short pull-right" style="margin-right: 15px; margin-top: 4px;">
							  <button id="btnConfirmRemoveElement" type="button" class="btn btn-default" title="Confirmar borrar elemento" runat="server">
							  <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
							  </button>
						   </div>
						</div>
					 </div>

						 <button id="btnFullscreen" class="btn btn-default" type="button" title="Ver en pantalla completa" onclick="openFullscreen();">
						<span class="fa fa-arrows-alt" aria-hidden="true"></span>
						</button> 

						 <a id="aBtnFullscreen" class="btn btn-default" type="button" style="margin-right: 4px; display:none;" href="Fullscreen.aspx"> 
							<span class="fa fa-arrows-alt" aria-hidden="true"></span>
						</a> 

					 </div>
				  </div>

			   </div>
			

			</div>
		 </div>
		 <div class="row no-gutter">
			<div class='popbox' style="margin-right: 6px; display: inline-block;"> </div> <!-- popbox: Add comment -->
			<div class='box popbox' style="width:300px; height: 245px;">
			   <div class='arrow'></div>
			   <div class='arrow-border'></div>
			   <div class="row row-short" style="padding: 10px;">
				  <label class="label" style="font-size:100%; color:black;">Agregar un comentario al folio</label> 
			   </div>
			   <div class="form-group">
				  <div class="col-md-12">
					 <input type="text" class="form-control" id="txbComment" placeholder="Comentario" name="login-username" required="required"/>
				  </div>
			   </div>
			   <div class="form-group">
				  <div class="col-md-12" style="margin-top: 10px;">
					  <!-- <input type="text" class="form-control" id="datetimepicker1" placeholder="Fecha" value="" required="required"/>  
					  <input type="text" class="form-control" id="addCommentDatetime" required="required"/> -->

					  <input id="commentDate" class="form-control" data-inputmask="'alias': 'date'">

					  <!-- <input type="text" name="time" class="timepicker" /> -->
					 <!--  http://jongsma.org/software/protoplasm/control/timepicker -->
				  </div>
			   </div>
			   <div class="form-group">
				  <div class="col-md-12" style="margin-top: 12px;">
					 <label class="control-label" style="margin-bottom: 20px;">Duración (seg)</label>
					 <div class="layout-slider">
						<input id="sliderSingle1" type="slider" name="duracion" value="1" style="display: none;"/>
					 </div>
				  </div>
				  <br />
				  <div id="popbox_footer" class="row row-short pull-right" style="margin: 7px;">
					 <button id="btnSaveComment" type="submit" class="btn btn-default" title="Guardar" onclick="confirmAddComment()">
					 <span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
					 </button>
				  </div>
			   </div>
			</div>

			 <div class='popbox2' style="margin-right: 6px; display: none;"> </div> <!-- popbox: Upload file -->
			 <div class='box2 popbox2' style="width:300px; height: 300px;">
				<div class='arrow'></div>
				<div class='arrow-border'></div>
				<div class="row row-short" style="padding: 10px;">
					<label id="popbox2_title" class="label" style="font-size:100%; color:black;">Subir elemento al folio</label> 
				</div>

				 <div class="row row-short">
					 <ul id="nav_popbox2" class="nav nav-tabs">
						<li id="liUpload" onclick="return changeTab2(this);" class="active"><a name="nav_tabs" style="background:transparent;" href="#">Subir</a></li>
						<li id="liCamera" onclick="return changeTab2(this);"><a style="background:transparent;" href="#">Cámaras</a></li>
					 </ul>
				  </div>

						<div id="divUpload" class="form-group">
						   <div class="row row-short" style="padding: 10px;">
							  <label class="control-label">Documentos, videos y audios</label>
							  <input id="MyFileUpload" type="file" runat="server" class="file" style="width: 85%; margin: auto; margin-top:8px; height:24px;"/>
							   <!--  -->
						   </div>
						   <div class="form-group">
							  <div class="col-md-8" style="margin-top: 10px;">
									<input id="uploadDate" class="form-control" data-inputmask="'alias': 'date'" runat="server"/>
							  </div>
								 <div class="col-md-4" style="margin-top: 10px;">
									<button id="btnConfirmUploadElement" type="button" class="btn btn-default" title="Subir" runat="server" onclick="prepareFileUpload_a();" onserverclick="btnConfirmUploadElement_ServerClick">
									<span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
									</button>                              
								 </div>
						   </div>
						   <br />

						</div>

				 <div id="divCamaras" class="form-group" style="display:none;">
						   <div class="row row-short" style="padding: 10px;">
							  <label class="control-label">Asignar un video al sistema de cámaras</label>
						   </div>
							<div class="form-group">
							  <div class="col-md-8" style="margin-top: 10px;">
								  Número de cámara
								  <input type="text" class="form-control" id="txbInputCameraNumber" onkeypress='return event.charCode >= 48 && event.charCode <= 57' runat="server" style="margin-bottom: 5px;"/>
								  Inicio y fin de la grabación 
									<input id="camarasDate1" class="form-control" data-inputmask="'alias': 'date'" runat="server"/>

									<input id="camarasDate2" class="form-control" data-inputmask="'alias': 'date'" runat="server" style="margin-top: 5px;"/>

							  </div>
							  <div class="col-md-4" style="margin-top: 10px;">
								  <div class="row row-short" style="margin-top: 110px;">
									   <button id="btnConfirmUploadElement_b" type="button" class="btn btn-default pull-right" style="margin:10px;" title="Subir" runat="server" onclick="prepareFileUpload_b();" onserverclick="btnConfirmUploadElement_ServerClick">
									  <span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
								  </button>
								</div>
						   </div>

						   </div>
							 
						</div>

					 </div>
					 </div>

			<!-- PANEL TIMELINE -->
            <div id="divGlobalplay_timer" style="display:none;"></div>
			<div id="divTimeline" class="divTimeline div-panel2 col-md-12 col-xs-12 img-rounded">
			   <h1 style="margin-top: 5px;">

                   <!--
					<label id="lblGlobalplay_timer_current_longFormat" class="label" style="font-size:100%; color:black;">00:00:00</label>
				   <label id="lblGlobalplay_timer_total_longFormat" class="label" style="font-size:100%; color:black;">00:00:00</label>
				   <label id="lblGlobalplay_timer_current" class="label" style="font-size:100%; color:black;">00:00:00</label>
				   <label id="lblGlobalplay_timer_total" class="label" style="font-size:100%; color:black;">00:00:00</label>
					Cantidad: <label id="lblGlobalplay_element_count" class="label" style="font-size:100%; color:black;">0</label>: IDs: <label id="lblGlobalplay_element_ids" class="label" style="font-size:100%; color:black;">0</label>
                   <a class="btn btn-large" data-toggle="confirmation">Click to toggle confirmation</a>
				   -->

				   <span class="special-title label label-primary" style="font-weight: normal;">Timeline</span>


			   </h1>

				<div class="row" style="display:inline">


                     <!-- -->
                            
					 <div id="playerContainer" class="playerContainer col-md-2"> <!-- img-rounded -->
						<div id="controlContainer">
							<ul class="controls"> <!-- Controls mask Source: http://www.jqueryrain.com/?vXjX8BEk -->
								<li>
									<a href="#" class="mute" data-attr="mute"></a>
								</li>
								<li>
									<a href="#divGlobalplay_screen" id="globalplay_play" class="play" data-attr="playPauseAudio" onclick="return globalplay_init()"></a> <!-- Play/Pause button -->
								   <a href="#divGlobalplay_screen" id="btnOpenFancybox" style="display:none;"></a>
								</li>
								<li>
									<a href="#divGlobalplay_screen" id="globalplay_stop" class="" data-attr="nextAudio" onclick="return globalplay_stop()"> <!-- Stop button -->
										<span class="fa fa-stop-circle fa-2x" aria-hidden="true" style="color:white"></span>
									</a>
								</li>
							</ul>
						</div>
					</div>

                        <!-- -->


					<div id="divTimelineProgress" style="height:8px; position:absolute; margin-top: -5px;"></div> <!-- Contenedor draggable para el Progress Pointer -->

					<div id="timeframe" class="timeframe col-md-10">
                      



					</div>

					<div id="sm2-inline-element" class="sm2-inline-element sm2-inline-status" style="position:absolute;">
						<div id="sm2-progress" class="sm2-progress">
						<div class="sm2-row">
							<div id="sm2-progress-bd" class="sm2-progress-bd">
								<div id="sm2-progress-track" class="sm2-progress-track sm2-progress-track2">
									<div id="sm2-progress-bar"class="sm2-progress-bar sm2-progress-bar2"></div>

									<div id="sm2-progress-ball_TIMELINE"  class="sm2-progress-ball sm2-progress-ball2" style="display:none;">
									<div id="icon-overlay"class="icon-overlay icon-overlay2"></div>
									<img src="assets/images/pointer.png" style="width:20px; margin-top:-45px; margin-left:-5px;" />

										<div id="vertical-line-progress-left" style="width: 5px; height: 130px; border-right: 2px solid black; position: absolute; margin-top: -10px;/* margin-left: -4px; */border-bottom: 2px solid black;"></div>
										<div id="vertical-line-progress-right" style="width: 5px; height: 130px;border-left: 2px solid black; position: absolute; margin-top: -10px;margin-left: 3px;border-bottom: 2px solid black;"></div>

									</div>

								</div>
							</div>
						</div>
						</div>
					</div>

				</div>

				<!-- popbox: Runtime Timelapse -->
				<div class='popbox4' style="margin-top:15px; margin-right: 6px; display: none;"> </div> 
				<div class='box4 popbox4' style="width:150px; height: 40px; opacity: 0.9; background-color: lightgrey;">
				<div class='arrow-down' style="opacity: 0.9;"></div>
				<div class='arrow-border-down'></div>
				<div class="row row-short" style="padding: 10px;">
					<label id="lblPopbox4" class="label" style="font-size:100%; color:black;"></label> 
				</div>
				</div>

			</div>
		 </div>
		 <div class="row no-gutter" style="width: 100%;">
			<div class="col-md-12 img-rounded" style="background-color:whitesmoke; height:100%; z-index:0;width: 100.5%; left: 0;margin-left: -5px;">
			</div>
		 </div>
	  </div>

	<a id="aDownloader" href="" download=""></a>
			
<div id="dialog" title="Mensaje MediaPlayer">
  <p style="text-align: left;"></p>
</div>
	  
<div id="dialog_WebChimera" title="Mensaje MediaPlayer">
  <p style="text-align: left;"></p>
	<a href=""></a>
</div>

   <script src="assets/js/jquery.qtip-1.0.0-rc3.js"></script>
   <script src="assets/js/highlight.js"></script>
   <script src="assets/js/jquery.photobox.js" type="text/javascript"></script>

<!-- From Server to Client -->      
   <asp:HiddenField ID="_hdnIsUpdateNeeded" runat="server" Value="false"/>
   <asp:HiddenField ID="_hdnLocalRepository" runat="server" />
   <asp:HiddenField ID="_hdnWS_Oreka_Server" runat="server" />
   <asp:HiddenField ID="_hdnWS_Oreka_Port" runat="server" />
   <asp:HiddenField ID="_hdnWS_Oreka_URL" runat="server" />
   <asp:HiddenField ID="_hdnWS_InConcert_Server" runat="server" />
   <asp:HiddenField ID="_hdnWS_InConcert_Port" runat="server" />
   <asp:HiddenField ID="_hdnWS_InConcert_URL_download" runat="server" />
   <asp:HiddenField ID="_hdnFbs_width" runat="server" />
   <asp:HiddenField ID="_hdnFbs_height" runat="server" />
   <asp:HiddenField ID="_hdnPlayerFBS_fullscreen_width" runat="server" />
   <asp:HiddenField ID="_hdnPlayerFBS_fullscreen_height" runat="server" />
   <asp:HiddenField ID="_hdnPlayerFBS_popup_width" runat="server" />
   <asp:HiddenField ID="_hdnPlayerFBS_popup_height" runat="server" />
   <asp:HiddenField ID="_hdnWebchimera_Install_URL" runat="server" />
   <asp:HiddenField ID="_hdnMaxElementsDownload" runat="server" />
   <asp:HiddenField ID="_hdnGlobalplay_defaultDuration" runat="server" />


<!-- From Client to Server -->      
</form>
</asp:content>