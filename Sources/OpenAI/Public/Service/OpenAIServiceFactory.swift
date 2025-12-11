//
//  OpenAIServiceFactory.swift
//
//
//  Created by James Rochabrun on 10/18/23.
//

import Foundation

public class OpenAIServiceFactory {

  /// Creates and returns an instance of `OpenAIService`.
  ///
  /// - Parameters:
  ///   - apiKey: The API key required for authentication.
  ///   - organizationID: The optional organization ID for multi-tenancy (default is `nil`).
  ///   - configuration: The URL session configuration to be used for network calls (default is `.default`).
  ///   - decoder: The JSON decoder to be used for parsing API responses (default is `JSONDecoder.init()`).
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.

  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    apiKey: String,
    organizationID: String? = nil,
    configuration: URLSessionConfiguration = .default,
    decoder: JSONDecoder = .init(),
    debugEnabled: Bool = false,
    includeUsageInStream: Bool = true)
    -> OpenAIService
  {
    DefaultOpenAIService(
      apiKey: apiKey,
      organizationID: organizationID,
      configuration: configuration,
      decoder: decoder,
      debugEnabled: debugEnabled,
      includeUsageInStream: includeUsageInStream)
  }

  // MARK: Azure

  /// Creates and returns an instance of `OpenAIService`.
  ///
  /// - Parameters:
  ///   - azureConfiguration: The AzureOpenAIConfiguration.
  ///   - urlSessionConfiguration: The URL session configuration to be used for network calls (default is `.default`).
  ///   - decoder: The JSON decoder to be used for parsing API responses (default is `JSONDecoder.init()`).
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    azureConfiguration: AzureOpenAIConfiguration,
    urlSessionConfiguration: URLSessionConfiguration = .default,
    decoder: JSONDecoder = .init(),
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    DefaultOpenAIAzureService(
      azureConfiguration: azureConfiguration,
      urlSessionConfiguration: urlSessionConfiguration,
      decoder: decoder,
      debugEnabled: debugEnabled)
  }

  // MARK: Custom URL

  /// Creates and returns an instance of `OpenAIService`.
  ///
  /// Use this service if you need to provide a custom URL, for example to run local models with OpenAI endpoints compatibility using Ollama.
  /// Check [Ollama blog post](https://ollama.com/blog/openai-compatibility) for more.
  ///
  /// - Parameters:
  ///   - apiKey: The optional API key required for authentication.
  ///   - baseURL: The local host URL. defaults to  "http://localhost:11434"
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    apiKey: Authorization = .apiKey(""),
    baseURL: String,
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    LocalModelService(
      apiKey: apiKey,
      baseURL: baseURL,
      debugEnabled: debugEnabled)
  }

  // MARK: Proxy Path

  /// Creates and returns an instance of `OpenAIService`.
  ///
  /// Use this service if you need to provide a custom URL with a proxy path, for example to run Groq.
  ///
  /// - Parameters:
  ///   - apiKey: The optional API key required for authentication.
  ///   - baseURL: The local host URL.  e.g "https://api.groq.com" or "https://generativelanguage.googleapis.com"
  ///   - proxyPath: The proxy path e.g `openai`
  ///   - overrideVersion: The API version. defaults to `v1`
  ///   - extraHeaders: Additional headers needed for the request. Do not provide API key in these headers.
  ///   - debugEnabled: If `true` service prints event on DEBUG builds, default to `false`.
  ///
  /// - Returns: A fully configured object conforming to `OpenAIService`.
  public static func service(
    apiKey: String,
    overrideBaseURL: String,
    configuration: URLSessionConfiguration = .default,
    proxyPath: String? = nil,
    overrideVersion: String? = nil,
    extraHeaders: [String: String]? = nil,
    includeUsageInStream: Bool = true,
    debugEnabled: Bool = false)
    -> OpenAIService
  {
    DefaultOpenAIService(
      apiKey: apiKey,
      baseURL: overrideBaseURL,
      proxyPath: proxyPath,
      overrideVersion: overrideVersion,
      extraHeaders: extraHeaders,
      configuration: configuration,
      debugEnabled: debugEnabled,
      includeUsageInStream: includeUsageInStream)
  }
}
