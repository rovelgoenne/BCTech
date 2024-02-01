namespace CopilotToolkitDemo.SuggestResource;

using Microsoft.Projects.Project.Planning;

pageextension 54350 "knkProjectCard Copilot" extends "KnkProject List"
{

    actions
    {
        addafter("Item C&ard")
        {
            group(Copilot)
            {
                action(SuggestShortText)
                {
                    Caption = 'Suggest Short Text';
                    ToolTip = 'Asks Copilot for a short text for the project. You will have to confirm the suggestion from Copilot.';
                    Image = Sparkle;
                    ApplicationArea = All;
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        SuggestShortTextWithAI(Rec);
                    end;
                }
                action(SuggestStructuredKeywords)
                {
                    Caption = 'Suggest Structured Keywords';
                    ToolTip = 'Asks Copilot for structured keywords for the project. You will have to confirm the suggestion from Copilot.';
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

    procedure SuggestShortTextWithAI(var knkProject: Record "knkproject");
    var
        ShortTextAIProposal: Page "knkShort Text Proposal";
    begin
        ShortTextAIProposal.SetKnkProject(knkProject);
        ShortTextAIProposal.RunModal();
        CurrPage.Update(false);
    end;

    procedure SuggestStructuredKeywordsWithAI(var knkProject: Record "knkproject");
    var
        KeywordsAIProposal: Page "knkKeywords Proposal";
    begin
        KeywordsAIProposal.SetKnkProject(knkProject);
        KeywordsAIProposal.RunModal();
        CurrPage.Update(false);
    end;

}