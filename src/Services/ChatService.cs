using Azure;
using Azure.AI.OpenAI;

namespace ZavaStorefront.Services
{
    public class ChatService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ChatService> _logger;
        private readonly string _endpoint;
        private readonly string _deploymentName;
        private readonly string _apiKey;

        public ChatService(IConfiguration configuration, ILogger<ChatService> logger)
        {
            _configuration = configuration;
            _logger = logger;
            _endpoint = _configuration["AZURE_OPENAI_ENDPOINT"] ?? "";
            _deploymentName = _configuration["AZURE_OPENAI_DEPLOYMENT_NAME"] ?? "Phi-4";
            _apiKey = _configuration["AZURE_OPENAI_API_KEY"] ?? "";
        }

        public async Task<string> GetChatResponseAsync(string userMessage)
        {
            try
            {
                _logger.LogInformation("Sending chat request to Azure OpenAI");

                var client = new OpenAIClient(new Uri(_endpoint), new AzureKeyCredential(_apiKey));

                var chatCompletionsOptions = new ChatCompletionsOptions()
                {
                    DeploymentName = _deploymentName,
                    Messages =
                    {
                        new ChatRequestSystemMessage("You are a helpful assistant for Zava Storefront. Help customers with questions about products, pricing, and general inquiries."),
                        new ChatRequestUserMessage(userMessage)
                    },
                    MaxTokens = 800,
                    Temperature = 0.7f
                };

                var response = await client.GetChatCompletionsAsync(chatCompletionsOptions);
                var completion = response.Value.Choices[0].Message.Content;

                _logger.LogInformation("Received chat response from Azure OpenAI");
                return completion;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting chat response from Azure OpenAI");
                throw;
            }
        }
    }
}
