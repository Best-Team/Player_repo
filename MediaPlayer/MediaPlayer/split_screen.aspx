<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="split_screen.aspx.cs" Inherits="MediaPlayer.ExternalResources.split_screen" MasterPageFile="~/Site.Master" %>

<asp:content id="Content2" ContentPlaceHolderID="ContentHeader" runat="server">

    <script src="assets/js/jquery.flex.js"></script>


	<title>jQuery plugin - Flex - Demo</title>
	<style>
		body {background-color:#CCC;font-family:Verdana;}
		.flex {position:relative;width:850px;min-height:300px;margin:0 auto;border:0px solid red;margin-top:10px;}
		.flex a {background-color:white;display:block;width:100px;height:100px;border-radius:8px;position:absolute;background-repeat:no-repeat;background-position:center;border:3px solid white;cursor:pointer;text-align:left;text-shadow:1px 1px 20px #000;color:white;font-size:18px;font-weight:bold;text-indent:10px;line-height:30px;text-decoration:none;}
		[bg=a] {background-image:url(http://farm8.staticflickr.com/7013/6448917381_0b754e86fb_z.jpg);}
		[bg=b] {background-image:url(http://farm9.staticflickr.com/8156/7362866426_bf285ebd45.jpg);;}
		[bg=c] {background-image:url(http://farm6.staticflickr.com/5117/7410370290_0935419fc3.jpg);}
		[bg=d] {background-image:url(http://farm8.staticflickr.com/7262/7419245080_bb752ed1d6.jpg);}
		[bg=e] {background-image:url(http://farm8.staticflickr.com/7003/6468321069_3375be3073_z.jpg);background-size:auto 280px;}
		[bg=f] {background-image:url(http://farm8.staticflickr.com/7220/7342556872_46cddaf9b0.jpg);background-size:auto 280px;}
		[bg=g] {background-image:url(http://farm9.staticflickr.com/8021/7322604950_348c535903.jpg);background-size:auto 200px;}
		[bg=h] {background-image:url(http://farm8.staticflickr.com/7076/7286717012_6e6b450243.jpg);}
		[bg=i] {background-image:url(http://farm8.staticflickr.com/7129/7452167788_a3f6aa3104.jpg);background-size:auto 200px;}
		[bg=j] {background-image:url(http://farm8.staticflickr.com/7153/6480022425_a8d419e663_z.jpg);background-size:auto 280px;}
		[bg=k] {background-image:url(http://farm8.staticflickr.com/7225/7269592732_c4b7918626.jpg);background-size:auto 450px;}
		h1, h3 {width:850px;font-weight:normal;margin:0 auto;}
		h1 {margin-top:100px;}
		h3 {color:#666;margin-top:5px;}
		p {width:850px;margin:0;padding:0;margin:0 auto;font-size:14px;color:black;margin-top:0px;margin-bottom:20px;color:#989898;}
		#buttons {height:75px;width:850px;margin:0 auto;margin-top:10px;}
		#buttons a {float:left}
		.marginleft {margin-left:25px;}
	</style>
	<script src="jquery.flex.js"></script>
	<script type="text/javascript">
	    $(function () {
	        $(".flex").flex();
	    });
	</script>

</asp:content>

<asp:content id="Content1" ContentPlaceHolderID="ContentBody" runat="server">

	<div class="flex">
		<a bg="a" style="left:0px;top:0px;width:250px;height:250px;" width="600" height="600" title="Hola holaaa">A</a>
		<a bg="b" style="left:290px;top:0px;width:250px;height:250px;" width="350" height="350">B</a>
		<a bg="g" style="left:0px;top:280px;width:250px;height:250px;" width="350" height="350">G</a>
		<a bg="h" style="left:290px;top:280px;width:250px;height:250px;" width="350" height="350">H</a>
		<a bg="c" style="left:580px;top:0px;width:250px;height:250px;" width="350" height="350">H</a>
		<a bg="d" style="left:580px;top:280px;width:250px;height:250px;" width="350" height="350">H</a>
	</div>
	
</asp:content>
