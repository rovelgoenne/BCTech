pageextension 54303 LicenseContractCopilot extends "KnkLicense Contract List"
{
     actions
    {
        addafter("&Functions")
        {
            group(Copilot)
            {
                action(SuggestStructuredKeywords)
                {
                    Caption = 'Suggest Structured Keywords';
                    ToolTip = 'Asks Copilot for structured keywords for the License Contract. You will have to confirm the suggestion from Copilot.';
                    Image = Sparkle;
                    ApplicationArea = All;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        SuggestStructuredKeywordsWithAI(Rec);
                    end;
                }
            }
        }
    }

    procedure SuggestStructuredKeywordsWithAI(var licenseContract: Record "knkLicense Contract");
    var
        KeywordsAIProposal: Page "knkLicenseKeywords Proposal";
    begin
        KeywordsAIProposal.SetLicenseContract(licenseContract);
        KeywordsAIProposal.RunModal();
        CurrPage.Update(false);
    end;
   
}