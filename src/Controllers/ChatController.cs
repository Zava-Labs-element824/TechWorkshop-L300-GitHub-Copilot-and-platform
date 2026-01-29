using Microsoft.AspNetCore.Mvc;
using ZavaStorefront.Models;
using ZavaStorefront.Services;

namespace ZavaStorefront.Controllers
{
    public class ChatController : Controller
    {
        private readonly ILogger<ChatController> _logger;
        private readonly ChatService _chatService;

        public ChatController(ILogger<ChatController> logger, ChatService chatService)
        {
            _logger = logger;
            _chatService = chatService;
        }

        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> SendMessage([FromBody] ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return Json(new ChatResponse
                {
                    Success = false,
                    Error = "Message cannot be empty"
                });
            }

            try
            {
                _logger.LogInformation("Processing chat message: {Message}", request.Message);
                var response = await _chatService.GetChatResponseAsync(request.Message);

                return Json(new ChatResponse
                {
                    Success = true,
                    Response = response
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chat message");
                return Json(new ChatResponse
                {
                    Success = false,
                    Error = "An error occurred while processing your request. Please try again."
                });
            }
        }
    }
}
