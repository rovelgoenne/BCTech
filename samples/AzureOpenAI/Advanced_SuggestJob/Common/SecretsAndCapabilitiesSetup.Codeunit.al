namespace CopilotToolkitDemo.Common;

using System.AI;
using System.Environment;

codeunit 54310 "Secrets And Capabilities Setup"
{
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        cd: Codeunit "AOAI Deployments";
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        IsolatedStorageWrapper: Codeunit "Isolated Storage Wrapper";
        LearnMoreUrlTxt: Label 'https://example.com/CopilotToolkit', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Describe Job") then
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Describe Job", Enum::"Copilot Availability"::Preview, LearnMoreUrlTxt);

        // You will need to use your own key for Azure OpenAI for all your Copilot features (for both development and production).
        // Error('Set up your secrets here before publishing the app.');
        IsolatedStorageWrapper.SetSecretKey('3906db9f22324cc0b5757d78abee8101');
        IsolatedStorageWrapper.SetDeployment('PDEGPT41106PREVIEW');
        IsolatedStorageWrapper.SetEndpoint('https://knkgpt4sweden.openai.azure.com/');
    end;
}