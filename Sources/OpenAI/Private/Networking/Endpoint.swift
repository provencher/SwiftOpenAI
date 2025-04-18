//
//  Endpoint.swift
//
//
//  Created by James Rochabrun on 10/11/23.
//

import Foundation

// MARK: HTTPMethod

enum HTTPMethod: String {
   case post = "POST"
   case get = "GET"
   case delete = "DELETE"
}

// MARK: Endpoint

protocol Endpoint {
   func path(
      in openAIEnvironment: OpenAIEnvironment)
      -> String
}

// MARK: Endpoint+Requests

extension Endpoint {

   private func urlComponents(
      base: String,
      path: String,
      queryItems: [URLQueryItem])
      -> URLComponents
   {
      var components = URLComponents(string: base)!
      components.path = path
      if !queryItems.isEmpty {
         components.queryItems = queryItems
      }
      return components
   }
   
   func request(
      apiKey: Authorization,
      openAIEnvironment: OpenAIEnvironment,
      organizationID: String?,
      method: HTTPMethod,
      params: Encodable? = nil,
      queryItems: [URLQueryItem] = [],
      betaHeaderField: String? = nil,
      extraHeaders: [String: String]? = nil)
      throws -> URLRequest
   {
    
          // Use path(in:) for flexibility, but ensure correct appending
          let finalPath = path(in: openAIEnvironment) // Typically "/v1/chat/completions"
          
          // Construct URL components
          var components = URLComponents(string: openAIEnvironment.baseURL)!
          let currentPath = components.path.isEmpty ? "" : components.path
          components.path = currentPath + (finalPath.hasPrefix("/") ? "" : "/") + finalPath
          if !queryItems.isEmpty {
                  components.queryItems = queryItems
          }
          
          // Validate and create request
          guard let url = components.url else {
                  throw URLError(.badURL)
          }
          var request = URLRequest(url: url)
          
          // Set headers
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          request.setValue(apiKey.value, forHTTPHeaderField: apiKey.headerField)
          if let organizationID {
                  request.setValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
          }
          if let betaHeaderField {
                  request.setValue(betaHeaderField, forHTTPHeaderField: "OpenAI-Beta")
          }
          if let extraHeaders {
                  extraHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
          }
          
      request.httpMethod = method.rawValue
      if let params {
         request.httpBody = try JSONEncoder().encode(params)
      }
          request.timeoutInterval = 1000
          
      return request
   }
       
       func requestAzure(
               apiKey: Authorization,
               openAIEnvironment: OpenAIEnvironment,
               organizationID: String?,
               method: HTTPMethod,
               params: Encodable? = nil,
               queryItems: [URLQueryItem] = [],
               betaHeaderField: String? = nil,
               extraHeaders: [String: String]? = nil)
       throws -> URLRequest
       {
               let finalPath = path(in: openAIEnvironment)
               var request = URLRequest(url: urlComponents(base: openAIEnvironment.baseURL, path: finalPath, queryItems: queryItems).url!)
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
               request.addValue(apiKey.value, forHTTPHeaderField: apiKey.headerField)
               if let organizationID {
                       request.addValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
               }
               if let betaHeaderField {
                       request.addValue(betaHeaderField, forHTTPHeaderField: "OpenAI-Beta")
               }
               if let extraHeaders {
                       for header in extraHeaders {
                               request.addValue(header.value, forHTTPHeaderField: header.key)
                       }
               }
               request.httpMethod = method.rawValue
               if let params {
                       request.httpBody = try JSONEncoder().encode(params)
               }
               
               request.timeoutInterval = 1000

               return request
       }
   
   func multiPartRequest(
      apiKey: Authorization,
      openAIEnvironment: OpenAIEnvironment,
      organizationID: String?,
      method: HTTPMethod,
      params: MultipartFormDataParameters,
      queryItems: [URLQueryItem] = [])
      throws -> URLRequest
   {
      let finalPath = path(in: openAIEnvironment)
      var request = URLRequest(url: urlComponents(base: openAIEnvironment.baseURL, path: finalPath, queryItems: queryItems).url!)
      request.httpMethod = method.rawValue
      let boundary = UUID().uuidString
      request.addValue(apiKey.value, forHTTPHeaderField: apiKey.headerField)
      if let organizationID {
         request.addValue(organizationID, forHTTPHeaderField: "OpenAI-Organization")
      }
      request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
      request.httpBody = params.encode(boundary: boundary)
         request.timeoutInterval = 1000

      return request
   }
}