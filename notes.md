

request: 
```json
{
 "modelId": "amazon.titan-text-express-v1",
 "contentType": "application/json",
 "accept": "application/json",
 "body": "BODY"
}
```

### Anthropic

request body
```json
"anthropic_version": "bedrock-2023-05-31",
"max_tokens": 1000,
"messages": [
    {
    "role": "user",
    "content": [
        {
        "type": "image",
        "source": {
            "type": "base64",
            "media_type": "image/jpeg",
            "data": "iVBORw..."
        }
        },
        {
        "type": "text",
        "text": "You input text goes here"
        }
    ]
    }
]
```

response body 
```json
{
    "id":"msg_bdrk_0146cw8Wd6Dn8WZiQWeF6TEj",
    "type":"message",
    "role":"assistant",
    "model":"claude-3-haiku-20240307",
    "content":[
        {
            "type":"text",
            "text":"Completion!"
        }],
    "stop_reason":"max_tokens",
    "stop_sequence":null,
    "usage":{
        "input_tokens":12,
        "output_tokens":100}
}
```

### Titan 
TEXT 

```
// public func getInvokeModelInput(body: Codable) -> InvokeModelInput {
//     do { 
//         let jsonData: Data = try JSONEncoder().encode(body)
//         return InvokeModelInput(
//             accept: accept,
//             body: jsonData,
//             contentType: contentType,
//             modelId: modelId)
//     } catch {
//         print("Encoding error: (error)")
//         fatalError() // FIXME
//     }
// }

// public func getBody() -> any Codable {
//     return body
// }
```

request body: 
```json
{
    "inputText":"this is where you place your input text",
    "textGenerationConfig":
    {
        "maxTokenCount":8192,
        "stopSequences":[],
        "temperature":0,
        "topP":1
    }
}
```

```json
{
    "inputTextTokenCount":5,
    "results":[
        {
            "tokenCount":105,
            "outputText":"completion!",
            "completionReason":"FINISH"
            }
    ]
}
```

#### Image

Request: 
```json
{
    "textToImageParams":{
        "text":"this is where you place your input text"
    },
    "taskType":"TEXT_IMAGE",
    "imageGenerationConfig":{
        "cfgScale":8,
        "seed":42,
        "quality":"standard",
        "width":1024,
        "height":1024,
        "numberOfImages":3
    }
}
```


### Nova 

// {
//   "modelId": "amazon.nova-micro-v1:0",
//   "contentType": "application/json",
//   "accept": "application/json",
//   "body": {
//     "inferenceConfig": {
//       "max_new_tokens": 1000
//     },
//     "messages": [
//       {
//         "role": "user",
//         "content": [
//           {
//             "text": "this is where you place your input text"
//           }
//         ]
//       }
//     ]
//   }
// }


// {
//     "output":{
//         "message":{
//             "content":[
//                 {"text":"completion!"}
//             ],
//             "role":"assistant"
//         }},
//     "stopReason":"end_turn",
//     "usage":{
//         "inputTokens":5,
//         "outputTokens":244,
//         "totalTokens":249,
//         "cacheReadInputTokenCount":0,
//         "cacheWriteInputTokenCount":0
//     }
// }

listFoundationModelsInput

// let byCustomizationType = input.byCustomizationType
// let byInferenceType = input.byInferenceType
// let byOutputModality = input.byOutputModality
// let byProvider = input.byProvider

#### Image 

request 
```json
{
    "textToImageParams":{
        "text":"this is where you place your input text"
    },
    "taskType":"TEXT_IMAGE",
    "imageGenerationConfig":{
        "cfgScale":8,
        "seed":42,
        "quality":"standard",
        "width":1280,
        "height":720,
        "numberOfImages":3
    }
}
```

## DeepSeek 

WRONG requestbody 
```json
{
    "inferenceConfig": {
        "max_tokens": 512
    },
    "messages": [
        {
        "role": "user",
        "content": "this is where you place your input text"
        }
    ]
}
```

CORRECT requestbody
```json
{
    "prompt": "\(prompt)",
    "temperature": 1, 
    "top_p": 0.9,
    "max_tokens": 200,
    "stop": ["END"]
}
```

response
```json
{
    "choices":
        [
            {
                "text":"completion",
                "stop_reason":"length"
            }
        ]
}
```

## error with api check 
```yml
# api_breakage_check_container_image: "swift:6.0-noble"
# error message: 
#  * [new ref]         HEAD       -> pull-base-ref
# /__w/_temp/c5c97eea-ace5-4088-a5fe-5360536f3f1e.sh: 2: [[: not found
# error: Could not find Package.swift in this directory or any of its parent directories.
# Error: Process completed with exit code 1.
```