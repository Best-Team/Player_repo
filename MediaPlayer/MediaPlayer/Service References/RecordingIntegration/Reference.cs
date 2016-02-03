﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.34209
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace MediaPlayer.RecordingIntegration {
    
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ServiceModel.ServiceContractAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", ConfigurationName="RecordingIntegration.OperacionesGrabacionSoapBinding")]
    public interface OperacionesGrabacionSoapBinding {
        
        // CODEGEN: Parameter 'reproduccionFolioReturn' requires additional schema information that cannot be captured using the parameter mode. The specific attribute is 'System.Xml.Serialization.XmlArrayItemAttribute'.
        [System.ServiceModel.OperationContractAttribute(Action="http://grabacion.interfaces.esb.promad.com/reproduccionFolio", ReplyAction="*")]
        [System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults=true)]
        [return: System.ServiceModel.MessageParameterAttribute(Name="reproduccionFolioReturn")]
        MediaPlayer.RecordingIntegration.reproduccionFolioResponse reproduccionFolio(MediaPlayer.RecordingIntegration.reproduccionFolioRequest request);
        
        // CODEGEN: Parameter 'seleccionFolioUnidadReturn' requires additional schema information that cannot be captured using the parameter mode. The specific attribute is 'System.Xml.Serialization.XmlArrayItemAttribute'.
        [System.ServiceModel.OperationContractAttribute(Action="http://grabacion.interfaces.esb.promad.com/seleccionFolioUnidad", ReplyAction="*")]
        [System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults=true)]
        [return: System.ServiceModel.MessageParameterAttribute(Name="seleccionFolioUnidadReturn")]
        MediaPlayer.RecordingIntegration.seleccionFolioUnidadResponse seleccionFolioUnidad(MediaPlayer.RecordingIntegration.seleccionFolioUnidadRequest request);
        
        // CODEGEN: Parameter 'sincronizaUsuarioReturn' requires additional schema information that cannot be captured using the parameter mode. The specific attribute is 'System.Xml.Serialization.XmlArrayItemAttribute'.
        [System.ServiceModel.OperationContractAttribute(Action="http://grabacion.interfaces.esb.promad.com/sincronizaUsuario", ReplyAction="*")]
        [System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults=true)]
        [return: System.ServiceModel.MessageParameterAttribute(Name="sincronizaUsuarioReturn")]
        MediaPlayer.RecordingIntegration.sincronizaUsuarioResponse sincronizaUsuario(MediaPlayer.RecordingIntegration.sincronizaUsuarioRequest request);
        
        // CODEGEN: Parameter 'videoAsociadoReturn' requires additional schema information that cannot be captured using the parameter mode. The specific attribute is 'System.Xml.Serialization.XmlArrayItemAttribute'.
        [System.ServiceModel.OperationContractAttribute(Action="http://grabacion.interfaces.esb.promad.com/videoAsociado", ReplyAction="*")]
        [System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults=true)]
        [return: System.ServiceModel.MessageParameterAttribute(Name="videoAsociadoReturn")]
        MediaPlayer.RecordingIntegration.videoAsociadoResponse videoAsociado(MediaPlayer.RecordingIntegration.videoAsociadoRequest request);
        
        // CODEGEN: Parameter 'notificacionVideoReturn' requires additional schema information that cannot be captured using the parameter mode. The specific attribute is 'System.Xml.Serialization.XmlArrayItemAttribute'.
        [System.ServiceModel.OperationContractAttribute(Action="http://grabacion.interfaces.esb.promad.com/notificacionVideo", ReplyAction="*")]
        [System.ServiceModel.XmlSerializerFormatAttribute(SupportFaults=true)]
        [return: System.ServiceModel.MessageParameterAttribute(Name="notificacionVideoReturn")]
        MediaPlayer.RecordingIntegration.notificacionVideoResponse notificacionVideo(MediaPlayer.RecordingIntegration.notificacionVideoRequest request);
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="reproduccionFolio", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class reproduccionFolioRequest {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        public string folio;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=1)]
        public string usuario;
        
        public reproduccionFolioRequest() {
        }
        
        public reproduccionFolioRequest(string folio, string usuario) {
            this.folio = folio;
            this.usuario = usuario;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="reproduccionFolioResponse", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class reproduccionFolioResponse {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        [System.Xml.Serialization.XmlArrayItemAttribute("item", Form=System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable=false)]
        public object[] reproduccionFolioReturn;
        
        public reproduccionFolioResponse() {
        }
        
        public reproduccionFolioResponse(object[] reproduccionFolioReturn) {
            this.reproduccionFolioReturn = reproduccionFolioReturn;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="seleccionFolioUnidad", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class seleccionFolioUnidadRequest {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        public string usuario;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=1)]
        public string ip;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=2)]
        public string folio;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=3)]
        public string rfsi;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=4)]
        public System.DateTime timeStamp;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=5)]
        public string status;
        
        public seleccionFolioUnidadRequest() {
        }
        
        public seleccionFolioUnidadRequest(string usuario, string ip, string folio, string rfsi, System.DateTime timeStamp, string status) {
            this.usuario = usuario;
            this.ip = ip;
            this.folio = folio;
            this.rfsi = rfsi;
            this.timeStamp = timeStamp;
            this.status = status;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="seleccionFolioUnidadResponse", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class seleccionFolioUnidadResponse {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        [System.Xml.Serialization.XmlArrayItemAttribute("item", Form=System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable=false)]
        public object[] seleccionFolioUnidadReturn;
        
        public seleccionFolioUnidadResponse() {
        }
        
        public seleccionFolioUnidadResponse(object[] seleccionFolioUnidadReturn) {
            this.seleccionFolioUnidadReturn = seleccionFolioUnidadReturn;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="sincronizaUsuario", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class sincronizaUsuarioRequest {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        public string cuenta;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=1)]
        public string clave;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=2)]
        public string tipoUsuario;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=3)]
        public string opcion;
        
        public sincronizaUsuarioRequest() {
        }
        
        public sincronizaUsuarioRequest(string cuenta, string clave, string tipoUsuario, string opcion) {
            this.cuenta = cuenta;
            this.clave = clave;
            this.tipoUsuario = tipoUsuario;
            this.opcion = opcion;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="sincronizaUsuarioResponse", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class sincronizaUsuarioResponse {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        [System.Xml.Serialization.XmlArrayItemAttribute("item", Form=System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable=false)]
        public object[] sincronizaUsuarioReturn;
        
        public sincronizaUsuarioResponse() {
        }
        
        public sincronizaUsuarioResponse(object[] sincronizaUsuarioReturn) {
            this.sincronizaUsuarioReturn = sincronizaUsuarioReturn;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="videoAsociado", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class videoAsociadoRequest {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        public string folio;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=1)]
        public string usuario;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=2)]
        public string numeroCamara;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=3)]
        public string timeStampInicio;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=4)]
        public string timeStampFin;
        
        public videoAsociadoRequest() {
        }
        
        public videoAsociadoRequest(string folio, string usuario, string numeroCamara, string timeStampInicio, string timeStampFin) {
            this.folio = folio;
            this.usuario = usuario;
            this.numeroCamara = numeroCamara;
            this.timeStampInicio = timeStampInicio;
            this.timeStampFin = timeStampFin;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="videoAsociadoResponse", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class videoAsociadoResponse {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        [System.Xml.Serialization.XmlArrayItemAttribute("item", Form=System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable=false)]
        public object[] videoAsociadoReturn;
        
        public videoAsociadoResponse() {
        }
        
        public videoAsociadoResponse(object[] videoAsociadoReturn) {
            this.videoAsociadoReturn = videoAsociadoReturn;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="notificacionVideo", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class notificacionVideoRequest {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        public string fileName;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=1)]
        public bool status;
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=2)]
        public string description;
        
        public notificacionVideoRequest() {
        }
        
        public notificacionVideoRequest(string fileName, bool status, string description) {
            this.fileName = fileName;
            this.status = status;
            this.description = description;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(WrapperName="notificacionVideoResponse", WrapperNamespace="http://grabacion.interfaces.esb.promad.com", IsWrapped=true)]
    public partial class notificacionVideoResponse {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Namespace="http://grabacion.interfaces.esb.promad.com", Order=0)]
        [System.Xml.Serialization.XmlArrayItemAttribute("item", Form=System.Xml.Schema.XmlSchemaForm.Unqualified, IsNullable=false)]
        public object[] notificacionVideoReturn;
        
        public notificacionVideoResponse() {
        }
        
        public notificacionVideoResponse(object[] notificacionVideoReturn) {
            this.notificacionVideoReturn = notificacionVideoReturn;
        }
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public interface OperacionesGrabacionSoapBindingChannel : MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding, System.ServiceModel.IClientChannel {
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public partial class OperacionesGrabacionSoapBindingClient : System.ServiceModel.ClientBase<MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding>, MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding {
        
        public OperacionesGrabacionSoapBindingClient() {
        }
        
        public OperacionesGrabacionSoapBindingClient(string endpointConfigurationName) : 
                base(endpointConfigurationName) {
        }
        
        public OperacionesGrabacionSoapBindingClient(string endpointConfigurationName, string remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public OperacionesGrabacionSoapBindingClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public OperacionesGrabacionSoapBindingClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(binding, remoteAddress) {
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        MediaPlayer.RecordingIntegration.reproduccionFolioResponse MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding.reproduccionFolio(MediaPlayer.RecordingIntegration.reproduccionFolioRequest request) {
            return base.Channel.reproduccionFolio(request);
        }
        
        public object[] reproduccionFolio(string folio, string usuario) {
            MediaPlayer.RecordingIntegration.reproduccionFolioRequest inValue = new MediaPlayer.RecordingIntegration.reproduccionFolioRequest();
            inValue.folio = folio;
            inValue.usuario = usuario;
            MediaPlayer.RecordingIntegration.reproduccionFolioResponse retVal = ((MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding)(this)).reproduccionFolio(inValue);
            return retVal.reproduccionFolioReturn;
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        MediaPlayer.RecordingIntegration.seleccionFolioUnidadResponse MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding.seleccionFolioUnidad(MediaPlayer.RecordingIntegration.seleccionFolioUnidadRequest request) {
            return base.Channel.seleccionFolioUnidad(request);
        }
        
        public object[] seleccionFolioUnidad(string usuario, string ip, string folio, string rfsi, System.DateTime timeStamp, string status) {
            MediaPlayer.RecordingIntegration.seleccionFolioUnidadRequest inValue = new MediaPlayer.RecordingIntegration.seleccionFolioUnidadRequest();
            inValue.usuario = usuario;
            inValue.ip = ip;
            inValue.folio = folio;
            inValue.rfsi = rfsi;
            inValue.timeStamp = timeStamp;
            inValue.status = status;
            MediaPlayer.RecordingIntegration.seleccionFolioUnidadResponse retVal = ((MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding)(this)).seleccionFolioUnidad(inValue);
            return retVal.seleccionFolioUnidadReturn;
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        MediaPlayer.RecordingIntegration.sincronizaUsuarioResponse MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding.sincronizaUsuario(MediaPlayer.RecordingIntegration.sincronizaUsuarioRequest request) {
            return base.Channel.sincronizaUsuario(request);
        }
        
        public object[] sincronizaUsuario(string cuenta, string clave, string tipoUsuario, string opcion) {
            MediaPlayer.RecordingIntegration.sincronizaUsuarioRequest inValue = new MediaPlayer.RecordingIntegration.sincronizaUsuarioRequest();
            inValue.cuenta = cuenta;
            inValue.clave = clave;
            inValue.tipoUsuario = tipoUsuario;
            inValue.opcion = opcion;
            MediaPlayer.RecordingIntegration.sincronizaUsuarioResponse retVal = ((MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding)(this)).sincronizaUsuario(inValue);
            return retVal.sincronizaUsuarioReturn;
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        MediaPlayer.RecordingIntegration.videoAsociadoResponse MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding.videoAsociado(MediaPlayer.RecordingIntegration.videoAsociadoRequest request) {
            return base.Channel.videoAsociado(request);
        }
        
        public object[] videoAsociado(string folio, string usuario, string numeroCamara, string timeStampInicio, string timeStampFin) {
            MediaPlayer.RecordingIntegration.videoAsociadoRequest inValue = new MediaPlayer.RecordingIntegration.videoAsociadoRequest();
            inValue.folio = folio;
            inValue.usuario = usuario;
            inValue.numeroCamara = numeroCamara;
            inValue.timeStampInicio = timeStampInicio;
            inValue.timeStampFin = timeStampFin;
            MediaPlayer.RecordingIntegration.videoAsociadoResponse retVal = ((MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding)(this)).videoAsociado(inValue);
            return retVal.videoAsociadoReturn;
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        MediaPlayer.RecordingIntegration.notificacionVideoResponse MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding.notificacionVideo(MediaPlayer.RecordingIntegration.notificacionVideoRequest request) {
            return base.Channel.notificacionVideo(request);
        }
        
        public object[] notificacionVideo(string fileName, bool status, string description) {
            MediaPlayer.RecordingIntegration.notificacionVideoRequest inValue = new MediaPlayer.RecordingIntegration.notificacionVideoRequest();
            inValue.fileName = fileName;
            inValue.status = status;
            inValue.description = description;
            MediaPlayer.RecordingIntegration.notificacionVideoResponse retVal = ((MediaPlayer.RecordingIntegration.OperacionesGrabacionSoapBinding)(this)).notificacionVideo(inValue);
            return retVal.notificacionVideoReturn;
        }
    }
}
