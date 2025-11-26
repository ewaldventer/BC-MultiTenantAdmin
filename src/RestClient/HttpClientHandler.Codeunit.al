// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace EwaldVenter.TenantAdmin.RestClient;

using System.RestClient;

codeunit 72000 "Http Client Handler EV" implements "Http Client Handler"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure Send(CurrHttpClientInstance: HttpClient; HttpRequestMessage: Codeunit "Http Request Message"; var HttpResponseMessage: Codeunit "Http Response Message") Success: Boolean;
    var
        ResponseMessage: HttpResponseMessage;
    begin
        Success := CurrHttpClientInstance.Send(HttpRequestMessage.GetHttpRequestMessage(), ResponseMessage);
        HttpResponseMessage := HttpResponseMessage.Create(ResponseMessage);
    end;
}