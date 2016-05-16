<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="MediaPlayer.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentHeader" runat="server">

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
    <script src="assets/js/jquery.feedback_me.js"></script>
    <script src="assets/js/zip.js"></script>
    <script src="assets/js/Dashboard.js"></script>
    <script src="assets/js/Globalplay.js"></script>

    <!-- Styles -->
    <link href="assets/css/datetimepicker.css" type="text/css" rel="stylesheet" />
    <link href="assets/css/jquery.photobox.css" type="text/css" rel="stylesheet" />
    <link href="assets/css/timeline-styles.css" rel="stylesheet" />
    <link href="assets/css/numericUpDown.css" rel="stylesheet" />
    <link href="assets/css/bar-ui.css" rel="stylesheet" />
    <link href="assets/css/popbox.css" rel="stylesheet" />
    <link href="assets/css/qtip.css" rel="stylesheet" />
    <link href="assets/css/highlight.css" rel="stylesheet" />
    <link href="assets/css/jslider.css" rel="stylesheet" />
    <link href="assets/css/jquery.fancybox.css" type="text/css" rel="stylesheet" />
    <link href="assets/css/jquery.feedback_me.css" rel="stylesheet" type="text/css" />
    <link href="assets/css/Dashboard.css" type="text/css" rel="stylesheet" />
    <link href="assets/css/globalplay.css" type="text/css" rel="stylesheet" />

    <!--<script src="assets/js/bootstrap-confirmation.js"></script>-->
    <script src="assets/js/jquery.darktooltip.js"></script>
    <link href="assets/css/darktooltip.css" type="text/css" rel="stylesheet" />

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

        function doDownloadElements() {
            __doPostBack('<%=btnDownloadAllCandidate.UniqueID%>', "");
        }

        function checkUserSession() {
            var user_session =  '<%= Session["UserID"] %>';
            // alert(user_session);
        }
       
    </script>


