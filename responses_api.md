# SwiftOpenAI Responses API Documentation

The Responses API is a newer, more advanced interface for generating chats with predefined message history and stateful conversations. This documentation focuses on how to integrate it in place of completions, particularly for generating new chats with predefined message history.

## Key Differences from Chat Completions

- **Stateful conversations**: Uses `previousResponseId` to chain responses and maintain conversation history
- **Rich input types**: Supports text, images, files, and audio inputs
- **Structured outputs**: Returns detailed response objects with various output types
- **Built-in tools**: Native support for file search, web search, and computer use

## Core Files

### Parameters
- **`Sources/OpenAI/Public/Parameters/Response/ModelResponseParameter.swift`**
  - Main parameter structure for creating responses
  - Contains `previousResponseId` for conversation continuity

### Response Models
- **`Sources/OpenAI/Public/ResponseModels/Response/ResponseModel.swift`**
  - Response structure returned by the API
  - Includes `outputText` property for easy text extraction

### Input Types
- **`Sources/OpenAI/Public/Parameters/Response/InputType.swift`**
  - Defines supported input formats (text, images, files, audio)

## Basic Usage for Predefined Message History

### 1. Initial Response (Starting a Conversation)

```swift
import OpenAI

let service = OpenAIServiceFactory.service(apiToken: "your-api-key")

// Create initial response with predefined context
let initialParameters = ModelResponseParameter(
    input: .text("You are a helpful assistant. Previous conversation context: [Your predefined history here]"),
    model: .gpt4o,
    instructions: "Continue the conversation naturally based on the provided context"
)

let initialResponse = try await service.responseCreate(initialParameters)
let responseId = initialResponse.id
```

### 2. Follow-up Responses (Continuing the Conversation)

```swift
// Continue conversation using previousResponseId
let followUpParameters = ModelResponseParameter(
    input: .text("User's new message"),
    model: .gpt4o,
    previousResponseId: responseId, // Links to previous response
    instructions: "Continue the conversation"
)

let followUpResponse = try await service.responseCreate(followUpParameters)
```

### 3. Complex Input with Multiple Content Types

```swift
// Using array input for mixed content
let complexParameters = ModelResponseParameter(
    input: .array([
        .text("Continue our previous discussion about:"),
        .text("- Topic 1\n- Topic 2\n- Topic 3"),
        .text("Now let's focus on the user's new question:")
    ]),
    model: .gpt4o,
    previousResponseId: previousResponseId
)
```

## Key Properties for Message History

### ModelResponseParameter Properties

```swift
public struct ModelResponseParameter {
    public let input: InputType                    // Your message content
    public let model: Model                        // Model to use
    public let previousResponseId: String?         // CRITICAL for conversation continuity
    public let instructions: String?               // System instructions
    public let reasoningEffort: String?           // For o-series models
    public let tools: [Tool]?                     // Available tools
    public let stream: Bool?                      // Streaming (not yet supported)
    // ... other properties
}
```

### ResponseModel Properties

```swift
public struct ResponseModel {
    public let id: String                         // Use this as previousResponseId
    public let status: String                     // Response status
    public let output: [OutputItem]              // Response content
    public let usage: Usage?                     // Token usage
    
    // Convenience property for text extraction
    public var outputText: String {
        // Automatically extracts text from all output items
    }
}
```

## Conversation Flow Pattern

```swift
class ConversationManager {
    private var currentResponseId: String?
    private let service: OpenAIService
    
    func startConversation(with predefinedHistory: String) async throws -> String {
        let parameters = ModelResponseParameter(
            input: .text("Previous conversation:\n\(predefinedHistory)\n\nContinue naturally."),
            model: .gpt4o,
            instructions: "You are continuing a conversation. Reference the previous context appropriately."
        )
        
        let response = try await service.responseCreate(parameters)
        currentResponseId = response.id
        return response.outputText
    }
    
    func continueConversation(with userMessage: String) async throws -> String {
        let parameters = ModelResponseParameter(
            input: .text(userMessage),
            model: .gpt4o,
            previousResponseId: currentResponseId, // Maintains conversation state
            instructions: "Continue the ongoing conversation"
        )
        
        let response = try await service.responseCreate(parameters)
        currentResponseId = response.id // Update for next turn
        return response.outputText
    }
}
```

## Advanced Features

### With Tools Integration

```swift
let parametersWithTools = ModelResponseParameter(
    input: .text("Help me search for information about Swift"),
    model: .gpt4o,
    previousResponseId: currentResponseId,
    tools: [
        .webSearch(WebSearchTool()),
        .fileSearch(FileSearchTool())
    ]
)
```

### With Reasoning (o-series models)

```swift
let parametersWithReasoning = ModelResponseParameter(
    input: .text("Solve this complex problem..."),
    model: .o1Preview,
    previousResponseId: currentResponseId,
    reasoning: Reasoning(
        effort: .high,
        summarizeResult: true
    )
)
```

## Current Limitations

1. **No Streaming Support**: Current implementation sets `stream = false`
2. **No Demo Example**: Unlike other APIs, there's no dedicated demo in the Examples folder
3. **Error Handling**: Make sure to handle API errors appropriately

## Migration from Chat Completions

### Before (Chat Completions)
```swift
let chatParameters = ChatCompletionParameters(
    messages: [
        ChatMessage(role: .system, content: "You are a helpful assistant"),
        ChatMessage(role: .user, content: "Hello")
    ],
    model: .gpt4o
)
```

### After (Responses API)
```swift
let responseParameters = ModelResponseParameter(
    input: .text("Hello"),
    model: .gpt4o,
    instructions: "You are a helpful assistant",
    previousResponseId: nil // Start new conversation
)
```

## Testing

The API is well-tested with comprehensive test coverage in `Tests/OpenAITests/OpenAITests.swift`, including scenarios for:
- Basic response creation
- Function calls
- File search
- Web search
- Computer use
- Reasoning with o-series models

## Service Methods

```swift
protocol OpenAIService {
    // Create a new response
    func responseCreate(_ parameters: ModelResponseParameter) async throws -> ResponseModel
    
    // Retrieve an existing response by ID
    func responseModel(id: String) async throws -> ResponseModel
}
```

The Responses API is designed to replace chat completions for stateful, multi-turn conversations where maintaining conversation history and context is crucial.