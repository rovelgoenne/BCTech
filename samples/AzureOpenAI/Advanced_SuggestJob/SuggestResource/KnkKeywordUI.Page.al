namespace CopilotToolkitDemo.SuggestResource;

using Microsoft.Projects.Project.Planning;
using CopilotToolkitDemo.DescribeJob;
using Microsoft.Projects.Resources.Resource;

page 54323 "knkKeywords Proposal"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    Caption = 'Create structered keywords';
    DataCaptionExpression = KnkProject."Main Title" + ',' + KnkProject.Subtitle + ',' + ChatRequest;

    layout
    {
        area(Prompt)
        {
            //add field to set the tone of the resquest

            field(ProjectLongtext; Longtext)
            {
                Caption = 'Project longtext';
                MultiLine = true;
                ApplicationArea = All;
                Editable = false;
                trigger OnAssistEdit()
                begin
                    Message(Longtext);
                end;
            }
            // field(Tone; Tone)
            // {
            //     Caption = 'Tone';
            //     ApplicationArea = All;
            // }
            // field(MaxLength; MaxLength)
            // {
            //     Caption = 'Max length';
            //     ApplicationArea = All;
            // }
            field(LanguageOptions; LanguageOptions)
            {
                Caption = 'Language';
                ApplicationArea = All;
            }
            field(ChatRequest; ChatRequest)
            {
                Caption = 'Additional notes';
                MultiLine = true;
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }
        area(Content)
        {
            field(ProjectShorttext; Response)
            {
                Caption = 'Result JSON';
                MultiLine = true;
                ApplicationArea = All;
                trigger OnAssistEdit()
                begin
                    Message(Response);
                end;
            }
        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate Resource proposal with Dynamics 365 Copilot.';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Confirm';
                ToolTip = 'Create a shorttext for the project.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard Resource proposed by Dynamics 365 Copilot.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate Resource proposal with Dynamics 365 Copilot.';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        MaxLength := 1000;
    end;

    // trigger OnQueryClosePage(CloseAction: Action): Boolean
    // var
    //     metadatamgt: Codeunit "KnkMetadata Mgt.";
    //     Metadata: Record KnkMetadata;
    // begin
    //     if CloseAction = CloseAction::OK then begin
    //         Metadata.Reset();
    //         metadata.SetRange("Source Record SystemId", KnkProject."SystemId");
    //         metadata.SetRange("Table ID", Database::KnkProject);
    //         metadata.SetRange("Property Code", 'SHORTTEXT');
    //         if metadata.FindFirst() then begin
    //             Metadata.Position := KnkProject.GetPosition(false);
    //             metadata."Property Value" := copystr(Response, 1, MaxStrLen(metadata."Property Value"));
    //             metadata.Modify();
    //         end else begin
    //             metadata.Init();
    //             Metadata.Position := KnkProject.GetPosition(false);
    //             metadata."Source Record SystemId" := KnkProject."SystemId";
    //             metadata."Table ID" := Database::KnkProject;
    //             metadata.validate("Property Code", 'SHORTTEXT');
    //             metadata."Property Value" := copystr(Response, 1, MaxStrLen(metadata."Property Value"));
    //             metadata.Insert();
    //         end;
    //     end;

    //     exit(true);
    // end;

    local procedure RunGeneration()
    var
        TempCopilotResourceProposal: Record "Copilot Resource Proposal" temporary;
        GenResourceProposal: Codeunit "Generate Resource Proposal";
        KnkGenerateProposal: Codeunit "KnkGenerate Proposal";
        InStr: InStream;
        Attempts: Integer;

    begin        
        JSONStructure := CreateJSONStructure();
        Response := KnkGenerateProposal.GenerateStructuredKeywords(Longtext, ChatRequest, JSONStructure, LanguageOptions);
    end;

    local procedure FindLongTextInMetadata(var KnkProject2: Record KnkProject)
    var
        KnkContentSetup: Record "KnkContent Setup";
        KnkCommentMgt: Codeunit "KnkComment Mgt.";
        LongTextProperty: text;
    begin
        if knkcontentsetup.get() then
            if knkcontentsetup."Preview Text Long" <> '' then begin
                LongTextProperty := knkcontentsetup."Preview Text Long";
            end else
                LongTextProperty := 'LONGTEXT';

        KnkMetadata.Reset();
        KnkMetadata.SetRange("Source Record SystemId", KnkProject2."SystemId");
        KnkMetadata.SetRange("Table ID", Database::KnkProject);
        KnkMetadata.SetRange("Property Code", LongTextProperty);
        if KnkMetadata.FindFirst() then
            if KnkCommentMgt.ExistsComment(KnkMetadata.RecordId) then
                Longtext := KnkCommentMgt.GetComment(KnkMetadata.RecordId, 0, 0);
    end;

    local procedure CreateJSONStructure(): Text
    var
        JSONStructure: Text;
        Metadata: Record KnkMetadata;        
    begin
        Metadata.Reset();
        Metadata.setrange("Table ID", Database::KnkProject);
        Metadata.setrange("Source Record SystemId", KnkProject."SystemId");
        Metadata.SetFilter("Property Code", '<>%1', 'LONGTEXT');
        if Metadata.findset(false) then begin
            JSONStructure := '{';
            repeat
                JSONStructure := JSONStructure + ',' + Metadata."Property Code" + ':[]';
            until Metadata.next() = 0;
            JSONStructure := JSONStructure + '}';
        end else
            JSONStructure := '{"Location":[],"Time":[],"Actor":[Names],"Mood":[]}';
        exit(JSONStructure);
    end;


    procedure SetJobPlanningLine(JobPlanningLine2: Record "Job Planning Line")
    begin
        JobPlanningLine := JobPlanningLine2;
    end;

    procedure SetKnkProject(KnkProject2: Record KnkProject)
    begin
        KnkProject := KnkProject2;
        FindLongTextInMetadata(KnkProject2);
    end;

    var
        SomethingWentWrongErr: Label 'Something went wrong. Please try again.';
        SomethingWentWrongWithLatestErr: Label 'Something went wrong. Please try again. The latest error is: %1';
        JobPlanningLine: Record "Job Planning Line";
        KnkProject: Record KnkProject;
        KnkMetadata: Record "KnkMetadata";
        ChatRequest: Text;
        Longtext: Text;
        Response: Text;
        MaxLength: Integer;
        LanguageOptions: Option DEU,ENG,FRA,ITA,NLD,SPA;
        tone: Option Positive,Negative,Neutral;
        JSONStructure: Text;

}

// create a new page from type PromptDialog. 
// This page will be used to display the result of the Copilot suggestion.
// The page will be opened from the knkproject list page.
// The copilot suggestion will be triggered from the knkproject list page.
// the suggestion will be created based on the main title, subtitle and the chat request.