</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ContentLoginStatus" runat="server">
    <div class="container-session unselectable">
        <div class="hidden-xs" style="color: #446e9b; margin-left: 15px; margin-right: 20px; cursor: default; font-size: 12px !important">
            <span class="fa fa-user pull-left" aria-hidden="true" style="margin-right: 7px;"></span>
            <div class="usernameInfo"></div>
        </div>
        <button id="btn_close" class="btn btn-primary btn-xs" style="color: white; background-color: #446e9b; text-transform: none; letter-spacing: inherit;" runat="server" onserverclick="btn_close_ServerClick">
            <span class="" aria-hidden="true" style='font-family: "Open Sans","Helvetica Neue",Helvetica,Arial,sans-serif;'></span>Logout 
        </button>
    </div>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentBody" runat="server">
    <form id="form1" runat="server" enctype="multipart/form-data">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div id="feedback_trigger" class="left-bottom fm_clean feedback_trigger_closed" style="display:none;"><span class="feedback_trigger_text"></span></div>

        <div id="divFather" style="width: 100%; margin-top: 11px; margin-bottom: 15px;">
            <div style="width: 98%; min-height: 360px; height: 100%; margin: 8px auto;">
                <div class="row no-gutter" style="height: 100%; min-height: 600px; max-height: 600px;">

                    <%--<input type="button" id="btnPageFullscreen" value="click to toggle fullscreen" onclick="dashboardFullScreen(document.body)" style="visibility:hidden;">--%>

                    <!-- PANEL BÚSQUEDA -->
                    <div id="divPanel_Busqueda_pre" class="col-md-4 col-xs-12 img-rounded" style="padding-right: 4px;">
                    <div id="divPanel_Busqueda" class="div-panel panel" style="max-height: 600px; min-height: 600px;"> <%--unselectable--%>

                        <h1 style="margin-top: 5px;"><span id="h1-busqueda" class="special-title label label-primary unselectable" style="font-weight: normal; z-index: 50;">Búsqueda</span>
                        </h1>

                        <div class="row" style="margin: 3px; margin-top: 17px; min-height: 110px;">

                            <div class="row row-short" id="divFolios">
                                <div class="col-md-12" style="margin-bottom: -10px;">
                                    <div style="z-index: 0; display: inline;">
                                        <div>
                                            <asp:Timer ID="Timer1" OnTick="Timer1_Tick" runat="server" Interval="300000">
                                                <!-- Default: Refresh grid every 5 mins -->
                                            </asp:Timer>
                                        </div>

                                        <asp:UpdatePanel runat="server">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="Timer1" EventName="Tick" />
                                            </Triggers>
                                            <ContentTemplate>

                                                <asp:HiddenField ID="_hdnTapeID_RoleGroupName_TypeTapeType_duration_timestamp_segmentID_count_fileName_endDate_filePath_duration_formatStr_fileStatus_userName" runat="server" />
                                                <asp:HiddenField ID="_hdnJSonList" runat="server" />
                                                <asp:HiddenField ID="_hdnJSonStart" runat="server" />
                                                <asp:HiddenField ID="_hdnJSonEnd" runat="server" />
                                                <asp:HiddenField ID="_hdnFolioID" runat="server" />

                                                <span class="col-md-3 col-xs-3 pull-right" style="padding-right:0;">
                                                    <button class="btn btn-default pull-left" style="margin:0;" type="button" title="Hacer búsqueda" runat="server" id="btnSearch1" onserverclick="btnSearch_ServerClick">
                                                        <span class="glyphicon glyphicon-search" aria-hidden="true"></span>
                                                    </button>

                                                     <button class="btn btn-default panel-minus pull-right" type="button" title="Ocultar panel" style="position:relative; margin:0;" onclick="javascript: busqueda_panel_show(false);">
                                                        <span class="glyphicon glyphicon-hand-left" aria-hidden="true"></span>
                                                    </button>
                                                </span>

                                                <span class="col-md-9 col-xs-9" style="padding:0; padding-left:8px; ">
                                                    <asp:TextBox CssClass="form-control txbSearchBox1" placeholder="Buscar folios por número" runat="server" ID="txbSearchBox1" onkeypress="return enterSearchBox(event)" />
                                                    <asp:Button ID="btnSearchCandidate" runat="server" Style="display: none" Text="" OnClick="btnSearchCandidate_Click" />

                                                    <div class="pull-right unselectable" style="margin-right: 20px; margin-top: 2px; cursor: default; position: absolute; right: 0;">
                                                        <h6># Resultados: 
					                	                    <asp:Label Text="0" ID="lblResultsCount" runat="server" />
                                                        </h6>
                                                    </div>
                                                </span>

                                            </ContentTemplate>
                                        </asp:UpdatePanel>

                                    </div>
                                    <asp:TextBox runat="server" ID="txbDummy" Visible="false"/>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" ControlToValidate="txbDummy" runat="server" ErrorMessage="Número inválido" ValidationExpression="\d+"></asp:RegularExpressionValidator>
                                    <!-- /input-group -->
                                </div>
                            </div>
                            <br />

                            <div class="pull-right" style="margin-bottom: 5px; margin-right: 0; padding: 0; margin-top:5px;">
                                <!-- btnDownloadAll -->
                                <button id="btnDownloadAll" class="btn btn-default" type="button" title="Descargar los elementos seleccionados" style="margin-right: 6px;" onclick="downloadAll();">
                                    <span class="fa fa-download" aria-hidden="true"></span>
                                </button>
                                <asp:Button ID="btnDownloadAllCandidate" runat="server" Style="display: none" Text="" OnClick="btnDownloadAll_Click" />
                                <!-- addCommentClick -->
                                <a href="#" id="btnAddComment" class="open btn btn-default" style="margin-right: 6px;" title="Agregar comentario al folio" onclick="addCommentClick();">
                                    <span class="glyphicon glyphicon-comment"></span>
                                </a>
                                <button id="btnUploadElement" class="btn btn-default" type="button" title="Subir elemento al folio" style="margin-right: 6px;" onclick="addFileClick();">
                                    <span class="fa fa-upload" aria-hidden="true"></span>
                                </button>
                                <button id="btnRemoveElementSelected" style="margin-right: 6px; display: none;" class="btn btn-default" type="button" title="Borrar elementos seleccionados">
                                    <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
                                </button>
                                <button id="btnRefresh" class="btn btn-default" type="button" title="Actualizar folio" style="margin-right: 6px; display: none;" runat="server" onserverclick="btnSearch_ServerClick">
                                    <span class="glyphicon glyphicon-refresh" aria-hidden="true"></span>
                                </button>
                            </div>


                            <div class="row row-short" style="margin-top:5px;">
                                <ul id="nav_tabs1" class="nav nav-tabs">
                                    <li id="liFolio" onclick="return changeTab1(this);" class="active"><a name="nav_tabs" style="background: transparent;" href="#">Folio</a></li>
                                    <li id="liRoles" onclick="return changeTab1(this);"><a style="background: transparent;" href="#">Roles</a></li>
                                    <li id="liTipos" onclick="return changeTab1(this);"><a style="background: transparent;" name="nav_tabs" href="#">Tipos</a></li>
                                </ul>
                            </div>
                            <div class="row row-short" id="divRoles" style="display: none;">
                                <div class="col-md-12">
                                    <!-- /input-group -->
                                    <asp:Literal ID="litCheckRoles" Text="" runat="server" />
                                </div>
                            </div>
                            <div class="row row-short" id="divTypes" style="display: none;">
                                <div class="col-md-12">
                                    <!-- /input-group -->
                                    <asp:Literal ID="litCheckTypes" Text="" runat="server" />
                                </div>
                            </div>
                            <asp:Panel runat="server" ID="pnlTagTypes"></asp:Panel>
                            <!-- /.col-md-6 -->
                        </div>
                        <!-- /.row -->

                        <div id="divElementos" style="overflow: auto; max-height: 430px; min-height: 330px">
                            <asp:UpdatePanel runat="server">
                                <ContentTemplate>
                                    <asp:Literal ID="litTable" runat="server" Text=""></asp:Literal>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <asp:Panel runat="server" ID="pnlTimelineElements">
                            </asp:Panel>
                        </div>
                        <div id="divAcciones" style="display: none;">
                            <br />
                            <div class="row row-short">
                            </div>
                            <br />
                            <br />
                            <br />
                        </div>

                    </div>
                    </div>
                    <div id="light" class="white_content">
                        <div id="light_row" class="row">
                        </div>
                        <button id="btnCloseFullscreen" type="submit" class="btn btn-default pull-right" title="Minimizar video" style="position: absolute; bottom: 0; right: 0; margin: 20px;" onclick="closeFullscreen();">
                            <span class="glyphicon glyphicon-new-window" aria-hidden="true"></span>
                        </button>
                        <label class="label" id="lblFullscreenTitle"></label>
                    </div>
                    <div id="fade" class="black_overlay"></div>

                    <!-- PANEL PLAYER -->
                    <div id="divPanel_container" class="col-md-8 col-xs-12 img-rounded" style="padding-left: 8px;">
                        <div id="divPanel_PlayerControl" class="div-panel unselectable disabled" style="float: right; max-height: 600px; min-height: 600px; width: 100%;">

                        <h1 style="margin-top: 5px;"><span class="special-title label label-primary" style="font-weight: normal;">Reproductor</span></h1>

                        <div class="row row-short">
                            <label id="lblElementName" class="pull-left unselectable" style="margin-left: 20px; font-size: 20px;">Video Player</label>
                        </div>
                        <div class="row row-short" style="margin-top: 1%; display: block;">

                            <!-- PLAYER VIDEO -->
                            <div id="playerControl_sub1" class="col-md-9 col-xs-12">
                                <div class="row">
                                    <div runat="server" id="playerBox" class="img-rounded playerBox" style="background: repeating-linear-gradient( -55deg, #999, #999 23px, #474949 25px, #333 20px );">

                                        <section class="gradient position-controls row">
                                            <button class="glyphicon glyphicon-zoom-in zoom-button" type="button" title="Zoom aumentar" >
                                            </button>
                                            <button class="glyphicon glyphicon-zoom-out zoom-button" type="button" title="Zoom reducir" >
                                            </button>
                                            <button class="fa fa-refresh zoom-button" type="button" title="Reiniciar" onclick="javascript: doReset();">
                                            </button>
                                            <div style="display:none;">
                                                <button class="fa fa-arrow-left zoom-button" type="button" title="Mover izquierda" >
                                                </button>
                                                <button class="fa fa-arrow-right zoom-button" type="button" title="Mover derecha" >
                                                </button>
                                                 <button class="fa fa-arrow-up zoom-button" type="button" title="Mover arriba" >
                                                </button>
                                                <button class="fa fa-arrow-down zoom-button" type="button" title="Mover abajo" >
                                                </button>
                                            </div>
                                        </section>

                                        <div id="divPlayer_VIDEO" class='photobox' style="display: none; overflow: hidden; background-color:black;" >
                                            <!-- Contiene el Applet -->
                                        </div>
                                        <img id="imgPlayer" class='photobox' style='max-width: 100%; margin: auto; display: none;' alt='' />

                                        <!-- PLAYER - VIDEO - Controls Mask -->
                                        <div id="divControlsMask_VIDEO" class="sound_player_class1 sm2-bar-ui compact full-width" style="position: absolute; top: -1px; right: 0; height: 54px; display: none;">
                                            <!-- Controles -->
                                            <div class="bd sm2-main-controls" style="height: 100%;">
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
                                                                <li>
                                                                    <label id="lblSoundTitle1_VIDEO">*</label></li>
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
                                                        <li class="selected"><a id="lnkSound_VIDEO">
                                                            <label id="lblSoundTitle2_VIDEO">*</label></a></li>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>



                                    </div>
                                </div>

                                <div class="row">
                                    <!-- PLAYER AUXILIAR - AUDIO -->
                                    <div id="divPlayer_AUDIO" style="display: block;">
                                        <div class="row row-short">
                                            <label class="pull-left unselectable" style="margin-top: 15px; margin-bottom: -3px; margin-left: 20px; font-size: 20px;">Audio Player</label>
                                        </div>
                                        <div class="row row-short" style="margin-top: 1%; margin-left: 20px;">

                                            <div id="audioContainer" class="row row-short" style="height: 80px;">

                                                <div id="divControlsMask_AUDIO" class="sound_player_class sm2-bar-ui compact full-width" style="top: 0; right: 0; height: 54px; border: 1px solid #CCC;">
                                                    <div class="bd sm2-main-controls" style="height: 100%;">
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
                                                                        <li>
                                                                            <label id="lblSoundTitle1_AUDIO">*</label></li>
                                                                    </ul>
                                                                </div>
                                                            </div>
                                                            <div class="sm2-progress">
                                                                <div class="sm2-row">
                                                                    <div id="sm2-inline-time_AUDIO" class="sm2-inline-time">0:00</div>
                                                                    <div class="sm2-progress-bd">
                                                                        <div id="sm2-progress-track_AUDIO" class="sm2-progress-track">
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
                                                        <div id="volume_AUDIO" class="sm2-inline-element sm2-button-element sm2-volume">
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
                                                                <li class="selected"><a id="lnkSound_AUDIO">
                                                                    <label id="lblSoundTitle2_AUDIO">*</label></a></li>
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
                            <div id="playerControl_sub2" class="col-md-3 img-rounded unselectable" style="height: 70%; padding-right: 20px;"> <%--width: 20%--%>
                                <div class="row row-short">
                                    <label id="lblDetalles" class="pull-left" style="margin-top: 5px; margin-bottom: -3px">Detalles:</label>
                                </div>
                                <hr style="margin-top: 4px;" />
                                <div class="row row-short" style="margin-left: 10px; margin-top: -8px;">
                                    <label class="pull-left" style="font-size: 12px; font-weight: normal;">Nombre:</label>
                                </div>
                                <div class="row row-short" style="margin-bottom: 4px;">
                                    <div class="form-group form-group-sm">
                                        <input id="lblName" type="text" readonly="true" class="form-control form-group-sm unselectable" style="cursor: default;" />
                                    </div>
                                </div>
                                <div class="row row-short" style="margin-left: 10px; margin-top: -8px;">
                                    <label class="pull-left" style="font-size: 12px; font-weight: normal;">Tipo:</label>
                                </div>
                                <div class="row row-short" style="margin-bottom: 4px;">
                                    <div class="form-group form-group-sm">
                                        <input id="lblType" type="text" readonly="true" class="form-control form-group-sm unselectable" style="cursor: default;" />
                                    </div>
                                </div>
                                <div class="row row-short" style="margin-left: 10px;">
                                    <label class="pull-left" style="font-size: 12px; font-weight: normal;">Inicio:</label>
                                </div>
                                <div class="row row-short" style="margin-bottom: 4px;">
                                    <div class="form-group form-group-sm">
                                        <input id="lblTimestamp" type="text" readonly="true" class="form-control form-group-sm unselectable" style="cursor: default;" />
                                    </div>
                                </div>
                                <div class="row row-short" style="margin-left: 10px;">
                                    <label class="pull-left" style="font-size: 12px; font-weight: normal;">Duración:</label>
                                </div>
                                <div class="row row-short" style="margin-bottom: 4px;">
                                    <div class="form-group form-group-sm">
                                        <input id="lblDuration" type="text" readonly="true" class="form-control form-group-sm unselectable" style="cursor: default;" />
                                    </div>
                                </div>
                                <div class="row row-short" style="margin-left: 10px;">
                                    <label class="pull-left" style="font-size: 12px; font-weight: normal;">Estado:</label>
                                </div>
                                <div class="row row-short" style="margin-bottom: 0;">
                                    <div class="form-group form-group-sm">
                                        <input id="lblStatus" type="text" readonly="true" class="form-control form-group-sm unselectable" style="cursor: default;" />
                                    </div>
                                </div>


                                <br />
                                <div class="row row-short" style="margin-top: -10px;">
                                    <label id="lblAcciones" class="pull-left" style="margin-bottom: -3px;">Acciones:</label>
                                </div>
                                <hr style="margin-top: 4px;" />
                                <div class="row row-short">

                                    <a id="lnkElementDownload" class="btn btn-default" type="button" style="margin-right: 4px;" href="#" onclick="javascript: $('#dialog p').text(hashMessages['SeleccioneElemento']); $('#dialog').dialog({ buttons: {'Confirmar': function () { $(this).dialog('close'); }} });">
                                        <span class="fa fa-download" aria-hidden="true"></span>
                                    </a>

                                    <button id="btnRemoveElement" class="btn btn-default" type="button" title="Borrar elemento" style="margin-right: 4px;" onclick="javascript: $('#dialog p').text(hashMessages['SeleccioneElemento']); $('#dialog').dialog({ buttons: {'Confirmar': function () { $(this).dialog('close'); }} });">
                                        <span class="fa fa-trash" aria-hidden="true"></span>
                                    </button>

                                    <div class='popbox3' style="margin-top: 15px; margin-right: 6px; display: none;"></div>
                                    <!-- popbox: Remove element -->
                                    <div class='box3 popbox3' id="divPopbox3" style="width: 300px; height: 240px; margin-top: 10px; right: 10%;">
                                        <div class='arrow' style="left: 250px;"></div>
                                        <div class='arrow-border' style="left: 250px;"></div>
                                        <div class="row row-short" style="padding: 10px;">
                                            <label class="label" style="font-size: 100%; color: rgba(68, 89, 156, 1); font-size: 16px;">Borrar elemento seleccionado</label>
                                        </div>
                                        <div class="form-group">
                                            <div class="row row-short" style="padding: 10px;">

                                                <div id="divRemoveElementMessage" class="alert alert-warning" role="alert">
                                                    <span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>
                                                    <span class="sr-only">Info:</span> Está a punto de borrar el elemento, confirme su contraseña para continuar
                                                </div>
                                                <input type="password" class="form-control" id="txbConfirmRemoveElement" placeholder="Contraseña" name="login-username" required="required" />
                                                <!--  -->
                                            </div>
                                            <div id="popbox_footer3" class="row row-short pull-right" style="margin-right: 15px; margin-top: -7px;">
                                                <button id="btnConfirmRemoveElement" type="button" class="btn btn-default" title="Confirmar borrar elemento" runat="server">
                                                    <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <button id="btnFullscreen" class="btn btn-default" type="button" title="Maximizar video" onclick="openFullscreen();"> <!-- goFullscreen() -->
                                        <span class="fa fa-arrows-alt" aria-hidden="true"></span>
                                    </button>

                                    <a id="aBtnFullscreen" class="btn btn-default" type="button" title="Maximizar video" style="margin-right: 4px; display: none;" href="Fullscreen.aspx">
                                        <span class="fa fa-arrows-alt" aria-hidden="true"></span>
                                    </a>
                                </div>
                            </div>

                        </div>

                    </div>
                    </div>
                </div>
                <div class="row no-gutter">
                    <div class='popbox' style="margin-right: 6px; display: inline-block;"></div>
                    <!-- popbox: Add comment -->
                    <div class='box popbox' style="width: 300px; min-height: 300px; max-height: 340px;">
                        <div class='arrow'></div>
                        <div class='arrow-border'></div>
                        <div class="row row-short" style="padding: 10px;">
                            <label class="label" style="font-size: 100%; color: rgba(68, 89, 156, 1); font-size: 16px;">Agregar un comentario al folio</label>
                        </div>
                        <div class="form-group">
                            <div class="col-md-12">
                                <input type="text" class="form-control" id="txbComment" placeholder="Comentario" name="login-username" required="required" />
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-12" style="margin-top: 10px;">
                                <input id="commentDate" class="form-control" data-inputmask="'alias': 'date'"/>
                                <!--  http://jongsma.org/software/protoplasm/control/timepicker -->
                            </div>
                        </div>

                        <div class="row row-short">
                                <label class="control-label" style="margin-top: 10px;">Folio destino</label>
                             <div id="divFolioSelection_addComment">
                            </div>
                                <!--  -->
                        </div>

                        <div class="form-group" style="position:absolute; width:100%">
                            <div class="col-md-12">
                                <label class="control-label" style="margin-bottom: 12px;">Duración (seg)</label>
                                <div class="layout-slider">
                                    <input id="sliderSingle1" type="slider" name="duracion" value="1" style="display: none;" />
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

                    <div class='popbox2' style="margin-right: 6px; display: none;"></div>
                    <!-- popbox: Upload file -->
                    <div class='box2 popbox2' style="width: 300px; min-height: 300px; max-height: 330px;">
                        <div class='arrow'></div>
                        <div class='arrow-border'></div>
                        <div class="row row-short" style="padding: 10px;">
                            <label id="popbox2_title" class="label" style="font-size: 100%; color: rgba(68, 89, 156, 1); font-size: 16px;">Subir elemento al folio</label>
                        </div>

                        <div class="row row-short">
                            <ul id="nav_popbox2" class="nav nav-tabs">
                                <li id="liUpload" onclick="return changeTab2(this);" class="active"><a name="nav_tabs" style="background: transparent;" href="#">Subir</a></li>
                                <li id="liCamera" onclick="return changeTab2(this);"><a style="background: transparent;" href="#">Cámaras</a></li>
                            </ul>
                        </div>

                        <div id="divUpload" class="form-group">
                            <div class="row row-short" style="padding: 10px;">
                                <label class="control-label">Documentos, videos y audios</label>
                                <input id="MyFileUpload" type="file" runat="server" class="file" style="width: 85%; margin: auto; margin-top: 8px; height: 24px;" />
                                <!--  -->
                            </div>
                             <div class="row row-short">
                                <label class="control-label">Folio destino</label>
                             <div id="divFolioSelection_fileUpload">
                            </div>
                                <!--  -->
                            </div>
                            <div class="form-group">
                                <div class="col-md-9" style="margin-top: 10px;">
                                    <input id="uploadDate" class="form-control" data-inputmask="'alias': 'date'" runat="server" />
                                </div>
                                <div class="col-md-3" style="margin-top: 10px;">
                                    <button id="btnConfirmUploadElement" type="button" class="btn btn-default" title="Subir" runat="server" onclick="prepareFileUpload_a();" onserverclick="btnConfirmUploadElement_ServerClick">
                                        <span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
                                    </button>
                                </div>
                            </div>
                            <br />

                        </div>

                        <div id="divCamaras" class="form-group" style="display: none;">
                            <div class="row row-short" style="padding: 10px;">
                                <label class="control-label">Asignar un video al sistema de cámaras</label>
                            </div>
                            <div class="form-group">
                                <div class="col-md-8" style="margin-top: 10px;">
                                    Número de cámara
								  <input type="text" class="form-control" id="txbInputCameraNumber" onkeypress='return event.charCode >= 48 && event.charCode <= 57' runat="server" style="margin-bottom: 5px;" />
                                    Inicio y fin de la grabación 
									<input id="camarasDate1" class="form-control" data-inputmask="'alias': 'date'" runat="server" />

                                    <input id="camarasDate2" class="form-control" data-inputmask="'alias': 'date'" runat="server" style="margin-top: 5px;" />

                                </div>
                                <div class="col-md-4" style="margin-top: 10px;">
                                    <div class="row row-short" style="margin-top: 110px;">
                                        <button id="btnConfirmUploadElement_b" type="button" class="btn btn-default pull-right" style="margin: 10px;" title="Subir" runat="server" onclick="prepareFileUpload_b();" onserverclick="btnConfirmUploadElement_ServerClick">
                                            <span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>
                                        </button>
                                    </div>
                                </div>

                            </div>

                        </div>

                    </div>
                </div>

                <div class="row no-gutter">

                    <!-- PANEL TIMELINE -->
                    <div id="globalPlayer_popup" class="unselectable">

                        <!-- GLOBALPLAY SCREEN -->
                        <div id="divgp_sc" class="globalplayBox img-rounded" style="display: none;">
                            <div id="flex_messages">                                

                            <div id="flex-messages-top" style="cursor:default;">
                                <div id="globalplay_divDocumentsName" class="flex-messages-top info-label">
                                    <h2 class="flex-messages-top-h2 label label-success"></h2>
                                </div>

                                <div id="globalplay_divAudioName" class="flex-messages-top info-label">
                                    <h2 class="flex-messages-top-h2 label label-danger"></h2>
                                </div>

                                <div id="globalplay_divVideoName" class="flex-messages-top info-label">
                                    <h2 class="flex-messages-top-h2 label label-danger" style="background-color: purple;"></h2>
                                </div>

                                <div id="globalplay_divSpecialMessages" class="flex-messages-top info-label">
                                    <h2 class="flex-messages-top-h2 label label-danger" style="background-color: rgb(55, 51, 51);"></h2>
                                </div>
                            </div>

                            <div id="flex-messages-bottom" style="cursor:default;">
                                <div id="globalplay_divComments" class="info-label" style="bottom: 16px; word-wrap: break-word;">
                                    <h2 class="flex-messages-top-h2 label label-warning" style="z-index: 1001; color: #474747; background-color:#FDFDF0; text-transform: none; font-size: 17px; width: 50%; margin: 0 auto; text-shadow: none;"></h2> 
                                </div>
                            </div>
                            </div>
                            <div class="flex">
                            </div>
                        </div>

                        <div id="divGlobalplay_timer" style="display: none;"></div>
                        <div id="divTimeline" class="divTimeline div-panel2 col-md-12 col-xs-12 img-rounded">
                            <h1 style="margin-top: 5px;">

                                <span class="special-title label label-primary" style="font-weight: normal;">Timeline</span>

                            </h1>

                            <div class="row" style="display: inline">

                                <div id="playerContainer" class="playerContainer col-md-2 img-rounded">
                                    <!-- img-rounded -->
                                    <div id="controlContainer" style="width: 100%; position: relative; top: 50%; transform: translate(0, -50%);"> 
                                        <ul class="globalplay_controls controls">

                                            <!-- Play/Pause button -->
                                            <li id="globalplay_play_li" class="img-rounded globalplay_play_li blue" style="position: relative; padding: 8px;">
                                                <a href="#divgp_sc" id="globalplay_play" class="push_button globalplay_play" data-attr="playPauseAudio" 
                                                    onclick="return globalplay_init()" style="position: relative; border: none; vertical-align:top;"></a>
                                                <a href="#globalPlayer_popup" id="btnOpenFancybox" style="display: none;"></a>
                                            </li>
                                            <!-- Stop button -->
                                            <li id="globalplay_stop_li" class="img-rounded blue">
                                                <a href="#divgp_sc" id="globalplay_stop" class="globalplay_stop" data-attr="nextAudio" 
                                                    onclick="return globalplay_stop()" style="padding: 14px; border: none; vertical-align:top;">
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                </div>

                                <!-- -->

                                <div id="divTimelineProgress" style="height: 8px; position: absolute;"></div> <!-- margin-top: 10px; -->
                                <!-- Contenedor draggable para el Progress Pointer -margin-top: -5px -->
                                <div id="timeframe" class="timeframe col-md-10" style="margin-top:-10px;">
                                </div>

                                <div id="sm2-inline-element" class="sm2-inline-element sm2-inline-status" style="position: absolute;">
                                    <div id="sm2-progress" class="sm2-progress">
                                        <div class="sm2-row">
                                            <div id="sm2-progress-bd" class="sm2-progress-bd">
                                                <div id="sm2-progress-track" class="sm2-progress-track sm2-progress-track2">
                                                    <div id="sm2-progress-bar" class="sm2-progress-bar sm2-progress-bar2"></div>

                                                    <div id="sm2-progress-ball_TIMELINE" class="sm2-progress-ball sm2-progress-ball2" style="display: none;">
                                                        <div id="icon-overlay" class="icon-overlay icon-overlay2"></div>
                                                        <img id="imgPointer" src="assets/images/pointer.png" style="width: 20px; margin-top: -45px; margin-left: -5px;" />

                                                        <div id="vertical-line-progress-left" style="width: 5px; height: 130px; border-right: 2px solid black; position: absolute; margin-top: -10px; /* margin-left: -4px; */border-bottom: 2px solid black;"></div>
                                                        <div id="vertical-line-progress-right" style="width: 5px; height: 130px; border-left: 2px solid black; position: absolute; margin-top: -10px; margin-left: 3px; border-bottom: 2px solid black;"></div>

                                                    </div>

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>

                            <!-- popbox: Runtime Timelapse -->
                            <div class='popbox4' style="margin-top: 15px; margin-right: 6px; display: none;"></div>
                            <div class='box4 popbox4' style="width: 150px; height: 40px; opacity: 0.9; background-color: lightgrey;">
                                <div class='arrow-down' style="opacity: 0.9;"></div>
                                <div class='arrow-border-down'></div>
                                <div class="row row-short" style="padding: 10px;">
                                    <label id="lblPopbox4" class="label" style="font-size: 100%; color: black;"></label>
                                </div>
                            </div>

                        </div>
                        <div style="clear: both;"></div>
                    </div>

                    <div class="col-md-12 img-rounded" style="background-color: whitesmoke; height: 100%; z-index: 0; width: 100.5%; left: 0; margin-left: -5px;">
                    </div>
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
        <asp:HiddenField ID="_hdnGlobalplay_maxCollisionElements" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="_hdnElementsToDownload" runat="server" ClientIDMode="Static" />

        <!-- -->
        <asp:HiddenField ID="_hdnFolioID_selected" runat="server" ClientIDMode="Static" />

    </form>
</asp:Content>
