<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="MediaPlayer.Dashboard" MasterPageFile="~/Site.Master" %>
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
	<script src="assets/js/Dashboard.js"></script>

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
	<link href="assets/css/Dashboard.css" type="text/css" rel="stylesheet"/> 

	<!--<script src="assets/js/bootstrap-confirmation.js"></script>-->
	<script src="assets/js/jquery.darktooltip.js"></script>
	<link href="assets/css/darktooltip.css" type="text/css" rel="stylesheet"/> 


<script type="text/javascript">


/*** global variables ***/

 window.globalUserID = '<%= Session["UserID"] %>';
 window.globalUserName = '<%:Session["UserName"]%>';
 
 /******** Event: Enter Key listener ********/
    function enterSearchBox(e) {
        if (e.keyCode == 13) {
            __doPostBack('<%=btnSearchCandidate.UniqueID%>', "");
        }
    }

</script>



</asp:content>
<asp:content id="Content3" ContentPlaceHolderID="ContentLoginStatus" runat="server">
    <div class="container-session" >
		<div class="hidden-xs" style="color:#446e9b; margin-left:15px; margin-right:20px; cursor:default;">
            <span class="fa fa-user pull-left" aria-hidden="true"></span>
            <div class="usernameInfo" style="font: 11px/1.4em FontAwesome, Helvetica, Arial, sans-serif"></div>
		</div>
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
						<asp:RegularExpressionValidator ID="RegularExpressionValidator1" ControlToValidate="txbSearchBox1" runat="server" ErrorMessage="Número inválido" ValidationExpression="\d+"></asp:RegularExpressionValidator>
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
				   -->
					Cantidad: <label id="lblGlobalplay_element_count" class="label" style="font-size:100%; color:black;">0</label>: IDs: <label id="lblGlobalplay_element_ids" class="label" style="font-size:100%; color:black;">0</label>

				   <span class="special-title label label-primary" style="font-weight: normal;">Timeline</span>

			   </h1>

				<div class="row" style="display:inline">

                     <!-- -->
                            
					 <div id="playerContainer" class="playerContainer col-md-2 img-rounded"> <!-- img-rounded -->
						<div id="controlContainer">
							<ul class="globalplay_controls controls"> <!-- Controls mask Source: http://www.jqueryrain.com/?vXjX8BEk -->
								<li id="globalplay_play_li" class="img-rounded globalplay_play_li">
									<a href="#divGlobalplay_screen" id="globalplay_play" class="globalplay_play" data-attr="playPauseAudio" onclick="return globalplay_init()"></a> <!-- Play/Pause button -->
                                    <a href="#divGlobalplay_screen" id="btnOpenFancybox" style="display:none;"></a>
								</li>
								<li id="globalplay_stop_li" class="img-rounded">
									<a href="#divGlobalplay_screen" id="globalplay_stop" class="globalplay_stop" data-attr="nextAudio" onclick="return globalplay_stop()"> <!-- Stop button -->
									</a>
								</li>
							</ul>
						</div>
					</div>

                        <!-- -->

					<div id="divTimelineProgress" style="height:8px; position:absolute; margin-top: 10px;"></div> <!-- Contenedor draggable para el Progress Pointer -margin-top: -5px -->
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
									<img id="imgPointer" src="assets/images/pointer.png" style="width:20px; margin-top:-45px; margin-left:-5px;" />

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

<asp:HiddenField ID="_hdnIsUpdateNeeded" runat="server" Value="false" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnLocalRepository" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnWS_Oreka_Server" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnWS_Oreka_Port" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnWS_Oreka_URL" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnWS_InConcert_Server" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnWS_InConcert_Port" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnWS_InConcert_URL_download" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnFbs_width" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnFbs_height" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnPlayerFBS_fullscreen_width" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnPlayerFBS_fullscreen_height" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnPlayerFBS_popup_width" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnPlayerFBS_popup_height" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnWebchimera_Install_URL" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnMaxElementsDownload" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnGlobalplay_defaultDuration" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="_hdnGlobalplay_simultaneousElements" runat="server" ClientIDMode="Static" />
        

</form>
</asp:content>