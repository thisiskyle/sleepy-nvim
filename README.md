# Sleepy - REST API Client

## About

Another REST API client. I found similar plugins had more features than I needed. 
So feature wise, Sleepy is pretty minimal.

If you want something more feature complete check out [kulala.nvim](kulala).

<br>

## Installation

Lazy:

```lua
{
    "thisiskyle/sleepy-nvim",
    opts = {},
}
```

<br>

## Configuration

```lua
opts = {

    -- (optional) this function will be run after the response data is added to the new buffer useful for formatting the response
    -- NOTE: this will be overidden by sleepy.Job.after if one is set
    --@type fun()?
    global_after = function() end,

},
```

<br>

## Usage

Sleepy uses lua tables to build curl commands to make https requests. 
To tell sleepy what tables to user, you visually select the table, or multiple tables, and run `:Sleepy` 

Selected text is wrapped in an array internally. So to run multiple jobs
they should be separated by a comma, but do not need to be wrapped in curly
brackets. 


### Job Template

```lua

---@type sleepy.Job
{ 
    --- (optional) name of the job, will be used to name the response buffer
    ---@type string
    name = "", 

    --- (required) request type  [ "GET", "POST" ]
    ---@type string
    type = "",

    --- (required) request url
    ---@type string
    url = "",

    --- (optional) array of header strings
    ---@type string[]
    headers = { },

    --- (optional) request body / url params
    ---@type sleepy.RequestData[]
    data = {

        --- (optional) add '---data-urlencode' prefix before the data
        ---@type sleepy.RequestData
        { urlencode = "" }, 

        --- (optional) add '---data-raw' prefix before the data
        ---@type sleepy.RequestData
        { raw = "" },

        --- (optional) encodes the table as json and will add '---data' prefix before the data
        ---@type sleepy.RequestData
        { json_encode = { } },

        --- (optional) use the data type and request type to decide which prefix to use 
        --- on a GET request, this will be sent as '---data-urlencoded'
        --- on a POST request, this will be treated as standard '---data'
        ---@type sleepy.RequestData
        { "" },

        --- (optional) use the data type and request type to decide which prefix to use 
        --- on a GET request, this table be ignored
        --- on a POST request, this table will be encoded as json and sent as '---data'
        ---@type sleepy.RequestData
        { { } },
    },

    --- (optional) array of additional curl arguments as strings
    ---@type string[]
    additional_args = { },

    --- (optional) runs after the response is loaded into the buffer, used for formatting
    ---@type fun(data: sleepy.ResponseData)
    after = nil,

    --- (optional) runs last, runs tests against the reponse data
    ---@type fun(data: sleepy.ResponseData): sleepy.TestResult[]
    test = nil,
},

```

### Examples

GET Requests:

```lua

{ 
    name = "pikachu", 
    type = "GET", 
    url = "https://pokeapi.co/api/v2/pokemon/pikachu", 
}, --- this comma is important for selecting multiple jobs

{ 
    name = "ditto", 
    type = "GET", 
    url = "https://pokeapi.co/api/v2/pokemon/ditto", 
    headers = { 
        "apikey:1234567890"
    }, 
    additional_args = {  
        "-i"
    },
    after = function(data) 
        vim.cmd(":%!jq") -- format the json response, requires jq
    end,
    test = function(data) 
        -- import sleepy.assert for some test helper functions
        local assert = require("sleepy.assert")
        return {
            {
                -- assumes response data is json, follows a path and checks the key's value
                name = "",
                result = assert.json_path_equals(data, { "abilities", 1, "ability", "name" }, "limber")
            },
            {
                -- assumes response data is json, follows a path and checks if a key exists
                name = "has a name key",
                result = assert.json_path_exists(data, { "abilities", 1, "ability", "name" })
            },
            { 
                -- searches the data for a string
                name = "name is ditto",
                result = assert.data_contains(data, 'name.*ditto') 
            },
            { 
                -- you can use your own function if assert does fit your needs
                name = "always true",
                result = (function()
                    return true
                end)()
            }
        }
    end
}, --- this comma is important when selecting multiple jobs


{ 
    name = "another get example",
    type = "GET", 
    url = "https://mockapi.com/api",
    headers = {
        "apikey:12345" 
    },
    data = {
        { urlencode = "lean=1" }, -- data prefixed with --data-urlencode in curl command
        { "param1=\"something\"" }, -- in a GET request, unlabeled string will be prefixed with --data-urlencode in curl command
        { { } }, -- in a GET request, table will be ignored
    },
},

```


POST Requests:

```lua

{ 
    name = "post example",
    type = "POST", 
    url = "http://localhost:8080",
    headers = {
        "Content-Type: application/json"
    },
    data = {
        {
            -- lua table will be json encoded and prefixed by --data in the curl command
            json_encode = {
                Name = "lua table",
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


{ 
    name = "another post example",
    type = "POST", 
    url = "http://localhost:8080",
    headers = {
        "Content-Type: application/json"
    },
    data = {
        -- in a POST request, unlabled strings will be prefixed by --data in the curl command
        { 
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

{ 
    name = "post example",
    type = "POST", 
    url = "http://localhost:8080",
    headers = {
        "Content-Type: application/json"
    },
    data = {
        {
            -- lua table will be json encoded and prefixed by --data in the curl command
            {
                Name = "lua table",
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

 




```

[kulala]:  <https://github.com/mistweaverco/kulala.nvim>

