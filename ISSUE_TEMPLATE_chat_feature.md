# GitHub Issue: Add Chat Page with Microsoft Foundry Phi4 Integration

> **To create this issue on GitHub:**
> 1. Run `gh auth login` to authenticate with GitHub CLI
> 2. Then run: `gh issue create --title "Add Chat Page with Microsoft Foundry Phi4 Integration" --body-file ISSUE_TEMPLATE_chat_feature.md`
> 3. Or manually create the issue at: https://github.com/Zava-Labs-element824/TechWorkshop-L300-GitHub-Copilot-and-platform/issues/new

---

## Feature Request

### Summary
Add a new chat functionality as a separate page that integrates with the Microsoft Foundry Phi4 endpoint to provide AI-powered chat capabilities.

### Description
Implement a simple chat feature that allows users to:
- Send text messages to the deployed Phi4 model endpoint
- View AI-generated responses in a text area
- Maintain conversation history within the session

### Acceptance Criteria
- [ ] Create a new `ChatController` with actions for displaying the chat page and handling message submissions
- [ ] Create a new `ChatService` to handle communication with the Microsoft Foundry Phi4 endpoint
- [ ] Create a Chat view page (`Views/Chat/Index.cshtml`) with:
  - A text input field for user messages
  - A text area to display conversation history
  - A submit button to send messages
- [ ] Configure the application to use the Phi4 endpoint settings from `appsettings.json`
- [ ] Register the `ChatService` in `Program.cs`
- [ ] Add navigation link to the chat page in the shared layout

### Technical Details

#### Configuration (appsettings.json)
Add the following configuration section:
```json
{
  "AzureOpenAI": {
    "Endpoint": "<FOUNDRY_ENDPOINT>",
    "ApiKey": "<API_KEY>",
    "DeploymentName": "phi-4"
  }
}
```

#### New Files to Create
1. **Controllers/ChatController.cs** - Handle chat page requests and message submissions
2. **Services/ChatService.cs** - Service to communicate with the Foundry Phi4 endpoint
3. **Views/Chat/Index.cshtml** - Chat UI page

#### Dependencies
- Add `Azure.AI.OpenAI` NuGet package for Azure OpenAI SDK integration

### Implementation Notes
- Follow existing patterns used in `HomeController` and `CartService`
- Use dependency injection for the `ChatService`
- The Phi4 model is already deployed via the Foundry infrastructure (see `infra/modules/foundry.bicep`)
- Consider using async/await for API calls to maintain responsiveness

### Related Infrastructure
The Foundry endpoint is deployed using the existing Bicep templates. The endpoint URL and API key should be configured as environment variables or app settings for the deployed App Service.

### Labels
enhancement, feature
