<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SessionCheck.aspx.cs" Inherits="MediaPlayer.SessionCheck" %>

{"valid":<%=Session["UserID"] != null ? "true" : "false" %>}
