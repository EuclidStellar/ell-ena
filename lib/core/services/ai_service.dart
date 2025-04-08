import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/utils/logger.dart';

class AIService {
  // Update to use Gemini API key and URL
  final String? apiKey = 'Your-Gemini-API-key'; // Using provided key directly
  final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  final AppLogger _logger = AppLogger();

  AIService() {
    if (apiKey == null || apiKey!.isEmpty) {
      _logger.error('Gemini API key is not set.');
    }
  }

  Future<String> getAIResponse(String userMessage, List<Map<String, String>> history) async {
    try {
      if (apiKey == null || apiKey!.isEmpty) {
        return "Error: Gemini API key is not set up. Please add your key.";
      }

      // Format the history for Gemini API
      final List<Map<String, dynamic>> formattedHistory = [];
      
      // Add system prompt as the first message
      formattedHistory.add({
        "role": "user",
        "parts": [{"text": _getSystemPrompt()}]
      });
      
      // Add conversation history
      for (final msg in history) {
        final role = msg["role"] == "user" ? "user" : "model";
        formattedHistory.add({
          "role": role,
          "parts": [{"text": msg["content"]}]
        });
      }
      
      // Add current user message
      formattedHistory.add({
        "role": "user",
        "parts": [{"text": userMessage}]
      });

      // Make API request with the correct Gemini format
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": formattedHistory,
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 800,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract content from Gemini response format
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          _logger.error('Unexpected Gemini response format: $data');
          return "Sorry, I couldn't process that properly.";
        }
      } else {
        _logger.error('API Error: ${response.statusCode} - ${response.body}');
        return "Sorry, I couldn't process that request. Please try again later.";
      }
    } catch (e) {
      _logger.error('Error in AI service: $e');
      return "I'm having trouble connecting right now. Please try again later.";
    }
  }

  Future<Task?> extractTaskFromMessage(String message) async {
    try {
      if (apiKey == null || apiKey!.isEmpty) {
        _logger.error('Gemini API key is not set.');
        return null;
      }

      final prompt = '''
Extract task information from the following message and format as JSON:
Message: $message

Please extract:
1. Task title (concise but descriptive)
2. Task description (more details)
3. Task type (todo, ticket, or meetingNote)
4. Priority (low, medium, high, urgent)
5. Due date (in YYYY-MM-DD format, if mentioned)
6. Tags (list of relevant keywords)

Return ONLY valid JSON without explanation, commentary or code formatting:
{
  "title": "",
  "description": "",
  "type": "",
  "priority": "",
  "dueDate": null,
  "tags": []
}
''';

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [{
            "role": "user",
            "parts": [{"text": prompt}]
          }],
          "generationConfig": {
            "temperature": 0.3,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract the JSON content from Gemini response
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          
          // Parse the JSON content
          final jsonResult = _extractJsonFromText(content);
          if (jsonResult == null) {
            _logger.error('Failed to extract JSON from Gemini response');
            return null;
          }
          
          // Map the task type and priority
          TaskType taskType;
          switch (jsonResult['type'].toString().toLowerCase()) {
            case 'ticket':
              taskType = TaskType.ticket;
              break;
            case 'meetingnote':
            case 'meeting note':
            case 'meeting':
              taskType = TaskType.meetingNote;
              break;
            case 'todo':
            default:
              taskType = TaskType.todo;
              break;
          }
          
          TaskPriority priority;
          switch (jsonResult['priority'].toString().toLowerCase()) {
            case 'low':
              priority = TaskPriority.low;
              break;
            case 'high':
              priority = TaskPriority.high;
              break;
            case 'urgent':
              priority = TaskPriority.urgent;
              break;
            case 'medium':
            default:
              priority = TaskPriority.medium;
              break;
          }
          
          // Parse due date if provided
          DateTime? dueDate;
          if (jsonResult['dueDate'] != null && jsonResult['dueDate'] != "null" && jsonResult['dueDate'].toString().isNotEmpty) {
            try {
              dueDate = DateTime.parse(jsonResult['dueDate']);
            } catch (e) {
              _logger.error('Error parsing due date: $e');
            }
          }
          
          // Create the task
          return Task(
            title: jsonResult['title'] ?? "Untitled Task",
            description: jsonResult['description'] ?? "",
            type: taskType,
            priority: priority,
            dueDate: dueDate,
            tags: jsonResult['tags'] != null ? List<String>.from(jsonResult['tags']) : [],
          );
        } else {
          _logger.error('Unexpected Gemini response format: $data');
          return null;
        }
      } else {
        _logger.error('API Error extracting task: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.error('Error extracting task: $e');
      return null;
    }
  }

  // Helper method to extract JSON from text that may contain other content
  Map<String, dynamic>? _extractJsonFromText(String text) {
    try {
      // First, try parsing the entire response as JSON
      try {
        return json.decode(text);
      } catch (_) {
        // If that fails, try to extract JSON using regex
        final regExp = RegExp(r'{[\s\S]*}');
        final match = regExp.firstMatch(text);
        
        if (match != null) {
          final jsonStr = match.group(0);
          if (jsonStr != null) {
            return json.decode(jsonStr);
          }
        }
        
        return null;
      }
    } catch (e) {
      _logger.error('Error extracting JSON: $e');
      return null;
    }
  }

  String _getSystemPrompt() {
    return '''
You are Ell-ena, an AI-powered product manager assistant. Your job is to help users manage tasks, create tickets, and transcribe meetings.

When users ask you to create tasks or tickets, understand their request and respond accordingly.

Examples of requests:
- "Create a task for the design review meeting tomorrow"
- "Add a ticket for implementing dark mode"
- "Add a to-do item for completing my assignment by Friday"

Include relevant details in your responses and always be helpful, concise, and professional.

Remember these task types:
1. To-Do items - simple tasks
2. Tickets - feature/bug work items
3. Meeting Notes - summaries and action items from meetings

When working with tasks, try to include details about priority, deadlines, and relevant context.
''';
  }
}