# Sleepy - REST API Client

### About

Basic REST API client. I found similar plugins (while awesome) had more features than I needed.
So I decided to create my own that fit my personal needs.

I only wanted a few things: 

- make http requests 
- display each response in its own buffer
- flexible response formatting
- allow for simple testing



### Usage

Sleepy uses lua tables as the construct for holding job details. 
You visually select the table, or multiple tables, and run `:Sleepy` 

NOTE: Selected text is wrapped in an array internally. So to run multiple jobs
they should be separated by a comma, but do not need to be wrapped in curly
brackets. This makes it easier to select one or multiple requests without making
things too complex.


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

            --- (optional) labeling with urlencode will add '---data-urlencode' prefix before the data
            ---@type sleepy.RequestData
            { urlencode = "" }, 

            --- (optional) labeling with raw will add '---data-raw' prefix before the data
            ---@type sleepy.RequestData
            { raw = "" },

            --- (optional) labeling with text will add '---data' prefix before the data
            ---@type sleepy.RequestData
            { text = "" },

            --- (optional) converts the table to json and will add '---data' prefix before the data
            ---@type sleepy.RequestData
            { json = { } },

            --- (optional) no label will use the data type and request type to decide which prefix to use 
            ---@type sleepy.RequestData
            { "" }

            --- (optional) no label will use the data type and request type to decide which prefix to use 
            ---@type sleepy.RequestData
            { { } }
        },

        --- (optional) array of additional curl arguments as strings
        ---@type string[]
        additional_args = { }
    },

    --- (optional) runs after the response is loaded into the buffer, used for formatting
    ---@type fun(data: sleepy.ResponseData)
    after = nil

    --- (optional) runs last, runs tests against the reponse data
    ---@type fun(data: sleepy.ResponseData): sleepy.TestResult[]
    test = nil
},

```

### Examples

GET Examples:

```lua

{ 
    name = "pikachu", 
    request = { 
        type = "GET", 
        url = "https://pokeapi.co/api/v2/pokemon/pikachu", 
    }
}, --- this comma is important when selecting multiple jobs

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


{ 
    name = "another get example",
    request = {
        type = "GET", 
        url = "https://mockapi.com/api",
        headers = {
            "apikey:12345" 
        },
        data = {
            { urlencode = "lean=1" }, -- forced --data-urlencode
            { "param1=\"something\"" }, -- implied --data-urlencode from GET request type
            { "param2=\"something else\"" }, -- implied --data-urlencode from GET request type
        },
    },
},

```


POST Examples:

```lua

{ 
    name = "post example",
    request = {
        type = "POST", 
        url = "http://localhost:8080",
        headers = {
            "Content-Type: application/json"
        },
        data = {
            {
                json = { -- force lua table to be json encoded
                    Name = "mock lua table",
                    Description = "this will be converted to json",
                    Variables = {
                        { Name = "One", Value = 1 }
                        { Name = "Two", Value = 2 }
                        { Name = "Three", Value = 3 }
                    }
                }
            },
        },
    },
},


{ 
    name = "another post example",
    request = {
        type = "POST", 
        url = "http://localhost:8080",
        headers = {
            "Content-Type: application/json"
        },
        data = {
            { -- this string will be used as a standard --data body
                [[
{
    "Name": "lua multiline json string",
    "Description": "multiline strings work too",
    "Note": "indentation will be included, thats why the wierd formatting"
}
                ]]
            },
        },
    },
},

```

### Using assert


todo
