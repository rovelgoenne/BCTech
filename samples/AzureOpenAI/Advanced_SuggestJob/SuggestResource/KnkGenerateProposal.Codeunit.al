namespace CopilotToolkitDemo.SuggestResource;

using CopilotToolkitDemo.Common;
using System.IO;
using System.Utilities;
using Microsoft.Service.Setup;
using Microsoft.Service.Resources;
using Microsoft.Foundation.Period;
using Microsoft.Projects.Resources.Resource;

codeunit 54350 "KnkGenerate Proposal"
{
    procedure GenerateShortDescription(LongDescription: Text; InputUserPrompt: Text; MaxLength: Integer; LanguageOption: Option; Tone: Option) ShortDescription: Text
    begin
        UserPrompt := InputUserPrompt;
        GLobalLanguageOption := LanguageOption;
        GLobalMaxLength := MaxLength;
        GlobalTone := Tone;
        ShortDescription := GenerateShortDescriptionProposal(LongDescription);
    end;

    procedure GenerateStructuredKeywords(LongDescription: Text; InputUserPrompt: Text; JSONStructure: Text; LanguageOption: Option) Response: Text
    begin
        UserPrompt := InputUserPrompt;
        GLobalLanguageOption := LanguageOption;
        Response := GenerateKeyWordProposal(LongDescription, JSONStructure);
    end;

    procedure SetTask(InputJobDescription: Text; InputJobRoleDescription: Text)
    begin
        JobDescription := InputJobDescription;
        JobRoleDescription := InputJobRoleDescription;
    end;

    procedure GetResult(var TempCopilotResourceProposal2: Record "Copilot Resource Proposal" temporary)
    begin
        TempCopilotResourceProposal2.Copy(TempCopilotResourceProposal, true);
    end;

    local procedure GenerateShortDescriptionProposal(LongDescription: Text) Response: text;
    var
        SimplifiedCopilotChat: Codeunit "Simplified Copilot Chat";
    begin
        Response := SimplifiedCopilotChat.Chat(GetSystemPromptShortText(), GetUserPrompt(LongDescription))
    end;

    local procedure GenerateKeyWordProposal(LongDescription: Text; JSONStructure: Text) Response: text;
    var
        SimplifiedCopilotChat: Codeunit "Simplified Copilot Chat";
    begin
        Response := SimplifiedCopilotChat.Chat(GetSystemPromptStructuredKeywords(JSONStructure), GetUserPrompt(LongDescription))
    end;

    procedure RemoveNewLineCharacters(InputString: Text): Text
    var
        Regex: Codeunit Regex;
        OutputString: Text;
    begin
        OutputString := Regex.Replace(InputString, '/(\r\n|\n|\r)/gm', '');
        exit(OutputString);
    end;

    local procedure GetSystemPromptShortText() SystemPrompt: Text
    begin
        SystemPrompt += 'The user will provide a long description of a media project and optionally some additional notes.' +
                   'Your goal is to create a short summary of the long description. The maximum number of characters is ' + format(GLobalMaxLength) +
                    ', the tone should be ' + GetTone(GlobalTone) + '. The short description should be create in the language ' + GetLanguageOptionText(GLobalLanguageOption);
    end;

    local procedure GetSystemPromptStructuredKeywords(JSONStructure: Text) SystemPrompt: Text
    begin
        SystemPrompt += 'The user will provide a long description of a media project and optionally some additional notes.' +
                   'Your goal is to create a structued JSON with keywords that describe the long description. Use the following JSON Structure: ' + JSONStructure + '. The keywords should be create in the language ' + GetLanguageOptionText(GLobalLanguageOption);
    end;

    local procedure CalculateResourceCapacity(Resource: Record Resource) UnusedCapacity: Decimal
    var
        DateFilterCalc: Codeunit "DateFilter-Calc";
        ResDateFilter: Text[30];
        ResDateName: Text[30];
        CurrentDate: Date;
        TotalUsageUnits: Decimal;
        Chargeable: Boolean;
        ResCapacity: Decimal;
        j: Integer;
    begin
        if CurrentDate <> WorkDate() then begin
            CurrentDate := WorkDate();
            DateFilterCalc.CreateFiscalYearFilter(ResDateFilter, ResDateName, CurrentDate, 0);
        end;

        Clear(TotalUsageUnits);

        Resource.SetFilter("Date Filter", ResDateFilter);
        Resource.SetRange("Chargeable Filter");
        Resource.CalcFields(Capacity, "Usage (Cost)", "Sales (Price)");

        ResCapacity := Resource.Capacity;

        for j := 1 to 2 do begin
            if j = 1 then
                Chargeable := false
            else
                Chargeable := true;
            Resource.SetRange("Chargeable Filter", Chargeable);
            Resource.CalcFields("Usage (Qty.)", "Usage (Price)");
            TotalUsageUnits := TotalUsageUnits + Resource."Usage (Qty.)";
        end;

        UnusedCapacity := ResCapacity - TotalUsageUnits;
    end;

    local procedure GetUserPrompt(LongDescription: Text) OutputUserPrompt: Text
    var
        // Resource: Record Resource;
        Newline: Char;
        LeftoverCapacity: Decimal;
    begin
        Newline := 10;
        OutputUserPrompt := 'Here is the long description: ' + LongDescription;
        OutputUserPrompt += StrSubstNo('This is the additional notes: %1.', UserPrompt);

    end;

    local procedure GetLanguageOptionText(GLobalLanguageOption: Option): Text
    begin
        case GLobalLanguageOption of
            0:
                exit('German');
            1:
                exit('English');
            2:
                exit('French');
            5:
                exit('Spanish');
            3:
                exit('Italian');
            4:
                exit('Dutch');
        end;
    end;

    local procedure GetTone(GlobalTone: Option): Text
    begin
        case GlobalTone of
            2:
                exit('neutral');
            0:
                exit('positive');
            1:
                exit('negative');
        end;
    end;

    var
        TempCopilotResourceProposal: Record "Copilot Resource Proposal" temporary;
        UserPrompt: Text;
        JobDescription: Text;
        JobRoleDescription: Text;

        GLobalLanguageOption: Option;
        GlobalTone: Option;
        GLobalMaxLength: Integer;
}