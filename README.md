# Sleepy - REST API Client

### About

Basic REST API client. I found similar plugins (while awesome) had more features than I needed.
So I decided to create my own that fit my personal needs.

I only wanted a few things: 

- make an http request(s) 
- display each response in its own buffer
- flexible response formatting
- allow for testing



### Usage

Sleepy uses lua tables as the construct for holding job details. 
You visually select the table, or multiple tables, and run `:Sleepy` 

NOTE: Selected text is wrapped in an array internally. So to run multiple jobs
they should be separated by a comma, but do not need to be wrapped in curly
brackets.


#### Job template

```lua

---@type sleepy.Job
{ 
    --- (optional) name of the job, will be used to name the response buffer
    ---@type string
    name = "", 

    --- (required) request details 
    ---@type sleepy.HttpRequest
    request = {

        --- (required) request type  [ "GET", "POST" ]
        ---@type string
        type = "",

        --- (required) request url
        ---@type string
        url = "",

        --- (optional) array of header strings
        ---@type string[]
        headers = { },

        --- (optional) request body
        ---@type sleepy.RequestData[]
        data = {

            --- (optional) labeling with urlencode will force '---data-urlencode' prefix before the string
            ---@type sleepy.RequestData
            { urlencode = "" }, 

            --- (optional) labeling with raw will force '---data' prefix before the string
            ---@type sleepy.RequestData
            { raw = "" },

            --- (optional) no label will use the request to decide which prefix to use 
            ---@type sleepy.RequestData
            { "" }
        },

        --- (optional) array of additional curl arguments as strings
        ---@type string[]
        additional_args = { }
    },

    --- (optional) runs after the response is loaded into the buffer, used for formatting
    ---@type fun(data: sleepy.ResponseData)
    after = nil

    --- (optional) for running tests against the reponse data
    ---@type fun(data: sleepy.ResponseData): sleepy.TestResult[]
    test = nil
},

```

### Examples

GET requests:

```lua

{ 
    name = "pikachu", 
    request = { 
        type = "GET", 
        url = "https://pokeapi.co/api/v2/pokemon/pikachu", 
    },
},

{ 
    name = "ditto", 
    request = { 
        type = "GET", 
        url = "https://pokeapi.co/api/v2/pokemon/ditto", 
        headers = { 
            "apikey:1234567890"
        }, 
        additional_args = {  
            "-i"
        },
    },
    after = function(data) 
        vim.cmd(":%!jq") -- format the json response, requires jq
    end,
    test = function(data) 
        local assert = require("sleepy.assert")
        return {
            {
                name = "",
                -- assumes data is json, follows a path and checks the key's value
                result = assert.json_path_value(data, { "abilities", 1, "ability", "name" }, "limber")
            },
            {
                name = "has a name key",
                -- assumes data is json, follows a path and checks if a key exists
                result = assert.json_has_key(data, { "abilities", 1, "ability", "name" })
            },
            { 
                name = "name is ditto",
                -- searches the data for a string
                result = assert.data_contains(data, 'name.*ditto') 
            }
        }
    end
},

```

### Using assert


todo
